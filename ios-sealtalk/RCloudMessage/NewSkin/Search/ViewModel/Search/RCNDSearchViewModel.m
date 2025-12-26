//
//  RCNDSearchViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/28.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchViewModel.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDSearchDataManager.h"
#import "RCNDSearchConversationResultCell.h"
#import "RCNDSearchGroupResultCell.h"
#import "RCNDSearchFriendResultCell.h"
#import "RCNDSearchContext.h"


@interface RCNDSearchViewModel()<RCSearchBarViewModelDelegate>
@property (nonatomic, strong) RCSearchBarViewModel *searchBarVM;
@property (nonatomic, strong) RCNDSearchContext *context;
@property (nonatomic, copy) NSString *keyword;
@end

@implementation RCNDSearchViewModel
- (void)ready {
    [super ready];
    self.searchBarVM = [RCSearchBarViewModel new];
    self.searchBarVM.delegate = self;
}

- (void)becomeFirstResponder {
    [self.searchBarVM.searchBar becomeFirstResponder];
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDSearchConversationResultCell class] forCellReuseIdentifier:RCNDSearchConversationResultCellIdentifier];
    [tableView registerClass:[RCNDSearchGroupResultCell class] forCellReuseIdentifier:RCNDSearchGroupResultCellIdentifier];
    [tableView registerClass:[RCNDSearchFriendResultCell class] forCellReuseIdentifier:RCNDSearchFriendResultCellIdentifier];
    [tableView registerClass:[RCNDCommonCell class] forCellReuseIdentifier:RCNDCommonCellIdentifier];
    
}


- (UIView *)searchBar {
    return self.searchBarVM.searchBar;
}

- (void)endEditingState {
    [self.searchBarVM endEditingState];
    self.searchBarVM.searchBar.text = self.keyword;

//    [self reloadData];
}

- (void)reloadData {
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        NSInteger count = [self.context numberOfSections];
        [self.delegate reloadData:count == 0];
    }
}

#pragma mark - RCSearchBarViewModelDelegate
- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    self.keyword = searchText;
    [self.context tasksInvalid];
    self.context = nil;
    __weak typeof(self) weakSelf = self;
    if (searchText.length == 0) {
        self.context = nil;
        [self reloadData];
    } else {
        self.context = [[RCNDSearchContext alloc] initWithKeyword:searchText completion:^{
            [weakSelf reloadData];
        }];
        [self.context tasksResume];
    }
}

- (void)searchBar:(UISearchBar *)searchBar editingStateChanged:(BOOL)inSearching {
    if (!inSearching) {
        [self endEditingState];
    }
//    [self reloadData];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.context numberOfRowsInSection:section];
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return [self.context cellViewModelAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.context numberOfSections];
}
- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return [self.context titleForHeaderInSection:section];
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 21;

    return height;
}

@end
