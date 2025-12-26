//
//  RCNDQRForwardGroupsViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardGroupsViewController.h"
#import "RCNDQRForwardGroupsView.h"

@interface RCNDQRForwardGroupsViewController ()
@property (nonatomic, strong) RCNDQRForwardGroupsView *groupsView;
@end

@implementation RCNDQRForwardGroupsViewController
- (instancetype)initWithViewModel:(RCNDBaseListViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.listView = self.groupsView;
    }
    return self;
}

- (RCNDQRForwardGroupsViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDQRForwardGroupsViewModel class]]) {
        RCNDQRForwardGroupsViewModel *vm = (RCNDQRForwardGroupsViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self currentViewModel] fetchData:^(BOOL noMoreData) {
        [self showNoMoreData:noMoreData];
    }];
}

- (void)showNoMoreData:(BOOL)noMoreData {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!noMoreData) {
            [self.groupsView.footer endRefreshing];
        } else {
            [self.groupsView.footer endRefreshingWithNoMoreData];
        }
    });
}

- (void)setupView {
    [super setupView];
    self.navigationItem.title = RCDLocalizedString(@"SelectGroupConversation");
    [self configureLeftBackButton];
}


- (void)loadMore {
    [[self currentViewModel] loadMore:^(BOOL noMoreData) {
        [self showNoMoreData:noMoreData];
    }];
    
}

- (RCNDQRForwardGroupsView *)groupsView {
    if (!_groupsView) {
        _groupsView = [RCNDQRForwardGroupsView new];
        _groupsView.tableView.delegate = self;
        _groupsView.tableView.dataSource = self;
        [_groupsView.footer setRefreshingTarget:self refreshingAction:@selector(loadMore)];
    }
    return _groupsView;
}
@end
