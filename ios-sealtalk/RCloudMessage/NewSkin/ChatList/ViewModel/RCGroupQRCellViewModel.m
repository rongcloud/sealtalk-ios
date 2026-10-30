//
//  RCGroupQRCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCGroupQRCellViewModel.h"
#import "RCGroupQRViewCell.h"
#import "RCNDGroupQRViewController.h"
@implementation RCGroupQRCellViewModel

+ (instancetype)viewModelWithGroupId:(NSString *)groupId {
    RCGroupQRCellViewModel *viewModel = [[self.class alloc] init];
    viewModel.groupId = groupId;
    return viewModel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RCGroupQRViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCGroupQRViewCellIdentifier];
    if (!cell) {
        cell = [[RCGroupQRViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RCGroupQRViewCellIdentifier];
    }
    cell.labelTitle.text = RCDLocalizedString(@"GroupQR");
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageViewArrow.hidden = YES;
    cell.imageViewIcon.image = [UIImage imageNamed:@"group_qr_info"];
    cell.hideSeparatorLine = self.hideSeparatorLine;
    return cell;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    RCNDGroupQRViewController *controller = [[RCNDGroupQRViewController alloc] initWithGroupID:self.groupId];
    [vc.navigationController pushViewController:controller animated:YES];
}
@end
