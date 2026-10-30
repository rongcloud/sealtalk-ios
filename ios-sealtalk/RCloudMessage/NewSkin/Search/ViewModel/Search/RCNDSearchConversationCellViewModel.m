//
//  RCNDSearchConversationCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchConversationCellViewModel.h"
#import "RCNDSearchConversationResultCell.h"
#import "RCUChatViewController.h"
#import "RCNDSearchMoreMessagesViewModel.h"
#import "RCNDSearchMoreViewController.h"

@implementation RCNDSearchConversationCellViewModel
- (instancetype)initWithConversationInfo:(RCSearchConversationResult *)info
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
    RCNDSearchConversationResultCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDSearchConversationResultCellIdentifier forIndexPath:indexPath];
    [cell updateWithViewModel:self];
    [self fetchDataInfoIfNeed];
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    if (self.info.matchCount == 1) {
        RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
        chatVC.conversationType = self.info.conversation.conversationType;
        chatVC.targetId = self.info.conversation.targetId;
        chatVC.locatedMessageSentTime = self.info.conversation.sentTime;
        chatVC.title = self.title;
        [vc.navigationController pushViewController:chatVC animated:YES];
    } else {
        NSString *title = [NSString stringWithFormat:RCDLocalizedString(@"total_related_message"), self.info.matchCount];
        RCNDSearchMoreMessagesViewModel *vm = [[RCNDSearchMoreMessagesViewModel alloc] initWithTitle:title
                                                                                             keyword:self.keyword conversation:self.info.conversation];
        RCNDSearchMoreViewController *chatVC = [[RCNDSearchMoreViewController alloc] initWithViewModel:vm];
        chatVC.title = self.title;
        [vc.navigationController pushViewController:chatVC animated:YES];
    }
   
}

- (void)fetchDataInfoIfNeed {
    if (self.title || !self.info.conversation.targetId) {
        return;
    }
    if (self.info.conversation.conversationType == ConversationType_PRIVATE) {
        [[RCCoreClient sharedCoreClient] getFriendsInfo:@[self.info.conversation.targetId] success:^(NSArray<RCFriendInfo *> * _Nonnull friendInfos) {
            if (friendInfos.count) {
                RCFriendInfo *info = [friendInfos firstObject];
                self.title = info.remark.length >0 ? info.remark : info.name;
                self.portraitURI = info.portraitUri;
                [self refreshCell];
            } else {
                [self fetchTitleFailed];
            }
           
        } error:^(RCErrorCode errorCode) {
            [self fetchTitleFailed];
        }];
    } else if (self.info.conversation.conversationType == ConversationType_GROUP) {
        [[RCCoreClient sharedCoreClient] getGroupsInfo:@[self.info.conversation.targetId] success:^(NSArray<RCGroupInfo *> * _Nonnull groupInfos) {
            if (groupInfos.count) {
                RCGroupInfo *info = groupInfos[0];
                self.title = info.remark.length > 0 ? info.remark : info.groupName;
                self.portraitURI = info.portraitUri;
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
    self.title = self.info.conversation.targetId;
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
    if (self.info.matchCount > 1) {
        string =  [NSString stringWithFormat:RCDLocalizedString(@"total_related_message"), self.info.matchCount];
        keyword = [@(self.info.matchCount) stringValue];
    } else {
        RCConversation *conversation = self.info.conversation;
        if ([conversation.lastestMessage isKindOfClass:[RCRichContentMessage class]]) {
            RCRichContentMessage *rich = (RCRichContentMessage *)conversation.lastestMessage;
            string = rich.title;
        } else if ([conversation.lastestMessage isKindOfClass:[RCFileMessage class]]) {
            RCFileMessage *file = (RCFileMessage *)conversation.lastestMessage;
            string = file.name;
        } else {
            string = [self formatMessage:conversation];
        }
        string = [self replaceEnterBySpace:string];
    }
    return [self attributedTextWith:string highlightedText:keyword];
}


- (NSString *)replaceEnterBySpace:(NSString *)originalString {
    NSString *string = [originalString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    return string;
}

- (NSString *)formatMessage:(RCConversation *)conversation{
    if (RCKitConfigCenter.message.showUnkownMessage && conversation.lastestMessageId > 0 && !conversation.lastestMessage) {
        return RCLocalizedString(@"unknown_message_cell_tip");
    } else {
        return [RCKitUtility formatMessage:conversation.lastestMessage targetId:conversation.targetId conversationType:conversation.conversationType isAllMessage:YES];
    }
}

- (NSMutableAttributedString *)subtitle {
    if (!_subtitle) {
        _subtitle = [self createSubtitle];
    }
    return _subtitle;
}

@end
