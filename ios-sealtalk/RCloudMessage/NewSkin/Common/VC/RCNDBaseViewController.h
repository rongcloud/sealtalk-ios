//
//  RCNDBaseViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "UIView+MBProgressHUD.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDBaseViewController : RCBaseViewController
- (void)pushViewController:(UIViewController *)controller;
- (void)setupView;
- (void)configureLeftBackButton;
- (void)leftBarButtonBackAction;
- (void)showLoading;
- (void)hideLoading;
- (void)showTips:(NSString *)tips;
- (void)configureTransparentNavigationBar;
- (void)restoreDefaultNavigationBarAppearance;
@end

NS_ASSUME_NONNULL_END
