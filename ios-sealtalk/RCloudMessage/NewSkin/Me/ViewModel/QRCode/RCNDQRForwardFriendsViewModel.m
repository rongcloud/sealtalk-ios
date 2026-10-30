//
//  RCNDQRForwardFriendsViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardFriendsViewModel.h"
#import "RCNDQRForwardCell.h"
#import "RCNDQRForwardFriendCellViewModel.h"

@implementation RCNDQRForwardFriendsViewModel

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDQRForwardCell class]
      forCellReuseIdentifier:RCNDQRForwardCellIdentifier];
}

- (void)ready {
    [super ready];
}

- (void)fetchData {
    [[RCCoreClient sharedCoreClient] getFriends:RCQueryFriendsDirectionTypeBoth
                                        success:^(NSArray<RCFriendInfo *> * _Nonnull friendInfos) {
        NSMutableArray *array = [NSMutableArray array];
        for (RCFriendInfo *info in friendInfos) {
            RCNDQRForwardFriendCellViewModel *vm = [[RCNDQRForwardFriendCellViewModel alloc] init];
            vm.info = info;
            [array addObject:vm];
        }
        self.dataSource = array;
    }
                                          error:^(RCErrorCode errorCode) {
       
    }];
}

- (void)reloadData {
    [self removeSeparatorLineIfNeed:self.dataSource];
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
        [self.forwardDelegate userDidSelectedForwardViewModel:(RCNDQRForwardFriendCellViewModel *)vm parentViewController:controller];
    }
}
@end
