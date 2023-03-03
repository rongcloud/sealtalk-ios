//
//  RCDUltraGroupSettingController.m
//  SealTalk
//
//  Created by 张改红 on 2022/1/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUltraGroupSettingController.h"
#import "RCDGroupSettingsTableViewCell.h"
#import "UIImage+RCImage.h"
#import "RCDUserListCollectionView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDCommonString.h"
#import "NormalAlertView.h"
#import "RCDUltraGroupManager.h"
#import "UIView+MBProgressHUD.h"
#import "RCDUserGroupListController.h"

static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";

@interface RCDUltraGroupSettingController ()
@property (nonatomic, strong) RCDUserListCollectionView *headerView;
@property (nonatomic, strong) NSArray *settingTableArr;
@end

@implementation RCDUltraGroupSettingController

- (instancetype)initWithStyle:(UITableViewStyle)style{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 48, 0, 0);
    self.title = RCDLocalizedString(@"group_information");
    [self refreshTableViewInfo];
    [self startLoad];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)showUserGroup {
    RCDUserGroupListController *vc = [RCDUserGroupListController new];
    vc.groupID = self.ultraGroup.groupId;
    BOOL ret = [self.ultraGroup.creatorId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId];
    vc.isOwner = ret;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.settingTableArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.settingTableArr[indexPath.section];
    RCDGroupSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[RCDGroupSettingsTableViewCell alloc] initWithTitle:title andGroupInfo:(RCDGroupInfo *)self.ultraGroup];
    }
    if (indexPath.row == 0) {
        cell.leftLabel.text = title;
        cell.rightLabel.text = self.ultraGroup.groupName;
    } else {
        cell.leftLabel.text = RCDLocalizedString(@"group_user_group");
        cell.rightLabel.text = @"";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self showUserGroup];
    }
}
#pragma mark - helper
- (void)quitGroup {

    [RCDUltraGroupManager quitUltraGroup:self.ultraGroup.groupId complete:^(BOOL success) {
        if (success) {
            [self clearConversationAndMessage];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self showAlert:RCDLocalizedString(@"quit_fail")];
        }
    }];
}

- (void)dismissGroup {
    [RCDUltraGroupManager dismissUltraGroup:self.ultraGroup.groupId complete:^(BOOL success) {
        if (success) {
            [self clearConversationAndMessage];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self showAlert:RCDLocalizedString(@"Disband_group_fail")];
        }
    }];
}

- (void)clearConversationAndMessage {
    NSArray *latestMessages =
        [[RCCoreClient sharedCoreClient] getLatestMessages:ConversationType_GROUP targetId:self.ultraGroup.groupId count:1];
    if (latestMessages.count > 0) {
        RCMessage *message = (RCMessage *)[latestMessages firstObject];
        [[RCCoreClient sharedCoreClient] clearRemoteHistoryMessages:ConversationType_GROUP
                                                         targetId:self.ultraGroup.groupId
                                                       recordTime:message.sentTime
                                                          success:^{
                                                              [[RCCoreClient sharedCoreClient]
                                                                  clearMessages:ConversationType_GROUP
                                                                       targetId:self.ultraGroup.groupId];
                                                          }
                                                            error:nil];
    }
    [[RCCoreClient sharedCoreClient] removeConversation:ConversationType_GROUP targetId:self.ultraGroup.groupId];
}

- (void)refreshTableViewInfo {
    self.settingTableArr = @[RCDLocalizedString(@"group_name"),RCDLocalizedString(@"group_user_group")];
    [self.tableView reloadData];
}

- (void)showAlert:(NSString *)alertContent {
    [NormalAlertView showAlertWithTitle:nil
                                message:alertContent
                          describeTitle:nil
                           confirmTitle:RCDLocalizedString(@"confirm")
                                confirm:^{
                                }];
}

- (void)showActionSheet:(NSString *)title tag:(NSInteger)tag {
    [RCActionSheetView showActionSheetView:title cellArray:@[RCDLocalizedString(@"confirm")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
        if (tag == 101) {
            [self quitGroup];
        } else if (tag == 102) {
            [self dismissGroup];
        }
    } cancelBlock:^{
        
    }];
}

- (void)setHeaderView {
    __weak typeof(self) weakSelf = self;
    [RCDUltraGroupManager getUltraGroupMemberList:self.ultraGroup.groupId count:50 complete:^(NSArray<NSString *> * _Nonnull memberIdList) {
        weakSelf.headerView = nil;
        [weakSelf.headerView reloadData:memberIdList];
        weakSelf.headerView.frame =
        CGRectMake(0, 0, RCDScreenWidth, weakSelf.headerView.collectionViewLayout.collectionViewContentSize.height);
        CGRect frame = weakSelf.headerView.frame;
        frame.size.height += 14;
        weakSelf.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];
        [weakSelf.tableView.tableHeaderView addSubview:self.headerView];
        
        UIView *separatorLine =
        [[UIView alloc] initWithFrame:CGRectMake(10, frame.size.height - 1, frame.size.width - 10, 1)];
        separatorLine.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        [weakSelf.tableView.tableHeaderView addSubview:separatorLine];
    }];
}

- (void)setTableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    UIButton *joinOrQuitGroupBtn = [[UIButton alloc] init];
    [joinOrQuitGroupBtn setBackgroundImage:[UIImage imageNamed:@"group_quit"] forState:UIControlStateNormal];
    [joinOrQuitGroupBtn setBackgroundImage:[UIImage imageNamed:@"group_quit_hover"] forState:UIControlStateSelected];
    [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"delete_and_exit") forState:UIControlStateNormal];
    joinOrQuitGroupBtn.layer.cornerRadius = 5.f;
    joinOrQuitGroupBtn.layer.borderWidth = 0.5f;
    joinOrQuitGroupBtn.layer.borderColor = [HEXCOLOR(0xcc4445) CGColor];
    [view addSubview:joinOrQuitGroupBtn];
    [joinOrQuitGroupBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(joinOrQuitGroupBtn);
    if ([self.ultraGroup.creatorId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"DisbandAndDelete") forState:UIControlStateNormal];
        [joinOrQuitGroupBtn addTarget:self
                               action:@selector(btnDismissAction:)
                     forControlEvents:UIControlEventTouchUpInside];
    } else {
        [joinOrQuitGroupBtn setTitle:RCDLocalizedString(@"delete_and_exit") forState:UIControlStateNormal];
        [joinOrQuitGroupBtn addTarget:self
                               action:@selector(btnJOQAction:)
                     forControlEvents:UIControlEventTouchUpInside];
    }
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-29-[joinOrQuitGroupBtn(42)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[joinOrQuitGroupBtn]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    self.tableView.tableFooterView = view;
}

- (void)startLoad {
    [self setHeaderView];
    [self setTableFooterView];
}

- (void)btnJOQAction:(id)sender {
    [self showActionSheet:RCDLocalizedString(@"delete_group_alert") tag:101];
}

- (void)btnDismissAction:(id)sender {
    [self showActionSheet:RCDLocalizedString(@"Disband_group_alert") tag:102];
}

- (void)showHUDMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:message];
    });
}

#pragma mark - getter & setter
- (RCDUserListCollectionView *)headerView {
    if (!_headerView) {
        CGRect tempRect =
            CGRectMake(0, 0, RCDScreenWidth, _headerView.collectionViewLayout.collectionViewContentSize.height);
        _headerView = [[RCDUserListCollectionView alloc] initWithFrame:tempRect isAllowAdd:NO isAllowDelete:NO];
        _headerView.groupId = self.ultraGroup.groupId;
    }
    return _headerView;
}
@end
