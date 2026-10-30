//
//  RCNDAccountSettingViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDAccountSettingViewController.h"
#import "RCNDFooterView.h"
#import "RCNDLoginViewController.h"
@interface RCNDAccountSettingViewController()<RCNDAccountSettingViewModelDelegate>

@end

@implementation RCNDAccountSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self currentViewModel] setAccountDelegate:self];
}

- (RCNDAccountSettingViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDAccountSettingViewModel class]]) {
        RCNDAccountSettingViewModel *vm = (RCNDAccountSettingViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)setupView {
    [super setupView];
    self.navigationItem.title = RCDLocalizedString(@"account_setting");
    [self configureLeftBackButton];
    
    // 创建按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:RCDLocalizedString(@"delete_account") forState:UIControlStateNormal];
    [btn setBackgroundColor:RCDynamicColor(@"hint_color", @"0xF74D43", @"0xFF5047")];
    [btn setTitleColor:RCDynamicColor(@"control_title_white_color", @"0xffffff", @"0xffffff")
              forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 6;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addTarget:self action:@selector(removeAccount) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加按钮高度约束
    [btn.heightAnchor constraintEqualToConstant:42].active = YES;
    
    // 创建 footer 并添加按钮
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    RCNDFooterView *footer = [[RCNDFooterView alloc] initWithFrame:CGRectMake(0, 0, width, 82)];
    [footer.contentStackView addArrangedSubview:btn];
    
    self.listView.tableView.tableFooterView = footer;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self currentViewModel] titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.viewModel isKindOfClass:[RCNDAccountSettingViewModel class]]) {
        RCNDAccountSettingViewModel *vm = (RCNDAccountSettingViewModel *)self.viewModel;
        return [vm heightForHeaderInSection:section];
    }
    return 0;
}

#pragma mark - RCNDAccountSettingViewModelDelegate
- (void)userDidSelectedCleanCache {
    [RCAlertView showAlertController:nil message:RCDLocalizedString(@"clear_cache_alert") actionTitles:nil cancelTitle:RCDLocalizedString(@"cancel") confirmTitle:RCDLocalizedString(@"confirm") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:nil confirmBlock:^{
        [[self currentViewModel] clearCache:^{
            [self cleanCacheFinished];
        }];
    } inViewController:self];
}

- (void)cleanCacheFinished {
    [RCAlertView showAlertController:nil message:RCDLocalizedString(@"clear_cache_succrss") actionTitles:nil cancelTitle:nil confirmTitle:RCDLocalizedString(@"confirm") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:nil confirmBlock:^{
       
    } inViewController:self];
}

- (void)removeAccount {
    [RCAlertView showAlertController:nil message:RCDLocalizedString(@"delete_account_alert") actionTitles:nil cancelTitle:RCDLocalizedString(@"cancel") confirmTitle:RCDLocalizedString(@"confirm") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:nil confirmBlock:^{
        [[self currentViewModel] removeAccount:^(BOOL success) {
            if (!success) {
                [self removeAccountFailed];
            } else {
                [self gotLogin];
            }
        }];
    } inViewController:self];
  
}
- (void)removeAccountFailed {
    [RCAlertView showAlertController:nil message:RCDLocalizedString(@"delete_account_fail") actionTitles:nil cancelTitle:RCDLocalizedString(@"cancel") confirmTitle:RCDLocalizedString(@"confirm") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:nil confirmBlock:^{
       
    } inViewController:self];
}

- (void)gotLogin {
    RCNDLoginViewController *loginVC = [[RCNDLoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.view.window.rootViewController = navi;
}
@end
