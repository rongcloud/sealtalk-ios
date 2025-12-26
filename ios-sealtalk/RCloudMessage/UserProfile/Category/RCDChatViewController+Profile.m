//
//  RCDChatViewController+Profile.m
//  SealTalk
//
//  Created by RobinCui on 2024/8/31.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCDChatViewController+Profile.h"
#import <objc/runtime.h>
#import <RongIMKit/RongIMKit.h>

@interface RCConversationViewController ()
- (void)didTapCellPortrait:(NSString *)userId;
@end

@implementation RCDChatViewController (Profile)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(didTapCellPortrait:));
        Method swizzlingMethod = class_getInstanceMethod(self, @selector(ext_didTapCellPortrait:));
        BOOL isAdded = class_addMethod([self class], method_getName(originalMethod), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        if (isAdded){
            //添加成功说明方法在原类中不存在，用下面的方法替换其实现");
            class_replaceMethod([self class], method_getName(originalMethod), method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzlingMethod);
        }
    });
}

- (void)ext_didTapCellPortrait:(NSString *)userId {
    if ([RCIM sharedRCIM].currentDataSourceType == RCDataSourceTypeInfoManagement) {
        [super didTapCellPortrait:userId];
    } else {
        [self ext_didTapCellPortrait:userId];
    }
}
@end
