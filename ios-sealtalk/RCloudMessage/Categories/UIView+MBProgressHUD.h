//
//  UIView+MBProgressHUD.h
//  SealClass
//
//  Created by liyan on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MBProgressHUD)

@property (weak, nonatomic) MBProgressHUD *HUD;
@property (nonatomic, strong) MBProgressHUD *loadingView;
- (void)showHUDMessage:(NSString *)message;
- (void)showLoading;
- (void)hideLoading;
@end

NS_ASSUME_NONNULL_END
