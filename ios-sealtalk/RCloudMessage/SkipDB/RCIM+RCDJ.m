//
//  RCIM+RCDJ.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCIM+RCDJ.h"
#import "RCJDMessageContext.h"
#import <objc/runtime.h>

@implementation RCIM (RCDJ)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self switchSendMessage];
        [self switchSendMediaMessage];
    });
}



+ (void)switchSendMediaMessage {
    Method originalMethod = class_getInstanceMethod([self class], @selector(sendMediaMessage:pushContent:pushData:progress:successBlock:errorBlock:cancel:));
    Method swizzlingMethod = class_getInstanceMethod([self class], @selector(rcdj_sendMediaMessage:pushContent:pushData:progress:successBlock:errorBlock:cancel:));
    BOOL isAdded = class_addMethod([self class], method_getName(originalMethod), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    if (isAdded){
        //添加成功说明方法在原类中不存在，用下面的方法替换其实现");
        class_replaceMethod([self class], method_getName(originalMethod), method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzlingMethod);
    }
}

- (RCMessage *)rcdj_sendMediaMessage:(RCMessage *)message
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                       progress:(void (^)(int progress, RCMessage *progressMessage))progressBlock
                   successBlock:(void (^)(RCMessage *successMessage))successBlock
                     errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock
                         cancel:(void (^)(RCMessage *cancelMessage))cancelBlock {
    RCMessage *msg = [self rcdj_sendMediaMessage:message
                                     pushContent:pushContent
                                        pushData:pushData
                                        progress:progressBlock
                                    successBlock:successBlock
                                      errorBlock:errorBlock
                                          cancel:cancelBlock];
    [RCJDMessageContext saveMessage:msg];
    return msg;
}


+ (void)switchSendMessage {
    Method originalMethod = class_getInstanceMethod([self class], @selector(sendMessage:pushContent:pushData:successBlock:errorBlock:));
    Method swizzlingMethod = class_getInstanceMethod([self class], @selector(rcdj_sendMessage:pushContent:pushData:successBlock:errorBlock:));
    BOOL isAdded = class_addMethod([self class], method_getName(originalMethod), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    if (isAdded){
        //添加成功说明方法在原类中不存在，用下面的方法替换其实现");
        class_replaceMethod([self class], method_getName(originalMethod), method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzlingMethod);
    }
}
- (RCMessage *)rcdj_sendMessage:(RCMessage *)message
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
              successBlock:(void (^)(RCMessage *successMessage))successBlock
                errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock {
    RCMessage *msg = [self rcdj_sendMessage:message
                                pushContent:pushContent
                                   pushData:pushData
                               successBlock:successBlock
                                 errorBlock:errorBlock];
    [RCJDMessageContext saveMessage:msg];
    return msg;
}
@end
