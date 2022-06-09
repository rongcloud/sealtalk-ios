//
//  RCDViewController.h
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDAlertAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title
                                 message:(nullable NSString *)message
                              withSender:(NSString *)sender
                                 handler:(void (^ __nullable)(UIButton *sender))handler ;

- (void)addAction:(RCDAlertAction *)action ;
@property (nonatomic, readonly) NSArray<RCDAlertAction *> *actions;

@property (nullable, nonatomic, copy) NSString *alertTitle;
@property (nullable, nonatomic, copy) NSString *alertMessage;
@property (nullable, nonatomic, copy) NSString *alertSender;

@end

NS_ASSUME_NONNULL_END
