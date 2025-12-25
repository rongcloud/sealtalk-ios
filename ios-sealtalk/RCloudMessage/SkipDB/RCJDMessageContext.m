//
//  RCJDMessageContext.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCJDMessageContext.h"
#import "RCIMDJThreadLock.h"

@interface RCJDMessageContext()
@property (nonatomic, strong) RCIMDJThreadLock *lock;
@property (nonatomic, strong) NSMapTable<NSNumber *, RCMessage *> *cacheInfo;
@end

@implementation RCJDMessageContext

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lock = [[RCIMDJThreadLock alloc] init];
        self.cacheInfo =  [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];;
    }
    return self;
}

+ (RCMessage *)getMessage:(long)messageId {
    return [[RCJDMessageContext sharedInstance] getMessage:messageId];;
}
+ (void)saveMessage:(RCMessage *)message {
    return [[RCJDMessageContext sharedInstance] saveMessage:message];;
}


- (RCMessage *)getMessage:(long)messageId {
    __block RCMessage *msg = nil;
    [self.lock performReadLockBlock:^{
            msg = [self.cacheInfo objectForKey:@(messageId)];
    }];
    return msg;
}

- (void)saveMessage:(RCMessage *)message {
    if (!message) {
        return;
    }
    if (message.conversationType != ConversationType_CHATROOM) {
        return;
    }
    [self.lock performWriteLockBlock:^{
        [self.cacheInfo setObject:message forKey:@(message.messageId)];
    }];
}
@end
