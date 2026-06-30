//
//  RCNDSearchMoreConversationsViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMoreConversationsViewModel.h"
#import <RongIMKit/RongIMKit.h>
#import "RCNDSearchConversationCellViewModel.h"
#import "RCNDSearchConversationResultCell.h"

@interface RCNDSearchMoreConversationsViewModel()
@end

@implementation RCNDSearchMoreConversationsViewModel


- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDSearchConversationResultCell class]
      forCellReuseIdentifier:RCNDSearchConversationResultCellIdentifier];
}

- (void)fetchDataWithBlock:(void (^)(NSArray * _Nonnull))completion {
    NSArray *types = @[
        [RCTextMessage getObjectName],
        [RCRichContentMessage getObjectName],
        [RCFileMessage getObjectName]];
    __weak typeof(self) weakSelf = self;
    NSMutableArray *array = [NSMutableArray array];

    [[RCCoreClient sharedCoreClient] searchConversations:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP)]
                                             messageType:types keyword:self.keyword completion:^(NSArray<RCSearchConversationResult *> * _Nullable results) {
        for (int i = 0; i< results.count; i++) {
            
            RCSearchConversationResult *info = results[i];
            RCNDSearchConversationCellViewModel *vm = [[RCNDSearchConversationCellViewModel alloc] initWithConversationInfo:info keyword:self.keyword];
            [array addObject:vm];
        }
        if (completion) {
            completion(array);
        }
    }];
}


@end
