//
//  RCNDSearchMoreViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMoreViewController.h"
#import "RCNDSearchMoreView.h"

@interface RCNDSearchMoreViewController ()
@property (nonatomic, strong) RCNDSearchMoreView *moreView;

@end

@implementation RCNDSearchMoreViewController
- (instancetype)initWithViewModel:(RCNDBaseListViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.listView = self.moreView;
    }
    return self;
}
- (RCNDSearchMoreViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDSearchMoreViewModel class]]) {
        RCNDSearchMoreViewModel *vm = (RCNDSearchMoreViewModel *)self.viewModel;
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
            [self.moreView.footer endRefreshing];
        } else {
            [self.moreView.footer endRefreshingWithNoMoreData];
        }
    });
}

- (void)setupView {
    [super setupView];
    self.navigationItem.title = RCDLocalizedString(@"search");
    [self configureLeftBackButton];
    UIView *searchBar = [[self currentViewModel] searchBar];
    if (searchBar) {
        [self.listView configureSearchBar:searchBar];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self currentViewModel] titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [[self currentViewModel] heightForHeaderInSection:section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    return [[self currentViewModel] endEditingState];
}

- (void)loadMore {
    [[self currentViewModel] loadMore:^(BOOL noMoreData) {
        [self showNoMoreData:noMoreData];
    }];
    
}

- (RCNDSearchMoreView *)moreView {
    if (!_moreView) {
        _moreView = [RCNDSearchMoreView new];
        _moreView.tableView.delegate = self;
        _moreView.tableView.dataSource = self;
        [_moreView.footer setRefreshingTarget:self refreshingAction:@selector(loadMore)];
    }
    return _moreView;
}
@end
