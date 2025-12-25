//
//  RCJDMessageContext.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCJDMessageContext : RCBaseView
+ (RCMessage *)getMessage:(long)messageId;
+ (void)saveMessage:(RCMessage *)message;

@end

NS_ASSUME_NONNULL_END
