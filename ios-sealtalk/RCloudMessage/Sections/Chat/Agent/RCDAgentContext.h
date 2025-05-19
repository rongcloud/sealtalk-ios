//
//  RCDAgentContext.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCDAgentTag.h"
NS_ASSUME_NONNULL_BEGIN
extern NSString * const RCDAgentEnableKey;
extern NSString * const RCDAgentMessageAuthKey;
@interface RCDAgentContext : NSObject
+ (BOOL)isAbilityValidForKey:(NSString *)key;
+ (void)updateAbilityFor:(NSString *)key result:(BOOL)result;

/// 标签列表
+ (NSArray *)agentTags;

/// 更新标签列表
/// - Parameter tags: 标签
+ (void)saveAgentTags:(NSArray<NSDictionary *>*)tags;


/// 按照会话取标签
/// - Parameter identifier: 会话
+ (RCDAgentTag *)agentTagFor:(RCConversationIdentifier *)identifier;

/// 按照会话保存标签
/// - Parameter tag: 标签
/// - Parameter identifier: 会话
+ (void)saveAgentTag:(RCDAgentTag *)tag forIdentifier:(RCConversationIdentifier *)identifier;
@end

NS_ASSUME_NONNULL_END
