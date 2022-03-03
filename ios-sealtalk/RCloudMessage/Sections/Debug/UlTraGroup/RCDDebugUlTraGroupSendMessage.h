//
//  RCDDebugUltraGroupSendMessage.h
//  SealTalk
//
//  Created by zafer on 2021/12/28.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDDebugUltraGroupSendMessage : NSObject
+ (void)sendMessage:(NSString *)text conversationType:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;
@end

NS_ASSUME_NONNULL_END
