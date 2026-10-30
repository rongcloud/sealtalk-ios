//
//  RCNDQRForwardGroupsViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardGroupsViewModel.h"
#import "RCNDQRForwardCell.h"
#import "RCNDQRForwardGroupCellViewModel.h"

@interface RCNDQRForwardGroupsViewModel()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) RCPagingQueryOption *option;
@end

@implementation RCNDQRForwardGroupsViewModel

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDQRForwardCell class]
      forCellReuseIdentifier:RCNDQRForwardCellIdentifier];
}

- (void)ready {
    [super ready];
    self.dataSource = [NSMutableArray array];
}

/// 获取数据
- (void)fetchData:(void(^)(BOOL noMoreData))completion {
    if (!self.option) {
        RCPagingQueryOption *opt = [[RCPagingQueryOption alloc] init];
        opt.count = 50;
        self.option = opt;
    }
    [self.dataSource removeAllObjects];
    [self fetchDataWithOption:self.option completion:completion];
}

- (void)loadMore:(void(^)(BOOL noMoreData))completion {
    [self fetchDataWithOption:self.option completion:completion];
}

- (void)fetchDataWithOption:(RCPagingQueryOption *)option completion:(void(^)(BOOL noMoreData))completion{
    self.option = option;
    [[RCCoreClient sharedCoreClient] getJoinedGroupsByRole:RCGroupMemberRoleUndef option:option success:^(RCPagingQueryResult<RCGroupInfo *> * _Nonnull result) {
        if (result.pageToken.length != 0) {
            self.option.pageToken = result.pageToken;
        }
        NSArray *infos = result.data;
        NSMutableArray *array = [NSMutableArray array];
        for (RCGroupInfo *info in infos) {
            RCNDQRForwardGroupCellViewModel *vm = [[RCNDQRForwardGroupCellViewModel alloc] init];
            vm.info = info;
            [array addObject:vm];
        }
        [self.dataSource addObjectsFromArray:array];
        if (self.dataSource.count) {
            RCNDQRForwardGroupCellViewModel *vm = [self.dataSource lastObject];
            vm.hideSeparatorLine = NO;
        }
        [self reloadData];
        if (completion) {
            completion(result.pageToken.length == 0);
        }
    } error:^(RCErrorCode errorCode) {
        if (completion) {
            completion(YES);
        }
    }];
  
}

- (void)reloadData {
    [self removeSeparatorLineIfNeed:@[self.dataSource]];
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath viewController:(UIViewController *)controller {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath viewController:controller];
    if ([self.forwardDelegate respondsToSelector:@selector(userDidSelectedForwardViewModel:parentViewController:)]) {
        RCNDBaseCellViewModel *vm = [self cellViewModelAtIndexPath:indexPath];
        [self.forwardDelegate userDidSelectedForwardViewModel:(RCNDQRForwardGroupCellViewModel *)vm parentViewController:controller];
    }
}
@end
