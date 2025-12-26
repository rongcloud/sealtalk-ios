//
//  RCCallKitExtensionModule+Temp.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/23.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCCallKitExtensionModule+Temp.h"
#import <RongIMKit/RongIMKit.h>
#import <objc/runtime.h>
#import "RCDCommonString.h"
#warning RTC 实现用户托管后移除该类
@implementation RCCallKitExtensionModule (Temp)
- (NSArray<RCExtensionPluginItemInfo *> *)tmp_getPluginBoardItemInfoList:(RCConversationType)conversationType
                                                            targetId:(NSString *)targetId {
    if (conversationType == ConversationType_PRIVATE) {
        return [self tmp_getPluginBoardItemInfoList:conversationType targetId:targetId];
    }
    return @[];
}


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(getPluginBoardItemInfoList:targetId:));
        Method swizzlingMethod = class_getInstanceMethod([self class], @selector(tmp_getPluginBoardItemInfoList:targetId:));
        BOOL isAdded = class_addMethod([self class], method_getName(originalMethod), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        if (isAdded){
            //添加成功说明方法在原类中不存在，用下面的方法替换其实现");
            class_replaceMethod([self class], method_getName(originalMethod), method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzlingMethod);
        }
    });
}

@end
