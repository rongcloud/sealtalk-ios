//
//  RCDChatViewController+Alert.m
//  SealTalk
//
//  Created by RobinCui on 2022/6/14.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDChatViewController+Alert.h"
#import <objc/runtime.h>
#import "NormalAlertView.h"

@implementation RCDChatViewController (Alert)
+ (void)load{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        SEL orginSel = @selector(didTapMessageCell:);
        SEL overrideSel = @selector(alert_didTapMessageCell:);
        
        Method originMethod = class_getInstanceMethod([self class], orginSel);
        Method overrideMethod = class_getInstanceMethod([self class], overrideSel);
        
        //原来的类没有实现指定的方法，那么我们就得先做判断，把方法添加进去，然后进行替换
        if (class_addMethod([self class], orginSel, method_getImplementation(overrideMethod) , method_getTypeEncoding(originMethod))) {
            class_replaceMethod([self class],
                                overrideSel,
                                method_getImplementation(originMethod),
                                method_getTypeEncoding(originMethod));
        }else{
            //交换实现
            method_exchangeImplementations(originMethod, overrideMethod);
        }
    });
}

- (BOOL)alert_isDebugEnable {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *val = [userDefault valueForKey:@"RCDDebugInputKeyboardUIKey"];
    return [val boolValue];
}

- (void)alert_showAlert {
    [RCAlertView showAlertController:@"AlertVIew"
                             message:@"输入框即将丢失第一响应者, 键盘收起"
                         cancelTitle:RCDLocalizedString(@"confirm")];

}

- (void)alert_didTapMessageCell:(RCMessageModel *)model {
    [self alert_didTapMessageCell:model];
    if ([self alert_isDebugEnable]) {
        [self alert_showAlert];
    }
}
@end
