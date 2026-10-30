//
//  RCNDSearchMoreMessagesViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMoreMessagesViewModel.h"
#import "RCNDSearchMessageCell.h"
#import "RCNDSearchMessageCellViewModel.h"

@interface RCNDSearchMoreMessagesViewModel()
@property (nonatomic, strong) RCConversation *conversation;
@end
@implementation RCNDSearchMoreMessagesViewModel

- (instancetype)initWithTitle:(NSString *)title
                      keyword:(NSString *)keyword
                 conversation:(RCConversation *)conversation {
    self = [super initWithTitle:title keyword:keyword];
    if (self) {
        self.conversation = conversation;
    }
    return self;
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDSearchMessageCell class]
      forCellReuseIdentifier:RCNDSearchMessageCellIdentifier];
}

- (void)fetchDataWithBlock:(void (^)(NSArray * _Nonnull))completion {
    [[RCCoreClient sharedCoreClient] searchMessages:self.conversation.conversationType
                                           targetId:self.conversation.targetId
                                            keyword:self.keyword
                                              count:(int)RCNDSearchMoreViewModelMaxCount
                                          startTime:0 completion:^(NSArray<RCMessage *> * _Nullable messages) {
        NSMutableArray *array = [NSMutableArray array];
        for (RCMessage *msg in messages) {
            RCNDSearchMessageCellViewModel *vm = [[RCNDSearchMessageCellViewModel alloc] initWithMessageInfo:msg keyword:self.keyword];
            [array addObject:vm];
        }
        if (completion) {
            completion(array);
        }
    }];
}

- (void)reloadData {
    self.title = [NSString stringWithFormat:RCDLocalizedString(@"total_related_message"), self.dataSource.count];
    [super reloadData];
}

- (void)loadMoreWithBlock:(void(^)(NSArray *array))completion {
    NSInteger startTime = 0;
    if (self.dataSource.count) {
        RCNDSearchMessageCellViewModel *vm = self.dataSource.lastObject;
        startTime = vm.info.sentTime;
    }
    [[RCCoreClient sharedCoreClient] searchMessages:self.conversation.conversationType
                                           targetId:self.conversation.targetId
                                            keyword:self.keyword
                                              count:(int)RCNDSearchMoreViewModelMaxCount
                                          startTime:startTime completion:^(NSArray<RCMessage *> * _Nullable messages) {
        NSMutableArray *array = [NSMutableArray array];
        for (RCMessage *msg in messages) {
            RCNDSearchMessageCellViewModel *vm = [[RCNDSearchMessageCellViewModel alloc] initWithMessageInfo:msg keyword:self.keyword];
            [array addObject:vm];
        }
        if (completion) {
            completion(array);
        }
    }];
}

@end
