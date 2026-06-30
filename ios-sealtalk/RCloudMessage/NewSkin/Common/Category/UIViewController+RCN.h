//
//  UIViewController+RCN.h
//  SealTalk
//
//  Created by RobinCui on 2025/8/29.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (RCN)
- (void)rcn_configureTransparentNavigationBar;
- (void)rcn_restoreDefaultNavigationBarAppearance;
@end

NS_ASSUME_NONNULL_END
