//
//  RCNDCleanHistoryViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCleanHistoryViewModel.h"
#import "RCNDCleanHistoryCellViewModel.h"

@interface RCNDCleanHistoryViewModel()

@property (nonatomic, assign) BOOL selectedAll;

@end

@implementation RCNDCleanHistoryViewModel

- (void)ready {
    [super ready];
    self.dataSource = [NSMutableArray array];
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDCleanHistoryCell class]
      forCellReuseIdentifier:RCNDCleanHistoryCellIdentifier];
}
/// 获取数据
- (void)fetchAllData {
    NSArray *conversations =
        [[RCCoreClient sharedCoreClient] getConversationList:@[ @(ConversationType_PRIVATE), @(ConversationType_GROUP),@(ConversationType_APPSERVICE),@(ConversationType_PUBLICSERVICE),@(ConversationType_SYSTEM) ]];
    NSMutableArray *dealWithArray = [NSMutableArray array];
    for (RCConversation *conversation in conversations) {
        if (![conversation.targetId isEqualToString:RCDGroupNoticeTargetId]) {
            RCNDCleanHistoryCellViewModel *vm = [[RCNDCleanHistoryCellViewModel alloc] initWithConversation:conversation];
            [dealWithArray addObject:vm];
        }
    }
    [self.dataSource addObjectsFromArray:dealWithArray];
    [self reloadData];
}
   
- (void)reloadData {
    [self removeSeparatorLineIfNeed:@[self.dataSource]];
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:self.dataSource.count == 0];
    }
}
- (NSInteger)changeAllConversationsStatus {
    self.selectedAll = !self.selectedAll;
    for (RCNDCleanHistoryCellViewModel *vm  in self.dataSource) {
        vm.selected = self.selectedAll;
    }
    [self reloadData];
    return self.selectedAll ? self.dataSource.count : 0;
}


- (NSInteger)numberOfConversationSelected {
    NSInteger count = 0;
    for (RCNDCleanHistoryCellViewModel *vm  in self.dataSource) {
        if (vm.selected) {
            count++;
        }
    }
    return count;
}

- (void)cleanHistoryOfConversationSelected:(void(^)(BOOL))completion {
    NSArray *array = [self.dataSource copy];
    NSMutableArray *tmp = [NSMutableArray array];
    for (RCNDCleanHistoryCellViewModel *vm in array) {
        if (vm.selected) {
            [tmp addObject:vm];
        }
        [[RCCoreClient sharedCoreClient] clearMessages:vm.conversation.conversationType targetId:vm.conversation.targetId];
        [[RCCoreClient sharedCoreClient] removeConversation:vm.conversation.conversationType targetId:vm.conversation.targetId];
    }
    [self.dataSource removeObjectsInArray:tmp];
    [self reloadData];
    if (completion) {
        completion(YES);
    }
}


- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (RCBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
   return self.dataSource[indexPath.row];
}
@end
