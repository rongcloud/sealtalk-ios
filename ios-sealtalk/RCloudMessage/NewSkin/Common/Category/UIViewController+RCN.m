//
//  UIViewController+RCN.m
//  SealTalk
//
//  Created by RobinCui on 2025/8/29.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "UIViewController+RCN.h"
#import <RongIMKit/RongIMKit.h>

@implementation UIViewController (RCN)


- (void)rcn_configureTransparentNavigationBar {
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    if (@available(iOS 15.0, *)) {
        // iOS 15+ 使用新的 UINavigationBarAppearance API
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithTransparentBackground];
        appearance.shadowColor = [UIColor clearColor]; // 去掉底部分割线

        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = appearance;
        navBar.compactAppearance = appearance;
        navBar.compactScrollEdgeAppearance = appearance;
    } else {
        // iOS 15 以下使用传统方式
        [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [navBar setShadowImage:[UIImage new]];
        navBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    }
    
    navBar.translucent = YES;
    navBar.tintColor = [UIColor whiteColor];
    
    // 强制更新导航栏外观
    [navBar setNeedsLayout];
    [navBar layoutIfNeeded];
}


- (void)rcn_restoreDefaultNavigationBarAppearance {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    // 设置 navigationbar 背景色
    UIColor *backgroundColor = RCDynamicColor(@"auxiliary_background_1_color", @"0xf5f6f9", @"0x111111");
    
    if (@available(iOS 15.0, *)) {
        // iOS 15+ 恢复默认外观
        UINavigationBarAppearance *defaultAppearance = [[UINavigationBarAppearance alloc] init];
        [defaultAppearance configureWithDefaultBackground];
        defaultAppearance.shadowColor = [UIColor clearColor]; // 去掉底部分割线
        defaultAppearance.backgroundColor = backgroundColor;

        navBar.standardAppearance = defaultAppearance;
        navBar.scrollEdgeAppearance = defaultAppearance;
        navBar.compactAppearance = defaultAppearance;
        if (@available(iOS 15.0, *)) {
            navBar.compactScrollEdgeAppearance = defaultAppearance;
        }
    } else {
        // iOS 15 以下恢复默认设置
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setShadowImage:nil];
        navBar.titleTextAttributes = nil;
        self.navigationController.navigationBar.barTintColor = backgroundColor;

    }
    
    navBar.translucent = YES; // 保持默认的translucent设置
    navBar.tintColor = nil; // 恢复默认按钮颜色
}

@end
