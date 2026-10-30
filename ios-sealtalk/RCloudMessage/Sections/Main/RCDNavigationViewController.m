//
//  RCDNavigationViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDNavigationViewController.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
#import "RCDSemanticContext.h"
#import <RongIMKit/RongIMKit.h>
@interface RCDNavigationViewController ()

@end

@implementation RCDNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([RCDSemanticContext isRTL]) {
        self.view.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        self.navigationBar.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
//    self.view.backgroundColor = RCDynamicColor(@"auxiliary_background_1_color", @"0xFFFFFF", @"0x000000");
//  
//    // 设置导航栏透明
//    [self setupTransparentNavigationBar];

    __weak RCDNavigationViewController *weakSelf = self;

    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;

        self.delegate = weakSelf;

        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)setupTransparentNavigationBar {
    if (@available(iOS 15.0, *)) {
        // iOS 15+ 使用 UINavigationBarAppearance
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithTransparentBackground]; // 透明背景
        // 如果需要完全透明（包括模糊效果也去掉）
        appearance.backgroundColor = [UIColor clearColor];
        appearance.shadowColor = [UIColor clearColor]; // 去掉底部分割线
        
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        // iOS 15 以下版本
        [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [[UIImage alloc] init]; // 去掉底部分割线
        self.navigationBar.translucent = YES; // 设置为半透明
        self.navigationBar.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    if (self.childViewControllers.count==1) {
            viewController.hidesBottomBarWhenPushed = YES; //viewController是将要被push的控制器
        }
    [super pushViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }

    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return [super popToViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.interactivePopGestureRecognizer] && self.viewControllers.count > 1 &&
        [self.visibleViewController isEqual:[self.viewControllers lastObject]]) {
        //判断当导航堆栈中存在页面，并且可见视图如果不是导航堆栈中的最后一个视图时，就会屏蔽掉滑动返回的手势。此设置是为了避免页面滑动返回时因动画存在延迟所导致的卡死。
        return YES;
    } else {
        return NO;
    }
}

@end
