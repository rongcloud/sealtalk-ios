//
//  RCNDAboutIconCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDAboutIconCellViewModel.h"

@implementation RCNDAboutIconCellViewModel
- (instancetype)initWithTapBlock:(RCNDCommonCellViewModelBlock)tapBlock {
    self = [super init];
    if (self) {
        self.tapBlock = tapBlock;
    }
    return self;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDAboutIconCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDAboutIconCellIdentifier
                                                                          forIndexPath:indexPath];
    return cell;
}


- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 196;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    if (self.tapBlock) {
        self.tapBlock(vc);
    }
}
@end
