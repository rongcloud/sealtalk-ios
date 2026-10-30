//
//  RCDOpenClawBotSelectViewController.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotSelectViewController.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotSelectCell.h"
#import "RCDOpenClawBotSelectViewModel.h"
#import "UIView+MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDOpenClawBotSelectViewController () <UITableViewDelegate, UITableViewDataSource, RCSearchBarViewModelDelegate>

@property (nonatomic, strong) RCDOpenClawBotSelectViewModel *viewModel;
@property (nonatomic, strong) RCSelectUserView *listView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) RCSearchBarViewModel *searchBarViewModel;
@property (nonatomic, strong) NSMutableSet<NSString *> *selectedBotIds;

@end

@implementation RCDOpenClawBotSelectViewController

- (instancetype)initWithGroupId:(NSString *)groupId
                  existingBotIds:(NSArray<NSString *> *)existingBotIds {
    self = [super init];
    if (self) {
        _viewModel = [[RCDOpenClawBotSelectViewModel alloc] initWithGroupId:groupId
                                                             existingBotIds:existingBotIds];
        _selectedBotIds = [NSMutableSet set];
    }
    return self;
}

- (void)loadView {
    self.view = self.listView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"OpenClawMyRobot");
    [self setNavigationBarItems];
    [self.listView configureSearchBar:self.searchBarViewModel.searchBar];
    [self loadBots];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBarViewModel endEditingState];
}

- (void)setNavigationBarItems {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
    self.confirmButton.enabled = NO;

    UIImage *imgMirror = RCDynamicImage(@"navigation_bar_btn_back_img", @"navigator_btn_back");
    self.navigationItem.leftBarButtonItems =
        [RCKitUtility getLeftNavigationItems:imgMirror title:@"" target:self action:@selector(clickBackBtn)];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadBots {
    [self.view showLoading];
    [self.viewModel loadBotsWithSuccess:^{
        [self.view hideLoading];
        [self reloadListView];
    } error:^(NSError *error) {
        [self.view hideLoading];
        [self.view showHUDMessage:error.localizedDescription ?: RCDLocalizedString(@"OpenClawLoadFailed")];
    }];
}

- (void)reloadListView {
    [self.listView.tableView reloadData];
    self.listView.emptyLabel.hidden = [self.viewModel numberOfBots] > 0;
}

- (void)updateConfirmButtonState {
    self.confirmButton.enabled = self.selectedBotIds.count > 0;
}

- (void)confirmButtonDidClick {
    NSArray<NSString *> *botIds = self.selectedBotIds.allObjects;
    if (botIds.count == 0) {
        return;
    }

    [self.view showLoading];
    [self.viewModel addBotsWithBotIds:botIds success:^(NSArray<RCDOpenClawBot *> *bots) {
        [self.view hideLoading];
        [self.view showHUDMessage:RCDLocalizedString(@"OpenClawAddSuccess")];
        if (self.addBotsSuccessBlock) {
            self.addBotsSuccessBlock(bots);
        }
        if (self.addSuccessBlock && bots.count > 0) {
            self.addSuccessBlock(bots.firstObject);
        }
        if (self.navigationController.topViewController == self) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } error:^(NSError *error) {
        [self.view hideLoading];
        [self.view showHUDMessage:error.localizedDescription ?: RCDLocalizedString(@"OpenClawAddFailed")];
    }];
}

#pragma mark - RCSearchBarViewModelDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.viewModel updateSearchKeyword:searchText];
    [self reloadListView];
}

- (void)searchBar:(UISearchBar *)searchBar editingStateChanged:(BOOL)inSearching {
    if (!inSearching) {
        [self.viewModel updateSearchKeyword:nil];
    }
    [self reloadListView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfBots];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RCDOpenClawBotSelectCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDOpenClawBotSelectCell *cell = [RCDOpenClawBotSelectCell cellWithTableView:tableView];
    RCDOpenClawBot *bot = [self.viewModel botAtIndex:indexPath.row];
    BOOL alreadyAdded = [self.viewModel isBotAlreadyAddedAtIndex:indexPath.row];
    NSString *portrait = [self.viewModel portraitUriForBot:bot];
    [cell configureWithName:[self.viewModel displayNameForBot:bot] portraitUri:portrait];
    [cell setCellSelectState:[self selectStateForBot:bot alreadyAdded:alreadyAdded]];
    cell.hideSeparatorLine = indexPath.row == [self.viewModel numberOfBots] - 1;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDOpenClawBot *bot = [self.viewModel botAtIndex:indexPath.row];
    if ([self.viewModel isBotAlreadyAdded:bot] || bot.botId.length == 0) {
        return;
    }

    if ([self.selectedBotIds containsObject:bot.botId]) {
        [self.selectedBotIds removeObject:bot.botId];
    } else {
        [self.selectedBotIds addObject:bot.botId];
    }

    RCDOpenClawBotSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setCellSelectState:[self selectStateForBot:bot alreadyAdded:NO]];
    [self updateConfirmButtonState];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (RCDOpenClawBotSelectCellState)selectStateForBot:(RCDOpenClawBot *)bot alreadyAdded:(BOOL)alreadyAdded {
    if (alreadyAdded || bot.botId.length == 0) {
        return RCDOpenClawBotSelectCellStateDisable;
    }
    return [self.selectedBotIds containsObject:bot.botId] ? RCDOpenClawBotSelectCellStateSelected : RCDOpenClawBotSelectCellStateUnselected;
}

#pragma mark - Getters

- (RCSelectUserView *)listView {
    if (!_listView) {
        _listView = [RCSelectUserView new];
        _listView.tableView.delegate = self;
        _listView.tableView.dataSource = self;
        _listView.emptyLabel.text = RCDLocalizedString(@"OpenClawNoGroupBot");
    }
    return _listView;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:RCDLocalizedString(@"confirm") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:RCDynamicColor(@"primary_color", @"0x0099ff", @"0x007acc") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:RCDynamicColor(@"disabled_color", @"0xa0a5ab", @"0xa0a5ab") forState:UIControlStateDisabled];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        _confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (RCSearchBarViewModel *)searchBarViewModel {
    if (!_searchBarViewModel) {
        _searchBarViewModel = [[RCSearchBarViewModel alloc] init];
        _searchBarViewModel.delegate = self;
    }
    return _searchBarViewModel;
}

@end
