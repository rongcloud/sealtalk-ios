//
//  RCUMeTableViewController.m
//  SealTalk
//
//  Created by RobinCui on 2024/8/29.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUMeTableViewController.h"
#import "RCUSettingsTableViewController.h"
#import "RCDMeCell.h"
#import "RCDThemesViewController.h"
#import "RCDThemesContext.h"
@interface RCUMeTableViewController ()

@end

@implementation RCUMeTableViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (0 == section) {
        rows = 1;
    } else if (1 == section) {
        rows = 1;
    } else if (2 == section) {
        rows = 4;
#ifdef RCD_SHOW_PROXYSETTING
        rows = 5;
#endif
    } else if (3 == section) {
        rows = 2;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section <= 1) {
        return 0.01;
    }
    return 15.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 3) {
        static NSString *reusableCellWithIdentifier = @"RCDMeCell";
        RCDMeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
        if (cell == nil) {
            cell = [[RCDMeCell alloc] init];
        }
        [cell setCellWithImageName:@"icon_ multilingual"
                         labelName:RCDLocalizedString(@"Themes")
                    rightLabelName:[RCDThemesContext currentThemeTitle]];
        return cell;
    }
   
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (2 == indexPath.section) {
        if (0 == indexPath.row) {
            RCUSettingsTableViewController *vc = [[RCUSettingsTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        } else if (3 == indexPath.row) {
            RCDThemesViewController *vc = [[RCDThemesViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

}
@end
