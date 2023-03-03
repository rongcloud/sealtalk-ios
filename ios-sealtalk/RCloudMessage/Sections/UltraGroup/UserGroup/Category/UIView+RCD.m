//
//  UIView+RCD.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "UIView+RCD.h"

@implementation UIView (RCD)

- (UITextField *)rcd_textFiledWith:(NSString *)placeholder {
    UITextField *txtFiled = [UITextField new];
    txtFiled.placeholder = placeholder;
    txtFiled.borderStyle = UITextBorderStyleRoundedRect;
    return txtFiled;
}

- (UIButton *)rcd_buttonWithTitle:(NSString *)title
                            target:(id __nullable)target
                          selector:(SEL __nullable)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title ?:@"" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (!target) {
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    return btn;
}

- (UIButton *)rcd_buttonWithTitle:(NSString *)title {
    UIButton *btn = [self rcd_buttonWithTitle:title target:nil selector:nil];
    return btn;
}

- (UILabel *)rcd_labelWithText:(NSString *)text font:(UIFont *__nullable)font {
    UILabel *lab = [UILabel new];
    if (font) {
        lab.font = font;
    }
    lab.text = text;
    return lab;
}
- (UILabel *)rcd_labelWithText:(NSString *)text {
    return [self rcd_labelWithText:text font:nil];
}
@end
