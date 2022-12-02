//
//  RCEmojiBoardView+Ext.m
//  SealTalk
//
//  Created by RobinCui on 2022/11/22.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCEmojiBoardView+Ext.h"
#import <objc/runtime.h>
#import "RCDCommonString.h"
@implementation RCEmojiBoardView (Ext)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(addExtensionEmojiTab:));
        Method swizzlingMethod = class_getInstanceMethod([self class], @selector(ext_addExtensionEmojiTab:));
        BOOL isAdded = class_addMethod([self class], method_getName(originalMethod), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        if (isAdded){
            //添加成功说明方法在原类中不存在，用下面的方法替换其实现");
            class_replaceMethod([self class], method_getName(originalMethod), method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzlingMethod);
        }
    });
}

- (void)ext_addExtensionEmojiTab:(id<RCEmoticonTabSource>)viewDataSource {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugDisableSystemEmoji] boolValue];
    if (!enable) {
        [self ext_addExtensionEmojiTab:viewDataSource];
    }
}
@end
