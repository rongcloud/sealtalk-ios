//
//  RCNDBaseTableViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseTableViewController.h"

@implementation RCNDBaseTableViewController

- (instancetype)initWithViewModel:(RCNDBaseListViewModel *)viewModel
{
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
        viewModel.delegate = self;
    }
    return self;
}

- (void)loadView {
    self.view = self.listView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewModel registerCellForTableView:self.listView.tableView];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    return [self.viewModel tableView:tableView cellForRowAtIndexPath:indexPath];;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return [self.viewModel tableView:tableView numberOfRowsInSection:section];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel tableView:tableView heightForRowAtIndexPath:indexPath];;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel tableView:tableView didSelectRowAtIndexPath:indexPath viewController:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSectionsInTableView:tableView];
}

- (void)reloadData:(BOOL)empty {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listView.tableView reloadData];
        self.listView.labEmpty.hidden = !empty;
    });
}

- (void)showTips:(NSString *)tips {
    [super showTips:tips];
}

- (RCSearchBarListView *)listView {
    if (!_listView) {
        RCSearchBarListView *listView = [RCSearchBarListView new];
        listView.tableView.dataSource = self;
        listView.tableView.delegate = self;
        _listView = listView;
    }
    return _listView;
}
@end
