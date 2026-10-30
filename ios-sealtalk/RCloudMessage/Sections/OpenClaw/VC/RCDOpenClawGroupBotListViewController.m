//
//  RCDOpenClawGroupBotListViewController.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawGroupBotListViewController.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotSelectViewController.h"
#import "RCDOpenClawGroupBotListViewModel.h"
#import "RCDOpenClawBotActionCell.h"
#import "RCDOpenClawGroupBotAddCell.h"
#import "UIView+MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDOpenClawGroupBotListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) RCDOpenClawGroupBotListViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation RCDOpenClawGroupBotListViewController

- (instancetype)initWithGroupId:(NSString *)groupId {
    self = [super init];
    if (self) {
        _groupId = [groupId copy];
    }
    return self;
}

- (void)loadView {
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"OpenClawGroupBot");
    [self setNavigationBarItems];
    self.viewModel = [[RCDOpenClawGroupBotListViewModel alloc] initWithGroupId:self.groupId canManage:self.canManage];
    [self.tableView addSubview:self.emptyLabel];
    [self loadBots];
}

- (void)setNavigationBarItems {
    UIImage *imgMirror = RCDynamicImage(@"navigation_bar_btn_back_img", @"navigator_btn_back");
    self.navigationItem.leftBarButtonItems =
        [RCKitUtility getLeftNavigationItems:imgMirror title:@"" target:self action:@selector(clickBackBtn)];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadBots {
    [self.view showLoading];
    [self.viewModel loadGroupBotsWithSuccess:^{
        [self.view hideLoading];
        [self.tableView reloadData];
        [self updateEmptyView];
    } error:^(NSError *error) {
        [self.view hideLoading];
        [self.view showHUDMessage:error.localizedDescription ?: RCDLocalizedString(@"OpenClawLoadFailed")];
    }];
}

- (void)addBot {
    if (!self.canManage) {
        [self.view showHUDMessage:RCDLocalizedString(@"OpenClawOnlyOwnerAdminCanManage")];
        return;
    }
    RCDOpenClawBotSelectViewController *vc = [[RCDOpenClawBotSelectViewController alloc] initWithGroupId:self.groupId
                                                                                          existingBotIds:[self.viewModel existingBotIds]];
    __weak typeof(self) weakSelf = self;
    vc.addBotsSuccessBlock = ^(NSArray<RCDOpenClawBot *> *bots) {
        for (RCDOpenClawBot *bot in bots) {
            [weakSelf.viewModel sendBotInviteNotification:bot];
        }
        [weakSelf loadBots];
        if (weakSelf.botAddedBlock) {
            weakSelf.botAddedBlock(bots.firstObject);
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfBots] + (self.canManage ? 1 : 0);
}

- (void)updateEmptyView {
    if ([self.viewModel numberOfBots] > 0 || self.canManage) {
        self.emptyLabel.hidden = YES;
        return;
    }
    self.emptyLabel.frame = self.tableView.bounds;
    self.emptyLabel.hidden = NO;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyLabel.text = RCDLocalizedString(@"OpenClawNoGroupBot");
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.font = [UIFont systemFontOfSize:16];
        _emptyLabel.textColor = RCDynamicColor(@"text_primary_color", @"0x939393", @"0x666666");
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isAddRowAtIndexPath:indexPath]) {
        return RCDOpenClawGroupBotAddCellHeight;
    }
    return RCDOpenClawBotActionCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isAddRowAtIndexPath:indexPath]) {
        RCDOpenClawGroupBotAddCell *cell = [RCDOpenClawGroupBotAddCell cellWithTableView:tableView];
        [cell configureWithTitle:RCDLocalizedString(@"OpenClawGroupBotAdd")];
        cell.hideSeparatorLine = [self.viewModel numberOfBots] == 0;
        return cell;
    }

    RCDOpenClawBotActionCell *cell = [RCDOpenClawBotActionCell cellWithTableView:tableView];
    NSInteger botIndex = [self botIndexForIndexPath:indexPath];
    RCDOpenClawBot *bot = [self.viewModel botAtIndex:botIndex];
    NSString *portrait = [self.viewModel portraitUriForBot:bot];
    [cell configureWithName:[self.viewModel displayNameForBot:bot] portraitUri:portrait];
    [cell setActionButtonVisible:self.canManage];
    [cell configureDeleteActionButton];
    cell.actionButton.tag = botIndex;
    cell.actionButton.enabled = self.canManage;
    cell.hideSeparatorLine = botIndex == [self.viewModel numberOfBots] - 1;
    [cell.actionButton addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isAddRowAtIndexPath:indexPath]) {
        [self addBot];
    }
}

- (BOOL)isAddRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.canManage && indexPath.row == 0;
}

- (NSInteger)botIndexForIndexPath:(NSIndexPath *)indexPath {
    return self.canManage ? indexPath.row - 1 : indexPath.row;
}

- (void)removeButtonTapped:(UIButton *)sender {
    if (!self.canManage) {
        [self.view showHUDMessage:RCDLocalizedString(@"OpenClawOnlyOwnerAdminCanManage")];
        return;
    }
    NSInteger botIndex = sender.tag;
    if (botIndex < 0 || botIndex >= [self.viewModel numberOfBots]) {
        return;
    }
    RCDOpenClawBot *bot = [self.viewModel botAtIndex:botIndex];
    NSString *name = [self.viewModel displayNameForBot:bot];
    NSString *message = [NSString stringWithFormat:RCDLocalizedString(@"OpenClawGroupBotRemoveConfirm"), name];
    [RCAlertView showAlertController:nil
                              message:message
                         actionTitles:nil
                          cancelTitle:RCLocalizedString(@"Cancel")
                         confirmTitle:RCLocalizedString(@"Confirm")
                       preferredStyle:UIAlertControllerStyleAlert
                         actionsBlock:nil
                          cancelBlock:nil
                         confirmBlock:^{
                             [self removeBotAtIndex:botIndex];
                         }
                     inViewController:self];
}

- (void)removeBotAtIndex:(NSInteger)index {
    [self.view showLoading];
    [self.viewModel removeBotAtIndex:index success:^{
        [self.view hideLoading];
        [self.view showHUDMessage:RCDLocalizedString(@"OpenClawRemoveSuccess")];
        [self loadBots];
    } error:^(NSError *error) {
        [self.view hideLoading];
        [self.view showHUDMessage:error.localizedDescription ?: RCDLocalizedString(@"OpenClawRemoveFailed")];
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = RCDynamicColor(@"auxiliary_background_1_color", @"0xf5f6f9", @"0x111111");
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 15)];
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

@end
