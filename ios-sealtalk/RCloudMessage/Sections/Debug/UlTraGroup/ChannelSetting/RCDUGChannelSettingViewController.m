//
//  RCDUGChannelSettingViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/6/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUGChannelSettingViewController.h"
#import "RCDChannelSettingHeaderView.h"
#import "RCDChannelUserInfoCell.h"
#import "RCDUGChannelSettingCell.h"
#import "UIView+MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserGroupChannelBelongViewController.h"


@interface RCDUGChannelSettingViewController () <UICollectionViewDelegate, UICollectionViewDataSource, RCDUGChannelSettingViewModelDelegate>
@property (nonatomic, strong) RCDUGChannelSettingViewModel *viewModel;
@property (nonatomic, strong) RCDChannelSettingHeaderView *headerView;
@property (nonatomic, strong) UIView *footerView;
@end

@implementation RCDUGChannelSettingViewController

- (instancetype)initWithViewModel:(RCDUGChannelSettingViewModel *)viewModel
{
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
        self.viewModel.delegate = self;
        [self.view showLoading];
        [viewModel query];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

- (void)ready {
    [self.tableView registerClass:[RCDUGChannelSettingCell class]
           forCellReuseIdentifier:RCDUGChannelSettingCellIdentifier];
    [self.headerView.collectionView registerClass:[RCDChannelUserInfoCell class]
                       forCellWithReuseIdentifier:RCDChannelUserInfoCellIdentifier];
    self.headerView.collectionView.delegate = self;
    self.headerView.collectionView.dataSource = self;
    self.tableView.tableHeaderView = self.headerView;
    if (self.viewModel.isOwner) {
        self.tableView.tableFooterView = self.footerView;
    }
}

- (void)showTipsBy:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}

- (void)btnFooterClick:(UIButton *)btn {

    [RCActionSheetView showActionSheetView:@"确定解散频道吗?"
                                 cellArray:@[RCDLocalizedString(@"confirm")]
                               cancelTitle:RCDLocalizedString(@"cancel")
                             selectedBlock:^(NSInteger index) {
        [self.viewModel disband];
    }
                               cancelBlock:^{}];
}

- (void)editChannelType {
    NSString *message = self.viewModel.isPrivate ? @"确定修改为公有频道?" : @"确定修改为私有频道?";
    [RCActionSheetView showActionSheetView:message cellArray:@[RCDLocalizedString(@"confirm")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
        [self.viewModel editChannelType];

    } cancelBlock:^{
        
    }];
}

- (void)showUserGroup {
    RCDUserGroupChannelBelongViewController *vc = [RCDUserGroupChannelBelongViewController new];
    vc.title = self.title;
    vc.channelID = self.viewModel.channelID;
    vc.groupID = self.viewModel.groupID;
    vc.isOwner = self.viewModel.isOwner;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -  RCDUGChannelSettingViewModelDelegate

- (void)memberInfoDidLoaded {
    [self.headerView.collectionView reloadData];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [self.viewModel headerViewHeight];
    self.headerView.frame = CGRectMake(0, 0, width, height);
    self.tableView.tableHeaderView = self.headerView;
    [self.view hideLoading];
}

- (void)editChannelTypeFinishedWith:(BOOL)success {
    if (success) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:RCDUGChannelSettingRowTypeChannelType
                                                    inSection:0];
        RCDUGChannelSettingCell *cell = (RCDUGChannelSettingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[RCDUGChannelSettingCell class]]) {
            [cell updateCellWith:@"频道类型" subtitle:[self.viewModel stringOfChannelType]];
        }
    } else {
        [self showTipsBy:@"修改频道类型失败"];
    }
}

- (void)disbandChannelFinishedWith:(BOOL)success {
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    } else {
        [self showTipsBy:@"解散频道失败"];

    }
}
#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel heightForRowType:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RCDUGChannelSettingRowTypeTotalNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tCell = nil;
    switch (indexPath.row) {
        case RCDUGChannelSettingRowTypeChannelType: {
            RCDUGChannelSettingCell *cell = (RCDUGChannelSettingCell *)[tableView dequeueReusableCellWithIdentifier:RCDUGChannelSettingCellIdentifier
                                                   forIndexPath:indexPath];
            [cell updateCellWith:@"频道类型" subtitle:[self.viewModel stringOfChannelType]];
             tCell = cell;
        }
            break;
        case RCDUGChannelSettingRowTypeUserGroup: {
            RCDUGChannelSettingCell *cell = (RCDUGChannelSettingCell *)[tableView dequeueReusableCellWithIdentifier:RCDUGChannelSettingCellIdentifier
                                                   forIndexPath:indexPath];
            [cell updateCellWith:@"用户组" subtitle:@""];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
             tCell = cell;
        }
            break;
            
        default:
            break;
    }
    if (!tCell) {
        tCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"UITableViewCellStyleDefault"];
    }
    return tCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    switch (indexPath.row) {
        case RCDUGChannelSettingRowTypeChannelType: {
            if (!self.viewModel.isOwner) {
                return;
            }
            [self editChannelType];
        }
            break;
        case RCDUGChannelSettingRowTypeUserGroup:
            [self showUserGroup];
            break;
        default:
            break;
    }
}
#pragma mark - UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel sizeForItem];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel numberOfMemebers];;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCDChannelUserInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RCDChannelUserInfoCellIdentifier
                                                                             forIndexPath:indexPath];
    RCDChannelUserInfoCellViewModel *vm = [self.viewModel viewModelAtIndex:indexPath];
    [cell updateCellWith:vm];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.viewModel.isOwner) {
        return;
    }
    RCDChannelUserInfoCellViewModel *vm = [self.viewModel viewModelAtIndex:indexPath];
    [vm changeUserStatus];
}

- (RCDChannelSettingHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [RCDChannelSettingHeaderView new];
    }
    return _headerView;
}

- (UIView *)footerView {
    if (!_footerView) {
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 150)];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(16, 20, width-32, 44)];
        [btn setBackgroundImage:[UIImage imageNamed:@"group_quit"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"group_quit_hover"] forState:UIControlStateSelected];
        [btn setTitle:RCDLocalizedString(@"delete_and_exit") forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5.f;
        btn.layer.borderWidth = 0.5f;
        btn.layer.borderColor = [HEXCOLOR(0xcc4445) CGColor];
        [btn addTarget:self
                               action:@selector(btnFooterClick:)
                     forControlEvents:UIControlEventTouchUpInside];
        if (self.viewModel.isOwner) {
            [btn setTitle:RCDLocalizedString(@"DisbandAndDelete") forState:UIControlStateNormal];
    
        } else {
            [btn setTitle:RCDLocalizedString(@"delete_and_exit") forState:UIControlStateNormal];
        }
        [view addSubview:btn];
        _footerView = view;
    }
    return _footerView;
   
}
@end
