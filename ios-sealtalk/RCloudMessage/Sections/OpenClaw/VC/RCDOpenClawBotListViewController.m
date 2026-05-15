//
//  RCDOpenClawBotListViewController.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotListViewController.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotListViewModel.h"
#import "RCDOpenClawBotListCell.h"
#import "RCDOpenClawSearchView.h"
#import "RCUChatViewController.h"
#import "RCDUIBarButtonItem.h"
#import "UIView+MBProgressHUD.h"

static CGFloat const RCDOpenClawBotListSearchHeaderHeight = 56.f;
static CGFloat const RCDOpenClawBotListSearchBarHorizontalPadding = 16.f;
static CGFloat const RCDOpenClawBotListSearchBarTopPadding = 8.f;
static CGFloat const RCDOpenClawBotListSearchBarHeight = 40.f;

@interface RCDOpenClawBotListViewController ()

@property (nonatomic, strong) RCDOpenClawBotListViewModel *viewModel;
@property (nonatomic, strong) UIView *searchHeaderView;
@property (nonatomic, strong) RCDOpenClawSearchView *searchView;

@end

@implementation RCDOpenClawBotListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"OpenClawMyAIRobot");
    self.navigationItem.leftBarButtonItems =
        [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    self.viewModel = [[RCDOpenClawBotListViewModel alloc] init];
    self.view.backgroundColor = RCDDYCOLOR(0xf3f5fb, 0x111111);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.searchHeaderView;
    self.tableView.tableFooterView = [UIView new];
    [self loadBots];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateSearchHeaderFrameIfNeeded];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadBots {
    [self.view showLoading];
    [self.viewModel loadBotsWithSuccess:^{
        [self.view hideLoading];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [self.view hideLoading];
        [self.view showHUDMessage:error.localizedDescription ?: RCDLocalizedString(@"OpenClawLoadFailed")];
    }];
}

- (void)updateSearchHeaderFrameIfNeeded {
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    if (width <= 0) {
        return;
    }
    
    CGRect headerFrame = CGRectMake(0, 0, width, RCDOpenClawBotListSearchHeaderHeight);
    CGRect containerFrame = CGRectMake(RCDOpenClawBotListSearchBarHorizontalPadding,
                                       RCDOpenClawBotListSearchBarTopPadding,
                                       width - RCDOpenClawBotListSearchBarHorizontalPadding * 2,
                                       RCDOpenClawBotListSearchBarHeight);
    BOOL needsUpdateHeader = !CGRectEqualToRect(self.searchHeaderView.frame, headerFrame);
    self.searchHeaderView.frame = headerFrame;
    self.searchView.frame = containerFrame;
    if (needsUpdateHeader || self.tableView.tableHeaderView != self.searchHeaderView) {
        self.tableView.tableHeaderView = self.searchHeaderView;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchView resignSearchFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfBots];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RCDOpenClawBotListCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDOpenClawBotListCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDOpenClawBotListCellIdentifier];
    if (!cell) {
        cell = [[RCDOpenClawBotListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:RCDOpenClawBotListCellIdentifier];
    }
    RCDOpenClawBot *bot = [self.viewModel botAtIndex:indexPath.row];
    NSString *portrait = [self.viewModel portraitUriForBot:bot];
    [cell configureWithName:[self.viewModel displayNameForBot:bot] portraitUri:portrait];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCDOpenClawBot *bot = [self.viewModel botAtIndex:indexPath.row];
    [self.viewModel cacheBot:bot];
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = bot.botId;
    chatVC.title = bot.name;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (UIView *)searchHeaderView {
    if (!_searchHeaderView) {
        _searchHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), RCDOpenClawBotListSearchHeaderHeight)];
        _searchHeaderView.backgroundColor = RCDDYCOLOR(0xf3f5fb, 0x111111);
        [_searchHeaderView addSubview:self.searchView];
    }
    return _searchHeaderView;
}

- (RCDOpenClawSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[RCDOpenClawSearchView alloc] initWithFrame:CGRectMake(RCDOpenClawBotListSearchBarHorizontalPadding,
                                                                              RCDOpenClawBotListSearchBarTopPadding,
                                                                              CGRectGetWidth(self.view.bounds) - RCDOpenClawBotListSearchBarHorizontalPadding * 2,
                                                                              RCDOpenClawBotListSearchBarHeight)];
        __weak typeof(self) weakSelf = self;
        _searchView.textChangedBlock = ^(NSString *text) {
            [weakSelf.viewModel updateSearchKeyword:text];
            [weakSelf.tableView reloadData];
        };
    }
    return _searchView;
}

@end
