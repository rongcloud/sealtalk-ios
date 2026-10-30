//
//  RCNDSearchContext.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchContext.h"
#import <RongIMKit/RongIMKit.h>
#import "RCNDSearchMoreConversationsViewModel.h"
#import "RCNDSearchMoreGroupsViewModel.h"
#import "RCNDSearchMoreFriendsViewModel.h"
#import "RCNDSearchMoreViewController.h"

NSInteger const RCNDSearchContextTasksCount = 3;

@implementation RCNDSearchResult

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray array];
    }
    return self;
}

@end

@interface RCNDSearchContext()
@property (nonatomic, strong) NSConditionLock *conditionLock; // 条件锁（值=完成的方法数）
@property (nonatomic, copy) void(^completionBlock)(void);
@property (nonatomic, assign) BOOL stopped;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableArray <RCNDSearchResult *>*items;
@property (nonatomic, strong) NSArray *sectionIndexTitles;
@end




@implementation RCNDSearchContext

- (instancetype)initWithKeyword:(NSString *)keyword
                     completion:(void(^)(void))completion
{
    self = [super init];
    if (self) {
        self.keyword = keyword;
        self.conditionLock = [[NSConditionLock alloc] initWithCondition:0];
        self.completionBlock = completion;
        self.lock = [NSLock new];
        self.items = [NSMutableArray array];
    }
    return self;
}

- (void)tasksResume {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self consumeWhenAllTasksDone];
    });
    [self searchFriendsByKeyword:self.keyword];
    [self searchGroupJoinedByKeyword:self.keyword];
    [self searchConversationByKeyword:self.keyword];
}

- (void)tasksInvalid {
//    [self.lock lock];
    self.stopped = YES;
//    [self.lock unlock];
}

- (NSInteger)numberOfSections {
    return self.sectionIndexTitles.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    RCNDSearchResult *result = self.dataSource[section];
    return result.items.count;

}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return self.sectionIndexTitles[section];
}


- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    RCNDSearchResult *result = self.dataSource[indexPath.section];
    return result.items[indexPath.row];
}


#pragma mark - Producer And Consumer

// 通用方法：执行任务后，条件值+1
- (void)completeTaskWithName:(NSString *)taskName result:(RCNDSearchResult *)result {
    // 1. 无条件加锁（修改条件值必须加锁）
    [self.conditionLock lock];
    
    // 2. 获取当前条件值（已完成的方法数），+1
    NSInteger currentCondition = self.conditionLock.condition;
    NSInteger newCondition = currentCondition + 1;
    NSLog(@"[任务%@] 执行完成，当前完成数：%ld → %ld", taskName, currentCondition, newCondition);
    if (result.items.count) {
        RCNDBaseCellViewModel *vm = [result.items lastObject];
        vm.hideSeparatorLine = YES;
        [self.items addObject:result];
    }
    // 3. 解锁并设置新的条件值（唤醒等待该值的线程）
    [self.conditionLock unlockWithCondition:newCondition];
}


// 消费方法：仅当条件值=4时执行
- (void)consumeWhenAllTasksDone {
    NSLog(@"[消费者] 等待3个任务全部完成...");
    // 4. 等待条件值=4时加锁（阻塞直到满足条件）
    [self.conditionLock lockWhenCondition:RCNDSearchContextTasksCount];
    
   
    [self.lock lock];
    if (!self.stopped) {
        // 5. 执行消费逻辑
        NSLog(@"[消费者] 3个任务全部完成，开始消费！");
        self.dataSource = [self.items sortedArrayUsingComparator:^NSComparisonResult(RCNDSearchResult *  _Nonnull obj1, RCNDSearchResult *  _Nonnull obj2) {
            return obj1.index > obj2.index;;
        }];
        NSMutableArray *titles = [NSMutableArray array];
        for (RCNDSearchResult * obj in self.dataSource) {
            [titles addObject:obj.title];
        }
        self.sectionIndexTitles = titles;
        if (self.completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock();
            });
        }
    }
    [self.lock unlock];
    // 6. 解锁（可重置条件值，也可保持4）
    [self.conditionLock unlock]; // 若需重复使用，可解锁并设为0：unlockWithCondition:0
}

