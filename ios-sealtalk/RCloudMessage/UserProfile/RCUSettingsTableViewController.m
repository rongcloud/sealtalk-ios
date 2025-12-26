//
//  RCUSettingsTableViewController.m
//  SealTalk
//
//  Created by RobinCui on 2024/8/29.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUSettingsTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDCleanChatHistoryViewController.h"
#import "RCDPushSettingViewController.h"
#import "RCDMessageNotifySettingTableViewController.h"

@interface RCDSettingsTableViewController ()
- (void)showAlert:(NSString *)message
   cancelBtnTitle:(NSString *)cBtnTitle
    otherBtnTitle:(NSString *)oBtnTitle
              tag:(int)tag;
@end

@implementation RCUSettingsTableViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger row = 0;
    if (0 == section) {
        row = 2;
    } else if (1 == section) {
        row = 2;
    } else if (2 == section) {
        row = 1;
    } else if (3 == section) {
        row = 1;
    }
    return row;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section > 1) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
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
            text = RCDLocalizedString(@"new_message_notification");
        } else if (1 == indexPath.row) {
            text = RCDLocalizedString(@"push_setting");
        }
    } else {
         if (indexPath.row == 0) {
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
            RCDMessageNotifySettingTableViewController *vc = [[RCDMessageNotifySettingTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (1 == indexPath.row) {
            RCDPushSettingViewController *vc = [[RCDPushSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (1 == indexPath.section) {
        if (indexPath.row == 0) {
            //清除缓存
            [super showAlert:RCDLocalizedString(@"clear_cache_alert")
              cancelBtnTitle:RCDLocalizedString(@"cancel")
               otherBtnTitle:RCDLocalizedString(@"confirm")
                         tag:1011];
        } else {
            RCDCleanChatHistoryViewController *cleanVC = [[RCDCleanChatHistoryViewController alloc] init];
            [self.navigationController pushViewController:cleanVC animated:YES];
        }
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
@end
