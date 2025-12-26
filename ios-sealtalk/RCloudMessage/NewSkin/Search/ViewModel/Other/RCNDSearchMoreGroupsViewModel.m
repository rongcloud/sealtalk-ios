//
//  RCNDSearchMoreGroupsViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMoreGroupsViewModel.h"
#import "RCNDSearchGroupCellViewModel.h"
#import "RCNDSearchGroupResultCell.h"

@interface RCNDSearchMoreGroupsViewModel()
@property (nonatomic, strong)RCPagingQueryOption *opt;

@end

@implementation RCNDSearchMoreGroupsViewModel

- (instancetype)initWithTitle:(NSString *)title keyword:(NSString *)keyword {
    self = [super initWithTitle:title keyword:keyword];
    if (self) {
        self.opt = [RCPagingQueryOption new];
        self.opt.count = RCNDSearchMoreViewModelMaxCount;
    }
    return self;
}
- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDSearchGroupResultCell class] forCellReuseIdentifier:RCNDSearchGroupResultCellIdentifier];
}

- (void)loadMoreWithBlock:(void(^)(NSArray *array))completion {
    NSMutableArray *array = [NSMutableArray array];
    [[RCCoreClient sharedCoreClient] searchJoinedGroups:self.keyword option:self.opt success:^(RCPagingQueryResult<RCGroupInfo *> * _Nonnull groupInfos) {
        if (groupInfos.pageToken.length != 0) {
            self.opt.pageToken = groupInfos.pageToken;
        }
        for (int i = 0; i< groupInfos.data.count; i++) {
            RCGroupInfo *info = groupInfos.data[i];
            RCNDSearchGroupCellViewModel *vm = [[RCNDSearchGroupCellViewModel alloc] initWithGroupInfo:info keyword:self.keyword];
            [array addObject:vm];
            
        }
        if (completion) {
            completion(array);
        }
    } error:^(RCErrorCode errorCode) {
        if (completion) {
            completion(array);
        }
    }];
}

- (void)fetchDataWithBlock:(void (^)(NSArray * _Nonnull))completion {
    self.opt.pageToken = nil;
    [self loadMoreWithBlock:completion];
}
@end
