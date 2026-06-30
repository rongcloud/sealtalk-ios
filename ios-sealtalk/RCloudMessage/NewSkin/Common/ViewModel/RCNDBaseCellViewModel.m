//
//  RCNDBaseCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCellViewModel.h"

NSInteger const RCNDBaseCellViewModelCellHeight = 54;

@implementation RCNDBaseCellViewModel
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RCNDBaseCellViewModelCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"子类 %@ 必须重写类方法 +[%@ %@]！",
                NSStringFromClass([self class]),
                NSStringFromClass([self superclass]),
                NSStringFromSelector(_cmd));
    return nil;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    
}
@end
