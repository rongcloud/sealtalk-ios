//
//  RCDUltraGroupNotificationMessage.m
//  SealTalk
//
//  Created by 张改红 on 2022/1/26.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUltraGroupNotificationMessage.h"

NSString * const RCDUltraGroupDismiss = @"Dismiss";

@implementation RCDUltraGroupNotificationMessage
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED;
}

- (void)decodeWithData:(NSData *)data {
    __autoreleasing NSError *__error = nil;
    if (!data) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&__error];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (!__error && dict) {
        self.operation = [dict objectForKey:@"operation"];
    }
}

+ (NSString *)getObjectName{
    return RCDUltraGroupNotificationMessageIdentifier;
}
@end
