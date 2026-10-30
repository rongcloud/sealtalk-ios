//
//  RCNDMainTabBarViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCNDMainTabBarViewController : UITabBarController

+ (NSInteger)currentTabBarItemIndex;
@property (nonatomic, assign) NSUInteger selectedTabBarIndex;
- (void)updateBadgeValueForTabBarItem;
@end

NS_ASSUME_NONNULL_END
