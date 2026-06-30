//
//  RCNDCleanHistoryCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCleanHistoryCellViewModel.h"
#import "RCNDCleanHistoryCell.h"

@interface RCNDCleanHistoryCellViewModel()
@property (nonatomic, weak) RCNDCleanHistoryCell *cell;
@end
@implementation RCNDCleanHistoryCellViewModel
- (instancetype)initWithConversation:(RCConversation *)conversation {
    self = [super initWithTapBlock:nil];
    if (self) {
        self.hideArrow = YES;
        self.conversation = conversation;
    }
    return self;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDCleanHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDCleanHistoryCellIdentifier
                                                                          forIndexPath:indexPath];
    cell.hideSeparatorLine = self.hideSeparatorLine;
    [self configureConversationInfoIfNeed];
    [cell updateWithViewModel:self];
    self.cell = cell;
    return cell;
}
- (void)configureConversationInfoIfNeed {
    if (self.title) {
        return;
    }
    if (self.conversation.conversationType == ConversationType_PRIVATE) {
        RCUserInfo *user = [[RCIM sharedRCIM] getUserInfoCache:self.conversation.targetId];
        self.title = user.name;
        self.imageURL = user.portraitUri;
    } else {
        RCGroup *group = [[RCIM sharedRCIM] getGroupInfoCache:self.conversation.targetId];
        self.title = group.groupName;
        self.imageURL = group.portraitUri;
    }
}
- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    self.selected = !self.selected;
    [self.cell refreshState:self];
}
@end
