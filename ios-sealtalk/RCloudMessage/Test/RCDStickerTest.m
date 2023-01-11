//
//  RCDStickerTest.m
//  SealTalk
//
//  Created by RobinCui on 2022/12/7.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDStickerTest.h"

@implementation RCDStickerTest

+ (void)testWithSelector:(SEL)selector {
    Class cls = NSClassFromString(@"RCStickerDataManager");
    id obj = [cls performSelector:@selector(sharedManager)];
    NSMethodSignature *signature = [obj methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = obj;
    [invocation invoke];
    
}

+ (void)test {
    SEL sel = NSSelectorFromString(@"fillMemoryCacheData");
    [self testWithSelector:sel max:100];
    
    sel = NSSelectorFromString(@"syncPackagesConfig");
    [self testWithSelector:sel max:100];
    
    sel = NSSelectorFromString(@"handleIconAndCover");
    [self testWithSelector:sel max:100];
    
    sel = NSSelectorFromString(@"handlePreloadPackages");
    [self testWithSelector:sel max:100];
}


+ (void)testWithSelector:(SEL)selector max:(int)max{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i<max; i++) {
        dispatch_async(queue, ^{
            [self testWithSelector:selector];
        });
    }
}
@end
