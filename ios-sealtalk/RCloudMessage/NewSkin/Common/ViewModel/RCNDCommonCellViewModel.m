//
//  RCNDCommonCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCommonCellViewModel.h"

@interface RCNDCommonCellViewModel()
@end

@implementation RCNDCommonCellViewModel
- (instancetype)initWithTapBlock:(RCNDCommonCellViewModelBlock)tapBlock {
    self = [super init];
    if (self) {
        self.tapBlock = tapBlock;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDCommonCellIdentifier
                                                                          forIndexPath:indexPath];
    cell.hideSeparatorLine = self.hideSeparatorLine;
    [cell updateWithViewModel:self];
    return cell;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    if (self.tapBlock) {
        self.tapBlock(vc);
    }
}
@end
