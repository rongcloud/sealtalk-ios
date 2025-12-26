//
//  RCNDImageCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDImageCellViewModel.h"

@implementation RCNDImageCellViewModel

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDImageCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDImageCellIdentifier
                                                                          forIndexPath:indexPath];
    cell.hideSeparatorLine = self.hideSeparatorLine;
    [cell updateWithViewModel:self];
    return cell;
}
@end
