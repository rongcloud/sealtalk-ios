//
//  RCDSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/20.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDSettingsTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCNDLoginViewController.h"
#import "RCDMessageNotifySettingTableViewController.h"
#import "RCDPrivacyTableViewController.h"
#import "RCDPushSettingViewController.h"
#import "RCDUIBarButtonItem.h"
#import "UIColor+RCColor.h"
#import "RCDLoginManager.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDCommonString.h"
#import "RCDCleanChatHistoryViewController.h"
#import "RCDChatBackgroundViewController.h"

@interface RCDSettingsTableViewController ()

@end

@implementation RCDSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

#pragma mark - Table view Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger row = 0;
    if (0 == section) {
        row = 3;
    } else if (1 == section) {
        row = 3;
    } else if (2 == section) {
        row = 1;
    } else if (3 == section) {
        row = 1;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (2 == indexPath.section) {
        return [self createQuitCell];
    } else if (3 == indexPath.section){
        return [self createCancellationCell];
    }

    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    [cell setCellStyle:DefaultStyle];
    NSString *text = @"";
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            text = RCDLocalizedString(@"SecurityAndprivacy");
        } else if (1 == indexPath.row) {
            text = RCDLocalizedString(@"new_message_notification");
        } else if (2 == indexPath.row) {
            text = RCDLocalizedString(@"push_setting");
        }
    } else {
        if (indexPath.row == 0) {
            text = RCDLocalizedString(@"ChatBackground");
        } else if (indexPath.row == 1) {
            text = RCDLocalizedString(@"clear_cache");
        } else {
            text = RCDLocalizedString(@"CleanChatHistory");
        }
    }
    cell.leftLabel.text = text;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            RCDPrivacyTableViewController *vc = [[RCDPrivacyTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (1 == indexPath.row) {
            RCDMessageNotifySettingTableViewController *vc = [[RCDMessageNotifySettingTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (2 == indexPath.row) {
            RCDPushSettingViewController *vc = [[RCDPushSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (1 == indexPath.section) {
        if (indexPath.row == 0) {
            RCDChatBackgroundViewController *chatBgVC = [[RCDChatBackgroundViewController alloc] init];
            [self.navigationController pushViewController:chatBgVC animated:YES];
        } else if (indexPath.row == 1) {
            //清除缓存
            [self showAlert:RCDLocalizedString(@"clear_cache_alert")
                cancelBtnTitle:RCDLocalizedString(@"cancel")
                 otherBtnTitle:RCDLocalizedString(@"confirm")
                           tag:1011];
        } else {
            RCDCleanChatHistoryViewController *cleanVC = [[RCDCleanChatHistoryViewController alloc] init];
            [self.navigationController pushViewController:cleanVC animated:YES];
        }
    } else if (2 == indexPath.section) {
        //退出登录
        [self showAlert:RCDLocalizedString(@"logout_alert")
            cancelBtnTitle:RCDLocalizedString(@"cancel")
             otherBtnTitle:RCDLocalizedString(@"confirm")
                       tag:1010];
    } else if (3 == indexPath.section) {
        //注销账户
        [self showAlert:RCDLocalizedString(@"delete_account_alert")
            cancelBtnTitle:RCDLocalizedString(@"cancel")
             otherBtnTitle:RCDLocalizedString(@"confirm")
                       tag:1012];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

//清理缓存
- (void)clearCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        //这里清除 Library/Caches 里的所有文件，融云的缓存文件及图片存放在 Library/Caches/RongCloud 下
        NSString *cachPath =
            [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];

        for (NSString *p in files) {
            NSError *error;
            NSString *path = [cachPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *naviCachePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences"]
            stringByAppendingPathComponent:@"cn.rongcloud.rcim.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:naviCachePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:naviCachePath error:nil];
        }

        [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
    });
}

- (void)clearCacheSuccess {
    [self showAlert:RCDLocalizedString(@"clear_cache_succrss")
        cancelBtnTitle:RCDLocalizedString(@"confirm")
         otherBtnTitle:nil
                   tag:-1];
}

//退出登录
- (void)logout {
    [self clearAccountInfo];
    [RCDLoginManager logout:^(BOOL success){
    }];
}

- (void)removeAccount{
    [RCDLoginManager removeAccount:^(BOOL success) {
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clearAccountInfo];
                [DEFAULTS removeObjectForKey:RCDPhoneKey];
                [DEFAULTS synchronize];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [RCAlertView showAlertController:RCDLocalizedString(@"delete_account_fail") message:nil cancelTitle:RCDLocalizedString(@"confirm") inViewController:self];
            });
        }
    }];
}

- (void)clearAccountInfo{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [DEFAULTS removeObjectForKey:RCDIMTokenKey];
    [RCDNotificationServiceDefaults removeObjectForKey:RCDIMTokenKey];
    [DEFAULTS synchronize];

    RCNDLoginViewController *loginVC = [[RCNDLoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.view.window.rootViewController = navi;
    [[RCIM sharedRCIM] logout];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:MCShareExtensionKey];
    [userDefaults removeObjectForKey:RCDCookieKey];
    [userDefaults synchronize];
}

- (void)showAlert:(NSString *)message
   cancelBtnTitle:(NSString *)cBtnTitle
    otherBtnTitle:(NSString *)oBtnTitle
              tag:(int)tag {
    [RCAlertView showAlertController:nil message:message actionTitles:nil cancelTitle:cBtnTitle confirmTitle:oBtnTitle preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:nil confirmBlock:^{
        if (tag == 1010) {
            [self logout];
        } else if (tag == 1011) {
            [self clearCache];
        } else if(tag == 1012) {
            [self removeAccount];
        }
    } inViewController:self];
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)createQuitCell {
    UITableViewCell *quitCell = [[UITableViewCell alloc] init];
    quitCell.selectionStyle = UITableViewCellSelectionStyleNone;
    quitCell.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                        darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    label.text = RCDLocalizedString(@"logout");
    label.translatesAutoresizingMaskIntoConstraints = NO;

    [quitCell setSeparatorInset:UIEdgeInsetsMake(0, 100, 0, 1000)];
    [quitCell.contentView addSubview:label];
    [quitCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:quitCell.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];

    [quitCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:quitCell.contentView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]];
    return quitCell;
}

- (UITableViewCell *)createCancellationCell {
    UITableViewCell *cancelCell = [[UITableViewCell alloc] init];
    cancelCell.selectionStyle = UITableViewCellSelectionStyleNone;
    cancelCell.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                        darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    label.text = RCDLocalizedString(@"delete_account");
    label.translatesAutoresizingMaskIntoConstraints = NO;

    [cancelCell setSeparatorInset:UIEdgeInsetsMake(0, 100, 0, 1000)];
    [cancelCell.contentView addSubview:label];
    [cancelCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cancelCell.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];

    [cancelCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cancelCell.contentView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]];
    return cancelCell;
}

- (void)initUI {
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.navigationItem.title = RCDLocalizedString(@"account_setting");
    self.navigationItem.leftBarButtonItems = [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn:)];
}

@end
