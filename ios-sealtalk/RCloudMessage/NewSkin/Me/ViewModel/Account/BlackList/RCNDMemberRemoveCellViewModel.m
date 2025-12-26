//
//  RCNDMemberRemoveCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMemberRemoveCellViewModel.h"

@implementation RCNDMemberRemoveCellViewModel

- (instancetype)initWithTapBlock:(RCNDCommonCellViewModelBlock)tapBlock {
    self = [super initWithTapBlock:tapBlock];
    if (self) {
        self.hideArrow = YES;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDMemberRemoveCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDMemberRemoveCellIdentifier
                                                                          forIndexPath:indexPath];
    cell.hideSeparatorLine = self.hideSeparatorLine;
    [cell updateWithViewModel:self];
    return cell;
}

- (void)actonButtonClick {
    if (self.tapBlock) {
        self.tapBlock(nil);
    }
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    
}
@end
