//
//  RCDUIBarButtonItem.m
//  RCloudMessage
//
//  Created by Jue on 16/8/24.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDUIBarButtonItem.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDSemanticContext.h"

@interface RCDUIBarButtonItem ()

@property (nonatomic, strong) UILabel *titleText;

@end

@implementation RCDUIBarButtonItem
+ (NSArray *)getLeftBarButton:(NSString *)title target:(id)target action:(SEL)method {
    UIImage *img = [UIImage imageNamed:@"navigator_btn_back"];
    img = [RCDSemanticContext imageflippedForRTL:img];
    return [RCKitUtility getLeftNavigationItems:img title:nil target:target action:method];
}

//初始化包含图片的UIBarButtonItem
- (RCDUIBarButtonItem *)initContainImage:(UIImage *)buttonImage target:(id)target action:(SEL)method {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:buttonImage
         forState:UIControlStateNormal];
    [btn addTarget:target
            action:method
  forControlEvents:UIControlEventTouchUpInside];
    self = [super initWithCustomView:btn];
    self.button = btn;
    return self;
}

//初始化不包含图片的UIBarButtonItem
- (RCDUIBarButtonItem *)initWithbuttonTitle:(NSString *)buttonTitle
                                 titleColor:(UIColor *)titleColor
                                buttonFrame:(CGRect)buttonFrame
                                     target:(id)target
                                     action:(SEL)method {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
    self = [super initWithCustomView:button];
    self.button = button;
    self.customView = self.button;
    return self;
}

//设置UIBarButtonItem是否可以被点击和对应的颜色
- (void)buttonIsCanClick:(BOOL)isCanClick
             buttonColor:(UIColor *)buttonColor
           barButtonItem:(RCDUIBarButtonItem *)barButtonItem {
    if (isCanClick == YES) {
        barButtonItem.customView.userInteractionEnabled = YES;
    } else {
        barButtonItem.customView.userInteractionEnabled = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (buttonColor != nil) {
            if (barButtonItem.titleText != nil) {
                [barButtonItem.titleText setTextColor:buttonColor];
            } else {
                [barButtonItem.button setTitleColor:buttonColor forState:UIControlStateNormal];
                barButtonItem.customView = barButtonItem.button;
            }
        }
    });
}

//平移UIBarButtonItem
- (NSArray<UIBarButtonItem *> *)setTranslation:(UIBarButtonItem *)barButtonItem translation:(CGFloat)translation {
    if (barButtonItem == nil) {
        return nil;
    }

    NSArray<UIBarButtonItem *> *barButtonItems;
    UIBarButtonItem *negativeSpacer =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = translation;

    barButtonItems = [NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil];

    return barButtonItems;
}
@end
