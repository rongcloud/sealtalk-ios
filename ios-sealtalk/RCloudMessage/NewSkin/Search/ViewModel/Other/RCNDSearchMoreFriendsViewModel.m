//
//  RCNDSearchMoreFriendsViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMoreFriendsViewModel.h"
#import "RCNDSearchFriendCellViewModel.h"
#import "RCNDSearchFriendResultCell.h"

@implementation RCNDSearchMoreFriendsViewModel

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDSearchFriendResultCell class] forCellReuseIdentifier:RCNDSearchFriendResultCellIdentifier];
}


- (void)fetchDataWithBlock:(void (^)(NSArray * _Nonnull))completion {
    [[RCCoreClient sharedCoreClient] searchFriendsInfo:self.keyword success:^(NSArray<RCFriendInfo *> * _Nonnull friendInfos) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i<friendInfos.count; i++) {
            RCFriendInfo *info = friendInfos[i];
            RCNDSearchFriendCellViewModel *vm = [[RCNDSearchFriendCellViewModel alloc] initWithFriendInfo:info keyword:self.keyword];
            [array addObject:vm];
            if (completion) {
                completion(array);
            }
        }
    } error:^(RCErrorCode errorCode) {
        if (completion) {
            completion(@[]);
        }
    }];
}
@end
