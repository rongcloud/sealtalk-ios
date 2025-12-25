//
//  RCCoreClient+RCDJ.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCCoreClient+RCDJ.h"
#import "RCJDMessageContext.h"
#import <objc/runtime.h>

@implementation RCCoreClient (RCDJ)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(getMessage:));
        Method swizzlingMethod = class_getInstanceMethod([self class], @selector(rcdj_getMessage:));
        BOOL isAdded = class_addMethod([self class], method_getName(originalMethod), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        if (isAdded){
            //添加成功说明方法在原类中不存在，用下面的方法替换其实现");
            class_replaceMethod([self class], method_getName(originalMethod), method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzlingMethod);
        }
    });
}

- (RCMessage *)rcdj_getMessage:(long)messageId; {
    RCMessage * msg = [RCJDMessageContext getMessage:messageId];
    if (!msg) {
        msg = [self rcdj_getMessage:messageId];
    }
    return msg;
}
@end
