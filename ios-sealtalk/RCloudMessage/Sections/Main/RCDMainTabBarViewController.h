//
//  RCDMainTabBarViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/7/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDMainTabBarViewController : UITabBarController <UITabBarControllerDelegate>

+ (NSInteger)currentTabBarItemIndex;
+ (id)mainTabBarViewController;
@property (nonatomic, assign) NSUInteger selectedTabBarIndex;
- (void)updateBadgeValueForTabBarItem;
@end
