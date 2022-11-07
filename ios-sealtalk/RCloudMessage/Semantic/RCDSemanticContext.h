//
//  RCDSemanticContext.h
//  SealTalk
//
//  Created by RobinCui on 2022/9/7.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDSemanticContext : NSObject
+ (BOOL)isRTL;
+ (void)configureAttributeForNavigationController:(UINavigationController *)navi;
+ (UIImage *)imageflippedForRTL:(UIImage *)image;
+ (CGRect)modifyFrameForRTL:(CGRect)frame toX:(CGFloat)x;
+ (void)swapFrameForRTL:(UIView *)firstView withView:(UIView *)secondView;
+ (void)subViewOfScrollViewFlippedForRTL:(UIView *)subView;
+ (void)scrollViewFlippedForRTL:(UIScrollView *)scrollView;
+ (UICollectionViewFlowLayout *)collectionViewFlowLayout;

@end

NS_ASSUME_NONNULL_END
