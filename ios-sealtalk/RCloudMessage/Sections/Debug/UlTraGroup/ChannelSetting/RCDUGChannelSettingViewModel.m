//
//  RCDUGChannelSettingViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2022/6/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUGChannelSettingViewModel.h"
#import "RCDUltraGroupManager.h"
#import "RCDUtilities.h"
#import "RCDGroupManager.h"
#import <RongIMKit/RCIM.h>

@interface RCDUGChannelSettingViewModel()
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, strong, readwrite) NSMutableArray *members;
@property (nonatomic, strong) NSMutableSet *whiteList;
@property (nonatomic, assign, readwrite) BOOL isPrivate;
@property (nonatomic, assign, readwrite) BOOL isOwner;

@end

@implementation RCDUGChannelSettingViewModel

- (instancetype)initWithGroupID:(NSString *)groupID
                      channelID:(NSString *)channelID
                      isPrivate:(BOOL)isPrivate
                       ownnerID:(NSString *)ownnerID
{
    self = [super init];
    if (self) {
        self.groupID = groupID;
        self.channelID = channelID;
        self.members = [NSMutableArray array];
        self.isPrivate = isPrivate;
        BOOL ret = [ownnerID isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId];
        self.isOwner = ret;
    }
    return self;
}

#pragma mark - Public
- (void)query {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self fetchAllMembers];
    });
}

- (CGSize)sizeForItem {
    return CGSizeMake(80, 100);
}

- (NSInteger)numberOfMemebers {
    return self.members.count;
}

- (RCDChannelUserInfoCellViewModel *)viewModelAtIndex:(NSIndexPath *)indexPath {
    return [self.members objectAtIndex:indexPath.row];
}

- (CGFloat)headerViewHeight {
    NSInteger count = [self numberOfMemebers];
    CGSize size = [self sizeForItem];
    NSInteger row = count/4;
    CGFloat height = 16 + row*(size.height+8);

    if (count%4!=0) {
        height += (size.height+8);
    }
    
    return height;
}

- (NSString *)stringOfChannelType {
    return self.isPrivate ? @"私有频道" : @"公有频道";
}

- (void)editChannelType {
    [RCDUltraGroupManager editUltraGroupChannelType:self.groupID channelID:self.channelID isPrivate:!self.isPrivate complete:^(NSString *channelID, BOOL result) {
            if (result) {
                self.isPrivate = !self.isPrivate;
            }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(editChannelTypeFinishedWith:)]) {
                [self.delegate editChannelTypeFinishedWith:result];
            }
            if ([self.typeDelegate respondsToSelector:@selector(channelTypeDidChangedTo:)]) {
                [self.typeDelegate channelTypeDidChangedTo:self.isPrivate];
            }
        });
    }];
}

- (CGFloat)heightForRowType:(RCDUGChannelSettingRowType)type {
    CGFloat height = 48;
    switch (type) {
        case RCDUGChannelSettingRowTypeChannelType:
            
            break;
            
        default:
            break;
    }
    return height;
}

- (void)disband {
    [RCDUltraGroupManager disbandUltraGroupChannel:self.groupID channelID:self.channelID complete:^(NSString *channelID, BOOL result) {
        if (result) {
            [[RCChannelClient sharedChannelManager] removeConversation:ConversationType_ULTRAGROUP
                                                              targetId:self.groupID
                                                             channelId:self.channelID];
        }
        if ([self.delegate respondsToSelector:@selector(disbandChannelFinishedWith:)]) {
            [self.delegate disbandChannelFinishedWith:result];
        }
    }];

}
#pragma mark - Private
/// 拉去白名单
/// @param members 全体成员列表
- (void)fetchAllMembersInWhiteList:(NSArray *)members {
    [RCDUltraGroupManager getUltraGroupMembersInWhiteList:self.groupID
                                                channelID:self.channelID
                                                    limit:100
                                                 complete:^(NSArray<NSString *> *memberIdList) {
        if (memberIdList.count) {
            [self.whiteList addObjectsFromArray:memberIdList];
        }
        // 填充成员信息
        [self fillMemberInfoWith:members];
    }];
}


- (void)fetchAllMembers {
    [RCDUltraGroupManager getUltraGroupMemberList:self.groupID
                                            count:100
                                         complete:^(NSArray<NSString *> *memberIdList) {
        [self fetchAllMembersInWhiteList:memberIdList];
    }];
}

- (void)fillMemberInfoWith:(NSArray<NSString *> *)memberIdList {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *userID in memberIdList) {
        [RCDUtilities getGroupUserDisplayInfo:userID
                                      groupId:self.groupID
                                       result:^(RCUserInfo *user) {
            RCDChannelUserInfo *info = [self channelUserInfoBy:user];
            RCDChannelUserInfoCellViewModel *vm = [[RCDChannelUserInfoCellViewModel alloc] initWith:info];
            if (vm) {
                [array addObject:vm];
            }
        }];
    }
    [self.members addObjectsFromArray:array];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(memberInfoDidLoaded)]) {
            [self.delegate memberInfoDidLoaded];
        }
    });
  
}

- (RCDChannelUserInfo *)channelUserInfoBy:(RCUserInfo *)user {
    if (user) {
        RCDChannelUserInfo *info = [RCDChannelUserInfo new];
        info.groupID = self.groupID;
        info.channelID = self.channelID;
        info.name = user.name;
        info.userID = user.userId;
        info.portrait = user.portraitUri;
        info.isInWhiteList = [self.whiteList containsObject:user.userId];
        return info;
    }
    return nil;;
}

- (NSMutableSet *)whiteList {
    if (!_whiteList) {
        _whiteList = [NSMutableSet set];
    }
    return _whiteList;
}
@end
