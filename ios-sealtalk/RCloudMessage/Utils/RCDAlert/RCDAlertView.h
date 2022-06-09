//
//  RCDAlertView.h
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RCDAlertView ;
@class RCDAlertAction ;

@protocol RCDAlertViewDelegate <NSObject>

/* 点击sender */
- (void)RCDAlertView:(RCDAlertView *)alertView selectSenderButton:(UIButton *)action ;
/* 点击action */
- (void)RCDAlertView:(RCDAlertView *)alertView selectAlertAction:(RCDAlertAction *)action ;

@end

@interface RCDAlertView : UIView

@property(nonatomic, weak) id<RCDAlertViewDelegate>delegate ;

- (instancetype)initWithTitle:(NSString *)title withMessage:(NSString *)message withSender:(NSString *)sender ;
- (void)addActions:(NSArray<RCDAlertAction *> *)actions ;

@end

NS_ASSUME_NONNULL_END
