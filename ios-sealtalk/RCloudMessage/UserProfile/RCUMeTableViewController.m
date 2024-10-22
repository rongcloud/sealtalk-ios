//
//  RCUMeTableViewController.m
//  SealTalk
//
//  Created by RobinCui on 2024/8/29.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUMeTableViewController.h"
#import "RCUSettingsTableViewController.h"
@interface RCUMeTableViewController ()

@end

@implementation RCUMeTableViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (0 == section) {
        rows = 1;
    } else if (1 == section) {
        rows = 0;
    } else if (2 == section) {
        rows = 3;
#ifdef RCD_SHOW_PROXYSETTING
        rows = 4;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (2 == indexPath.section) {
        if (0 == indexPath.row) {
            RCUSettingsTableViewController *vc = [[RCUSettingsTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    } 
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

}
@end
