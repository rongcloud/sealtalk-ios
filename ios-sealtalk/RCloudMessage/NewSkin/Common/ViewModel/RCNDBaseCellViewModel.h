//
//  RCNDBaseCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const RCNDBaseCellViewModelCellHeight;

@interface RCNDBaseCellViewModel : NSObject
@property (nonatomic, assign) BOOL hideSeparatorLine;

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)itemDidSelectedByViewController:(UIViewController *)vc;
@end

NS_ASSUME_NONNULL_END