#pragma mark - Search
- (void)searchFriendsByKeyword:(NSString *)key {
    RCNDSearchResult *result =  [RCNDSearchResult new];
    result.index = 0;
    result.title = RCDLocalizedString(@"good_friend");
    if (key.length == 0) {
        [self completeTaskWithName:@"searchFriendsByKeyword" result:result];
        return;
    }
    __weak typeof(self) weakSelf = self;

    [[RCCoreClient sharedCoreClient] searchFriendsInfo:key success:^(NSArray<RCFriendInfo *> * _Nonnull friendInfos) {
        for (int i = 0; i<friendInfos.count; i++) {
            if (i == 3) {
                RCNDSearchMoreCellViewModel *more = [[RCNDSearchMoreCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
                    RCNDSearchMoreFriendsViewModel *vm = [[RCNDSearchMoreFriendsViewModel alloc] initWithTitle:RCDLocalizedString(@"good_friend") keyword:self.keyword];
                    RCNDSearchMoreViewController *controller = [[RCNDSearchMoreViewController alloc] initWithViewModel:vm];
                    [weakSelf pushViewController:controller byController:vc];
                }];
                more.title = [NSString stringWithFormat:RCDLocalizedString(@"see_more"),RCDLocalizedString(@"good_friend")];
                [result.items addObject:more];
                break;
            }
            RCFriendInfo *info = friendInfos[i];
            RCNDSearchFriendCellViewModel *vm = [[RCNDSearchFriendCellViewModel alloc] initWithFriendInfo:info keyword:key];
            [result.items addObject:vm];
            
        }
        [self completeTaskWithName:@"searchFriendsByKeyword" result:result];
    } error:^(RCErrorCode errorCode) {
        [self completeTaskWithName:@"searchFriendsByKeyword" result:result];
        
    }];
}

- (void)searchGroupJoinedByKeyword:(NSString *)key {
    RCNDSearchResult *result =  [RCNDSearchResult new];
    result.index = 1;
    result.title = RCDLocalizedString(@"group");
    
    if (key.length == 0) {
        [self completeTaskWithName:@"searchGroupJoinedByKeyword" result:result];
        return;
    }
    RCPagingQueryOption *opt = [RCPagingQueryOption new];
    opt.count = 4;
    __weak typeof(self) weakSelf = self;

    [[RCCoreClient sharedCoreClient] searchJoinedGroups:key option:opt success:^(RCPagingQueryResult<RCGroupInfo *> * _Nonnull groupInfos) {
        for (int i = 0; i< groupInfos.data.count; i++) {
            if (i == 3) {
                RCNDSearchMoreCellViewModel *more = [[RCNDSearchMoreCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
                    RCNDSearchMoreGroupsViewModel *vm = [[RCNDSearchMoreGroupsViewModel alloc] initWithTitle:RCDLocalizedString(@"group") keyword:self.keyword];
                    RCNDSearchMoreViewController *controller = [[RCNDSearchMoreViewController alloc] initWithViewModel:vm];
                    [weakSelf pushViewController:controller byController:vc];
                }];
                more.title = [NSString stringWithFormat:RCDLocalizedString(@"see_more"),RCDLocalizedString(@"group")];
                [result.items addObject:more];
                break;
            }
            RCGroupInfo *info = groupInfos.data[i];
            RCNDSearchGroupCellViewModel *vm = [[RCNDSearchGroupCellViewModel alloc] initWithGroupInfo:info keyword:key];
            [result.items addObject:vm];
            
        }
        [self completeTaskWithName:@"searchGroupJoinedByKeyword" result:result];
    } error:^(RCErrorCode errorCode) {
        [self completeTaskWithName:@"searchGroupJoinedByKeyword" result:result];
    }];
}

- (void)searchConversationByKeyword:(NSString *)key {
    RCNDSearchResult *result =  [RCNDSearchResult new];
    result.index = 2;
    result.title = RCDLocalizedString(@"chat_history");
    
    if (key.length == 0) {
        [self completeTaskWithName:@"searchGroupJoinedByKeyword" result:result];
        return;
    }
    NSArray *types = @[
        [RCTextMessage getObjectName],
        [RCRichContentMessage getObjectName],
        [RCFileMessage getObjectName]];
    __weak typeof(self) weakSelf = self;

    [[RCCoreClient sharedCoreClient] searchConversations:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP)]
                                             messageType:types keyword:key completion:^(NSArray<RCSearchConversationResult *> * _Nullable results) {
        for (int i = 0; i< results.count; i++) {
            if (i == 3) {
                RCNDSearchMoreCellViewModel *more = [[RCNDSearchMoreCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
                    RCNDSearchMoreConversationsViewModel *vm = [[RCNDSearchMoreConversationsViewModel alloc] initWithTitle:RCDLocalizedString(@"chat_history") keyword:self.keyword];
                    RCNDSearchMoreViewController *controller = [[RCNDSearchMoreViewController alloc] initWithViewModel:vm];
                    [weakSelf pushViewController:controller byController:vc];
                }];
                more.title = [NSString stringWithFormat:RCDLocalizedString(@"see_more"),RCDLocalizedString(@"chat_history")];
                [result.items addObject:more];
                break;
            }
            RCSearchConversationResult *info = results[i];
            RCNDSearchConversationCellViewModel *vm = [[RCNDSearchConversationCellViewModel alloc] initWithConversationInfo:info keyword:key];
            [result.items addObject:vm];
        }
        [self completeTaskWithName:@"searchConversationByKeyword" result:result];
    }];
}

- (void)pushViewController:(UIViewController *)vc  byController:(UIViewController *)controller {
    [controller.navigationController pushViewController:vc animated:YES];
}
@end
