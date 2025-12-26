//
//  RCNDSearchMoreViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMoreViewModel.h"
#import <RongIMKit/RongIMKit.h>
NSInteger const RCNDSearchMoreViewModelMaxCount = 50;
@interface RCNDSearchMoreViewModel()<RCSearchBarViewModelDelegate>
@property (nonatomic, strong) RCSearchBarViewModel *searchBarVM;

@end

@implementation RCNDSearchMoreViewModel

- (instancetype)initWithTitle:(NSString *)title
                      keyword:(NSString *)keyword
{
    self = [super init];
    if (self) {
        self.title = title;
        self.keyword = keyword;
    }
    return self;
}

- (void)ready {
    [super ready];
    self.searchBarVM = [RCSearchBarViewModel new];
    self.searchBarVM.delegate = self;
    self.dataSource = [NSMutableArray array];
}

- (UIView *)searchBar {
    return self.searchBarVM.searchBar;
}

- (void)endEditingState {
    [self.searchBarVM endEditingState];
    self.searchBarVM.searchBar.text = self.keyword;
}


- (void)loadMore:(void (^)(BOOL noMoreData))completion {
    [self loadMoreWithBlock:^(NSArray * _Nonnull array) {
        if (self.dataSource.count) {
            RCBaseCellViewModel *vm = self.dataSource.lastObject;
            vm.hideSeparatorLine = array.count>0;
        }
        [self.dataSource addObjectsFromArray:array];
        [self reloadData];
        
        if (completion) {
            completion(array.count == 0);
        }
    }];
}

- (void)loadMoreWithBlock:(void(^)(NSArray *array))completion {
    if (completion) {
        completion(@[]);
    }
}


- (void)fetchDataWithBlock:(void (^)(NSArray * _Nonnull))completion {
    NSAssert(NO, @"子类 %@ 必须重写类方法 +[%@ %@]！",
                NSStringFromClass([self class]),
                NSStringFromClass([self superclass]),
                NSStringFromSelector(_cmd));
}

- (void)reloadData {
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self removeSeparatorWitArray:self.dataSource];
        [self.delegate reloadData:self.dataSource.count == 0];
    }
}

- (void)removeSeparatorWitArray:(NSArray *)array {
    if (array.count) {
        [self removeSeparatorLineIfNeed:@[array]];
    }
}

- (void)fetchData:(void (^)(BOOL noMoreData))completion {
    [self fetchDataWithBlock:^(NSArray *array) {
        [self.dataSource addObjectsFromArray:array];
        [self reloadData];
        if (completion) {
            completion(array.count < RCNDSearchMoreViewModelMaxCount);
        }
    }];
}

#pragma mark - RCSearchBarViewModelDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.keyword = searchText;
    if (searchText.length == 0) {
        [self.dataSource removeAllObjects];
        [self reloadData];
    } else {
        [self fetchDataWithBlock:^(NSArray *array) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:array];
            [self reloadData];
        }];
    }
}

- (void)searchBar:(UISearchBar *)searchBar editingStateChanged:(BOOL)inSearching {
    if (!inSearching) {
        //        [self endEditingState];
    }
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count>0 ? 1 : 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return self.title;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    return 21;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}
@end
