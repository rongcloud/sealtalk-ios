//
//  RCNDContactCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDContactCellViewModel.h"
#import "RCNDContactCell.h"

@interface RCNDContactCellViewModel()
@property (nonatomic, weak) RCNDContactCell *cell;

@end
@implementation RCNDContactCellViewModel
- (instancetype)initWithFriendInfo:(RCFriendInfo *)info {
    self = [super initWithTapBlock:nil];
    if (self) {
        self.hideArrow = YES;
        self.info = info;
        self.displayName = info.remark.length > 0 ? info.remark : info.name;
    }
    return self;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDContactCellIdentifier
                                                                          forIndexPath:indexPath];
    cell.hideSeparatorLine = self.hideSeparatorLine;
    [cell updateWithViewModel:self];
    self.cell = cell;
    return cell;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    self.selected = !self.selected;
    [self.cell refreshState:self];
}

- (void)cellViewModelUnselected {
    self.selected = NO;
    [self.cell refreshState:self];
}
@end
