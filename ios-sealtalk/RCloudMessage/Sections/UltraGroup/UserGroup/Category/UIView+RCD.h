//
//  UIView+RCD.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (RCD)
- (UITextField *)rcd_textFiledWith:(NSString *)placeholder;
- (UIButton *)rcd_buttonWithTitle:(NSString *)title
                            target:(id __nullable)target
                         selector:(SEL __nullable)selector;
- (UIButton *)rcd_buttonWithTitle:(NSString *)title;
- (UILabel *)rcd_labelWithText:(NSString *)text font:(UIFont *__nullable)font;
- (UILabel *)rcd_labelWithText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
