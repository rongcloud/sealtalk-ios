//
//  RCNDSearchMessageCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMessageCellViewModel.h"
#import "RCNDSearchMessageCell.h"
#import "RCUChatViewController.h"

@implementation RCNDSearchMessageCellViewModel
- (instancetype)initWithMessageInfo:(RCMessage *)info
                            keyword:(NSString *)keyword
{
    self = [super init];
    if (self) {
        self.info = info;
        self.keyword = keyword;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDSearchMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDSearchMessageCellIdentifier forIndexPath:indexPath];
    [cell updateWithViewModel:self];
    [self fetchDataInfoIfNeed];
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.conversationType = self.info.conversationType;
    chatVC.targetId = self.info.targetId;
    chatVC.title = self.title;
    chatVC.locatedMessageSentTime = self.info.sentTime;
    [vc.navigationController pushViewController:chatVC animated:YES];
}

- (void)fetchDataInfoIfNeed {
    if (self.title) {
        return;
    }
    if (self.info.conversationType == ConversationType_PRIVATE) {
        [[RCCoreClient sharedCoreClient] getFriendsInfo:@[self.info.targetId] success:^(NSArray<RCFriendInfo *> * _Nonnull friendInfos) {
            if (friendInfos.count) {
                RCFriendInfo *info = [friendInfos firstObject];
                self.title = info.remark.length >0 ? info.remark : info.name;
                self.portraitURI = info.portraitUri;
                self.subtitle = [self createSubtitle];
                [self refreshCell];
            } else {
                [self fetchTitleFailed];
            }
           
        } error:^(RCErrorCode errorCode) {
            [self fetchTitleFailed];
        }];
    } else if (self.info.conversationType == ConversationType_GROUP) {
        RCPagingQueryOption *opt = [RCPagingQueryOption new];
        opt.count = 1;
        [[RCCoreClient sharedCoreClient] getGroupMembers:self.info.targetId userIds:@[self.info.senderUserId] success:^(NSArray<RCGroupMemberInfo *> * _Nonnull groupMembers) {
            if (groupMembers.count) {
                RCGroupMemberInfo *info = groupMembers[0];
                self.title =  info.name;
                self.portraitURI = info.portraitUri;
                self.subtitle = [self createSubtitle];
                [self refreshCell];
            } else {
                [self fetchTitleFailed];
            }
        } error:^(RCErrorCode errorCode) {
            [self fetchTitleFailed];
        }];
         
    } else {
        [self fetchTitleFailed];
    }
}

- (void)fetchTitleFailed {
    self.title = self.info.targetId;
    [self refreshCell];
}

- (void)refreshCell {
    if ([self.cellDelegate respondsToSelector:@selector(refreshCellWith:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cellDelegate refreshCellWith:self];
        });
    }
}

- (NSMutableAttributedString *)createSubtitle {
    NSString *string = nil;
    NSString *keyword = self.keyword;
        RCMessageContent *content = self.info.content;
        if ([content isKindOfClass:[RCRichContentMessage class]]) {
            RCRichContentMessage *rich = (RCRichContentMessage *)content;
            string = rich.title;
        } else if ([content isKindOfClass:[RCFileMessage class]]) {
            RCFileMessage *file = (RCFileMessage *)content;
            string = file.name;
        } else {
            string = [self formatMessage:self.info];
        }
        string = [self replaceEnterBySpace:string];
    return [self attributedTextWith:string highlightedText:keyword];
}


- (NSString *)replaceEnterBySpace:(NSString *)originalString {
    NSString *string = [originalString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    return string;
}

- (NSString *)formatMessage:(RCMessage *)msg{
        return [RCKitUtility formatMessage:msg.content targetId:msg.targetId conversationType:msg.conversationType isAllMessage:YES];
}

- (NSString *)timeString {
    if (!_timeString) {
        _timeString = [RCKitUtility convertConversationTime:self.info.sentTime / 1000];
    }
    return _timeString;
}
@end

