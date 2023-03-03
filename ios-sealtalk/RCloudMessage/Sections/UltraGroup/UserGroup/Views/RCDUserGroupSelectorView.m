//
//  RCDUserGroupSelectorView.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/12.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupSelectorView.h"

@interface RCDUserGroupSelectorView()
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;
@property(nonatomic, strong, readwrite) UITableView *tableView;
@end

@implementation RCDUserGroupSelectorView

- (void)setupView {
    [super setupView];
    
    [self addSubview:self.searchBar];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(48);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.searchBar.mas_bottom).mas_offset(10);
    }];
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    }
    return _searchBar;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        
    }
    return _tableView;
}
@end
