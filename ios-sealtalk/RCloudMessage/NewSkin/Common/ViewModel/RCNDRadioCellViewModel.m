//
//  RCNDRadioCellCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDRadioCellViewModel.h"
#import "RCNDRadioCell.h"

@implementation RCNDRadioCellViewModel

- (instancetype)initWithTapBlock:(RCNDCommonCellViewModelBlock)tapBlock {
    self = [super initWithTapBlock:tapBlock];
    self.hideArrow = YES;
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDRadioCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDRadioCellIdentifier
                                                                          forIndexPath:indexPath];
    cell.hideSeparatorLine = self.hideSeparatorLine;
    [cell updateWithViewModel:self];
    return cell;
}
@end
