//
//  RCDChannelUserInfoCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2022/6/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDChannelUserInfoCellViewModel.h"
#import "RCDUltraGroupManager.h"


@interface RCDChannelUserInfoCellViewModel()
@property (nonatomic, strong, readwrite) RCDChannelUserInfo *userInfo;
@end

@implementation RCDChannelUserInfoCellViewModel

- (instancetype)initWith:(RCDChannelUserInfo *)userInfo
{
    self = [super init];
    if (self) {
        self.userInfo = userInfo;
    }
    return self;
}

- (void)changeUserStatus {
    if (!self.userInfo.userID) {
        return;
    }
    [RCDUltraGroupManager editUltraGroupMemberForWhiteList:self.userInfo.groupID
                                                 channelID:self.userInfo.channelID
                                                  isRemove:self.userInfo.isInWhiteList
                                                 memberIds:@[self.userInfo.userID]
                                                  complete:^(NSArray<NSString *> *memberIdList, BOOL result) {
        if (result) {
            [self refreshUI:result];
        }
    }];
}

- (void)refreshUI:(BOOL)success {
    if ([self.delegate respondsToSelector:@selector(channelUserInfoDidChanged:isSuccess:)]) {
        if (success) {
            self.userInfo.isInWhiteList = !self.userInfo.isInWhiteList;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate channelUserInfoDidChanged:self.userInfo isSuccess:success];
        });
    }
}
@end
