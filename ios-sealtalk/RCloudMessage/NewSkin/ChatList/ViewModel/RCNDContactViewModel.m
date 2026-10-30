//
//  RCNDContactViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDContactViewModel.h"
#import "RCNDContactCell.h"
#import "RCDUtilities.h"


@interface RCNDContactViewModel()<RCSearchBarViewModelDelegate>

@property (nonatomic, strong) RCSearchBarViewModel *searchBarVM;

// 全部cell
@property (nonatomic, strong) NSArray *dataSource;
// 索引
@property (nonatomic, strong) NSArray *indexTitles;
// 分组cell
@property (nonatomic, strong) NSDictionary *dicInfo;

@property (nonatomic, strong) RCNDContactCellViewModel *currentCellViewModel;
@end

@implementation RCNDContactViewModel

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDContactCell class]
      forCellReuseIdentifier:RCNDContactCellIdentifier];
}

- (void)ready {
    [super ready];
}

- (void)fetchData {
    [[RCCoreClient sharedCoreClient] getFriends:RCQueryFriendsDirectionTypeBoth
                                        success:^(NSArray<RCFriendInfo *> * _Nonnull friendInfos) {
        NSMutableArray *array = [NSMutableArray array];
        for (RCFriendInfo *info in friendInfos) {
            RCNDContactCellViewModel *vm = [[RCNDContactCellViewModel alloc] initWithFriendInfo:info];
            [array addObject:vm];
        }
        self.dataSource = array;
        [self groupAndReloadItemsInArray:array];
    }
                                          error:^(RCErrorCode errorCode) {
       
    }];
}

- (void)groupAndReloadItemsInArray:(NSArray *)array {
    for (RCNDContactCellViewModel *obj in array) {
        obj.hideSeparatorLine = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // 数据源分组
        self.dicInfo = [RCDUtilities sortedWithPinYinArray:array
                                                  usingBlock:^NSString * _Nonnull(RCNDContactCellViewModel * obj, NSUInteger idx) {
            return obj.displayName;
        }];
        // 索引排序
        self.indexTitles = [[self.dicInfo allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 isKindOfClass:[NSString class]]&&[obj2 isKindOfClass:[NSString class]]) {
                NSString *key1 = (NSString *)obj1;
                NSString *key2 = (NSString *)obj2;
                if ([key1 isEqualToString:@"#"]) {
                    if ([key2 isEqualToString:@"#"]) {
                        return NSOrderedSame;
                    }
                    return NSOrderedDescending;
                } else if ([key2 isEqualToString:@"#"]) {
                    return NSOrderedAscending;
                }
            }
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        NSArray *allFriends = [self.dicInfo allValues];
        [self removeSeparatorLineIfNeed:allFriends];
        // 通知vc 刷新列表
        [self reloadData];
    });
}

- (void)filterDataSourceWithKeyword:(NSString *)keyword {
    if (keyword.length == 0) {
        return;
    }

    NSString *pre = [NSString stringWithFormat:@"self.displayName CONTAINS '%@'",keyword];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pre];
    NSArray *array = [self.dataSource filteredArrayUsingPredicate:predicate];
    [self groupAndReloadItemsInArray:array];
}

- (void)restoreData {
    [self groupAndReloadItemsInArray:self.dataSource];
}

- (void)reloadData {
    [self removeSeparatorLineIfNeed:[self.dicInfo allValues]];
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.indexTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.sectionIndexTitles[section] ;
    NSArray *array = self.dicInfo[key];
    return array.count;
}


- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.sectionIndexTitles[indexPath.section] ;
    NSArray *array = self.dicInfo[key];
    return array[indexPath.row];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath viewController:(UIViewController *)controller {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath viewController:controller];
    RCNDBaseCellViewModel *vm = [self cellViewModelAtIndexPath:indexPath];
    if (self.currentCellViewModel != vm) {
        [self.currentCellViewModel cellViewModelUnselected];
    }
    self.currentCellViewModel = (RCNDContactCellViewModel*)vm;
}
#pragma mark - SearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self restoreData];
    } else {
        [self filterDataSourceWithKeyword:searchText];
    }
}

- (void)searchBar:(UISearchBar *)searchBar editingStateChanged:(BOOL)inSearching {
    if (inSearching) {
        [self reloadData];
    } else {
        [self restoreData];
    }
}

#pragma mark - Public

- (NSArray *)sectionIndexTitles {
    return self.indexTitles;
}
- (void)endEditingState {
    [self.searchBarVM.searchBar resignFirstResponder];
//    [self restoreData];
}

- (RCSearchBarViewModel *)searchBarVM {
    if (!_searchBarVM) {
        RCSearchBarViewModel *vm = [[RCSearchBarViewModel alloc] init];
        vm.delegate = self;
        _searchBarVM = vm;
    }
    return _searchBarVM;
}

- (UIView *)searchBarView {
    return self.searchBarVM.searchBar;
}

- (RCNDContactCellViewModel *)currentContactCellViewModel {
    return self.currentCellViewModel;
}
@end
