//
//  RCNDBlackListViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBlackListViewController.h"
#import "RCNDMemberRemoveCellViewModel.h"

@implementation RCNDBlackListViewController

#pragma mark - RCNDBaseListViewModelDelegate

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel.delegate = self;
    if ([self.viewModel isKindOfClass:[RCNDBlackListViewModel class]]) {
        RCNDBlackListViewModel *vm = (RCNDBlackListViewModel *)self.viewModel;
        [vm fetchAllData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.viewModel isKindOfClass:[RCNDBlackListViewModel class]]) {
        RCNDBlackListViewModel *vm = (RCNDBlackListViewModel *)self.viewModel;
        [vm endEditingState];
    }}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)setupView {
    [super setupView];
    [self configureLeftBackButton];
    self.title = RCDLocalizedString(@"blacklist");
    // 去掉搜索
//    if ([self.viewModel isKindOfClass:[RCNDBlackListViewModel class]]) {
//        RCNDBlackListViewModel *vm = (RCNDBlackListViewModel *)self.viewModel;
//        [self.listView configureSearchBar:vm.searchBar];
//    }
}
@end
