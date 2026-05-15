//
//  RCDOpenClawBotManager.h
//  SealTalk
//
//  Created by Codex on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCDOpenClawBot;
@class RCUserInfo;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const RCDOpenClawBotInfoDidUpdateNotification;

@interface RCDOpenClawBotManager : NSObject

+ (NSString *)defaultPortraitUri;
+ (NSString *)defaultBotName;
+ (BOOL)isOpenClawBotId:(NSString *)botId;
+ (void)cacheBots:(NSArray<RCDOpenClawBot *> *)bots;
+ (void)cacheBot:(RCDOpenClawBot *)bot;
+ (nullable RCDOpenClawBot *)botWithBotId:(NSString *)botId;
+ (nullable RCUserInfo *)userInfoForBotId:(NSString *)botId;

@end

NS_ASSUME_NONNULL_END
