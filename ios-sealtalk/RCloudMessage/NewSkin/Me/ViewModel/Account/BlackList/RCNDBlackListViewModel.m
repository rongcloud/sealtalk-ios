//
//  RCNDBlackListViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBlackListViewModel.h"
#import "RCDUserInfoManager.h"
#import "RCNDMemberRemoveCellViewModel.h"
#import "RCDRCIMDataSource.h"

@interface RCNDBlackListViewModel()<RCSearchBarViewModelDelegate>
@property (nonatomic, strong) RCSearchBarViewModel *searchBarVM;
@property (nonatomic, strong) NSMutableArray *matchedMembers;
@property (nonatomic, strong) NSMutableArray *allMembers;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, weak) RCNDBaseCellViewModel *lastCellVM;
@end

@implementation RCNDBlackListViewModel
- (void)ready {
    [super ready];
    self.searchBarVM = [RCSearchBarViewModel new];
    self.searchBarVM.delegate = self;
    self.allMembers = [NSMutableArray array];
    self.matchedMembers = [NSMutableArray array];
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDMemberRemoveCell class] forCellReuseIdentifier:RCNDMemberRemoveCellIdentifier];
}


- (UIView *)searchBar {
    return self.searchBarVM.searchBar;
}

- (void)endEditingState {
    [self.matchedMembers removeAllObjects];
    [self.searchBarVM endEditingState];
    [self reloadData];
}

- (void)fetchAllData {
    [self.allMembers removeAllObjects];
    [RCDUserInfoManager getBlacklistFromServer:^(NSArray<NSString *> *blackUserIds) {
        if (!blackUserIds) {
            blackUserIds = [RCDUserInfoManager getBlacklist];
        }

        NSMutableArray *blacklist = [[NSMutableArray alloc] init];
        __weak typeof(self) weakSelf = self;

        for (NSString *userId in blackUserIds) {
            RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:userId];
            RCNDMemberRemoveCellViewModel *vm = [[RCNDMemberRemoveCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
                [weakSelf removeUser:userId];
            }];
            vm.title = userInfo.name;
            vm.imageURL = userInfo.portraitUri;
            vm.userID = userId;
            [blacklist addObject:vm];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.allMembers addObjectsFromArray:blacklist];
            [self filterMembersWithKey:self.searchBarVM.searchBar.text];
            [self reloadData];
        });
        
    }];
}

- (void)removeUser:(NSString *)userID {
    NSArray *tmp = [self.allMembers copy];
    for (RCNDMemberRemoveCellViewModel *vm in tmp) {
        if ([vm.userID isEqualToString:userID]) {
            [self.allMembers removeObject:vm];
            if ([self.matchedMembers containsObject:vm]) {
                [self.matchedMembers removeObject:vm];
            }
        }
    }
    [self reloadData];
}

- (void)filterMembersWithKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    NSString *pre = [NSString stringWithFormat:@"title CONTAINS '%@'",key];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pre];
    NSArray *array = [self.allMembers filteredArrayUsingPredicate:predicate];
    [self.matchedMembers addObjectsFromArray:array];
}

- (void)reloadData {
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self removeSeparatorWitArray:self.members];

        [self.delegate reloadData:self.members.count == 0];
    }
}

- (void)removeSeparatorWitArray:(NSArray *)array {
    if (self.lastCellVM) {
        self.lastCellVM.hideSeparatorLine = NO;
    }
    if (array.count) {
        [self removeSeparatorLineIfNeed:@[array]];
    }
    self.lastCellVM = array.lastObject;
}

#pragma mark - RCSearchBarViewModelDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.matchedMembers removeAllObjects];
    if (searchText.length == 0) {
        [self removeSeparatorWitArray:self.allMembers];
    } else {
        [self filterMembersWithKey:self.searchBarVM.searchBar.text];
        [self removeSeparatorWitArray:self.matchedMembers];

    }
    [self reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar editingStateChanged:(BOOL)inSearching {
    if (!inSearching) {
        [self endEditingState];
    }
    [self removeSeparatorWitArray:self.allMembers];
//    [self reloadData];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.members[indexPath.row];
}

- (NSArray *)members {
    if (self.searchBarVM.searchBar.text.length > 0) {
        return self.matchedMembers;
    }
    return self.allMembers;
}
@end
