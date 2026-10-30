//
//  RCNDSScanView.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseView.h"

NS_ASSUME_NONNULL_BEGIN


@interface RCNDScannerView : RCNDBaseView
@property (nonatomic, strong) UIButton *selectImageBtn;;
/** 添加扫描线条动画 */
- (void)rcd_addScannerLineAnimation;

/** 暂停扫描线条动画 */
- (void)rcd_pauseScannerLineAnimation;

/** 添加指示器 */
- (void)rcd_addActivityIndicator;

/** 移除指示器 */
- (void)rcd_removeActivityIndicator;

- (CGFloat)scanner_x;
- (CGFloat)scanner_y;
- (CGFloat)scanner_width;

/**
 显示手电筒
 @param animated 是否附带动画
 */
- (void)rcd_showFlashlightWithAnimated:(BOOL)animated;

/**
 隐藏手电筒
 @param animated 是否附带动画
 */
- (void)rcd_hideFlashlightWithAnimated:(BOOL)animated;

/**
 设置手电筒开关
 @param on YES:开  NO:关
 */
- (void)rcd_setFlashlightOn:(BOOL)on;

/**
 获取手电筒当前开关状态
 @return YES:开  NO:关
 */
- (BOOL)rcd_flashlightOn;

@end

NS_ASSUME_NONNULL_END
