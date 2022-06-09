//
//  RCDAlertBuilder.m
//  SealTalk
//
//  Created by lizhipeng on 2022/5/19.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDAlertBuilder.h"

@implementation RCDAlertBuilder

+ (void )showFraudPreventionRejectAlert {
    NSString *alertTitle= RCDLocalizedString(@"Fraud_Prevention_Alert_Tips");
    NSString *alertSender= RCDLocalizedString(@"Fraud_Prevention_Alert_Phone");
    NSString *alertMessage= RCDLocalizedString(@"Fraud_Prevention_Alert_Time");
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        RCDAlertController *alertController = [RCDAlertController
                                               alertControllerWithTitle:alertTitle
                                               message:alertMessage
                                               withSender:alertSender
                                               handler:^(UIButton * _Nonnull sender) {
            [weakSelf callWithTelpromptNumber:alertSender];
        }];
        
        [alertController addAction:[RCDAlertAction actionWithTitle:RCDLocalizedString(@"confirm") handler:^(RCDAlertAction * _Nonnull action) {}]];
        
        UIViewController *presentController = [self getCurrentVC] ;
        [presentController presentViewController:alertController animated:YES completion:nil];
    }) ;
}

+ (void)callWithTelpromptNumber:(NSString *)number {
    NSString *numberCheck = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSMutableString  *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@" , numberCheck];
    NSURL *callUrl = [NSURL URLWithString:str] ;
    [[UIApplication sharedApplication] openURL:callUrl options:@{} completionHandler:nil];
}

+ (UIViewController *)getCurrentVC {
    UIViewController*result =nil;
    UIWindow* window = [[UIApplication sharedApplication]keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray*windows = [[UIApplication sharedApplication]windows];
        for(UIWindow* tmpWin in windows){
            if(tmpWin.windowLevel==UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController*rootVC = window.rootViewController;
    id nextResponder= [rootVC.view nextResponder];
    if([nextResponder isKindOfClass:[UINavigationController class]]) {
        result = ((UINavigationController*)nextResponder).topViewController;
        if([result isKindOfClass:[UITabBarController class]]) {
            result = ((UITabBarController*)result).selectedViewController;
        }
    }else if([nextResponder isKindOfClass:[UITabBarController class]]) {
        result = ((UITabBarController*)nextResponder).selectedViewController;
        if([result isKindOfClass:[UINavigationController class]]) {
            result = ((UINavigationController*)result).topViewController;
        }
    } else if([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
        if([result isKindOfClass:[UINavigationController class]]) {
            result = ((UINavigationController*)result).topViewController;
            if([result isKindOfClass:[UITabBarController class]]) {
                result = ((UITabBarController*)result).selectedViewController;
            }
        } else if([result isKindOfClass:[UIViewController class]]) {
            result = nextResponder;
        }
    }
    return result;
}

@end
