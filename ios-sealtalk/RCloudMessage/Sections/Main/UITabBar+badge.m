//
//  UITabBar+badge.m
//  RCloudMessage
//
//  Created by Jue on 16/7/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "UITabBar+badge.h"
#define TabbarItemNums 4.0
#import "RCDTabBarBtn.h"
#import "UIColor+RCColor.h"
#import "RCDCommonDefine.h"
#import <objc/runtime.h>

#define RCDTabBarButtonTagFrom 888

@implementation UITabBar (badge)
- (void)bringBadgeToFrontOnItemIndex:(int)index {
    NSInteger tag = RCDTabBarButtonTagFrom + index;
    RCDTabBarBtn *badge = [self viewWithTag:tag];
    if (badge) {
        [badge removeFromSuperview];
        [self addSubview:badge];
    }
}

- (void)showBadgeOnItemIndex:(int)index {
    [self showBadgeOnItemIndex:index badgeValue:0];
}

- (void)showBadgeOnItemIndex:(int)index badgeValue:(int)badgeValue {
    [self showBadgeOnItemIndex:index badgeValue:badgeValue userInteractionEnabled:YES];
}

- (void)showBadgeOnItemIndex:(int)index badgeValue:(int)badgeValue userInteractionEnabled:(BOOL)enable {
    NSInteger tag = RCDTabBarButtonTagFrom + index;
    RCDTabBarBtn *badge = [self viewWithTag:tag];
    CGRect decideFrame;
    CGRect tabFrame = self.frame;
    if (RCD_IS_IPHONEX) {
        tabFrame.size.height = 49.0 + 34.0;
    } else {
        tabFrame.size.height = 49.0;
    }
    CGRect itemsFrame = [self getTabBarItemFrame:index];
    if (CGRectIsEmpty(itemsFrame)) {// 老版本xcode编译到iOS26， 按照原有方式遍历
        if (@available(iOS 26.0, *)) { // iOS26改变试图层级， 需要特殊处理
            itemsFrame = [self getTabBarItemFrameForIOS26:index];
        }
    }
   

    CGFloat x = itemsFrame.origin.x + itemsFrame.size.width/2 + 4;
    CGFloat y = 3;
    if (badgeValue > 0) {
        CGFloat width = 16;
        if (badgeValue >= 10 && badgeValue < 100) {
            width = 22;
        } else if (badgeValue >= 100 && badgeValue < 1000) {
            width = 30;
        }
        decideFrame = CGRectMake(x, y, width, 16);
        if (@available(iOS 26.0, *)) {// iOS 26 做特别偏移
            CGFloat offset = 0;
            for (UIView *view in self.subviews) {
                NSString *className = NSStringFromClass(view.class);
                if ([className containsString:@"TabBarPlatterView"]) {
                    offset = view.frame.origin.x;
                    decideFrame = CGRectMake(x+offset, y+4, width, 16);
                    break;
                }
            }
          }
    } else {
        decideFrame = CGRectMake(x, y, 10, 10);
    }
    if (!badge) {
        badge = [[RCDTabBarBtn alloc] initWithFrame:decideFrame];
        badge.tag = tag;
        [self addSubview:badge];
    }
    [badge setFrame:decideFrame];
    badge.layer.cornerRadius = badge.frame.size.height / 2;
    badge.hidden = NO;
    if (badgeValue) {
        badge.userInteractionEnabled = enable;
        if (badgeValue <= 99) {
            badge.unreadCount = [NSString stringWithFormat:@"%d", badgeValue];
        } else if (badgeValue > 99 && badgeValue < 1000) {
            badge.unreadCount = [NSString stringWithFormat:@"99+"];
        } else {
            badge.unreadCount = [NSString stringWithFormat:@"···"];
        }
    } else {
        badge.userInteractionEnabled = NO;
        badge.unreadCount = @"";
    }
}

//隐藏小红点
- (void)hideBadgeOnItemIndex:(int)index {
    RCDTabBarBtn *badge = [self viewWithTag:RCDTabBarButtonTagFrom + index];
    badge.hidden = YES;
}

#pragma mark - privite
- (CGRect)getTabBarItemFrameForIOS26:(NSInteger)targetIndex {
    if (targetIndex == NSNotFound) {
        return CGRectZero;
    }
    
    // 递归查找所有UITabBarButton
    NSMutableArray<UIView *> *tabButtons = [NSMutableArray array];
    [self findTabButtonsInView:self intoArray:tabButtons];
    
    if (targetIndex < tabButtons.count) {
        return tabButtons[targetIndex].frame;
    }
    
    return CGRectZero;
}

- (void)findTabButtonsInView:(UIView *)view intoArray:(NSMutableArray<UIView *> *)array {
    for (UIView *subview in view.subviews) {
        NSString *className = NSStringFromClass([subview class]);
        NSString *targetName = @"TabBarButton";
        if (@available(iOS 26.0, *)) {
            targetName = @"TabButton";
        }
        if ([className containsString:targetName]) {
            [array addObject:subview];
        } else {
            [self findTabButtonsInView:subview intoArray:array];
        }
    }
}

- (CGRect)getTabBarItemFrame:(NSInteger)index{
  
    NSInteger i = 0;
    CGRect itemFrame = CGRectZero;
    for (UIView *view in self.subviews) {
        if (![NSStringFromClass([view class]) isEqualToString:@"UITabBarButton"]) {
            continue;
        }
        //找到指定的tabBarItem
        if (index == i++) {
            itemFrame = view.frame;
            break;
        }
    }
    return itemFrame;
}
@end
