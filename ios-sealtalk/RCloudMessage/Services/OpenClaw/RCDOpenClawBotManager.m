//
//  RCDOpenClawBotManager.m
//  SealTalk
//
//  Created by RC on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotManager.h"
#import "RCDOpenClawBot.h"
#import <RongIMKit/RongIMKit.h>

NSString *const RCDOpenClawBotInfoDidUpdateNotification = @"RCDOpenClawBotInfoDidUpdateNotification";

static NSString *const RCDOpenClawDefaultPortraitUri = @"https://static.rongcloud.cn/avatar/claw.png";
static NSString *const RCDOpenClawBotIdPrefix = @"Claw_";
static NSString *const RCDOpenClawRefreshConversationListNotification = @"RefreshConversationList";

@implementation RCDOpenClawBotManager

+ (NSMutableDictionary<NSString *, RCDOpenClawBot *> *)botCache {
    static NSMutableDictionary *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary dictionary];
    });
    return cache;
}

+ (NSString *)defaultPortraitUri {
    return RCDOpenClawDefaultPortraitUri;
}

+ (NSString *)defaultBotName {
    return RCDLocalizedString(@"OpenClawBotDefaultName");
}

+ (BOOL)isOpenClawBotId:(NSString *)botId {
    if (botId.length == 0) {
        return NO;
    }
    return [self botCache][botId] != nil || [botId hasPrefix:RCDOpenClawBotIdPrefix];
}

+ (void)cacheBots:(NSArray<RCDOpenClawBot *> *)bots {
    for (RCDOpenClawBot *bot in bots) {
        [self cacheBot:bot];
    }
}

+ (void)cacheBot:(RCDOpenClawBot *)bot {
    if (bot.botId.length == 0) {
        return;
    }
    if (bot.portraitUri.length == 0) {
        bot.portraitUri = [self defaultPortraitUri];
    }
    [self botCache][bot.botId] = bot;
    [self refreshBotInfo:bot];
}

+ (RCDOpenClawBot *)botWithBotId:(NSString *)botId {
    if (botId.length == 0) {
        return nil;
    }
    RCDOpenClawBot *bot = [self botCache][botId];
    if (bot) {
        return bot;
    }
    if (![botId hasPrefix:RCDOpenClawBotIdPrefix]) {
        return nil;
    }
    return [self fallbackBotWithBotId:botId];
}

+ (RCUserInfo *)userInfoForBotId:(NSString *)botId {
    RCDOpenClawBot *bot = [self botWithBotId:botId];
    if (!bot) {
        return nil;
    }
    NSString *name = bot.name.length > 0 ? bot.name : [self defaultBotName];
    NSString *portrait = bot.portraitUri.length > 0 ? bot.portraitUri : [self defaultPortraitUri];
    return [[RCUserInfo alloc] initWithUserId:bot.botId name:name portrait:portrait];
}

+ (RCDOpenClawBot *)fallbackBotWithBotId:(NSString *)botId {
    return [[RCDOpenClawBot alloc] initWithDictionary:@{
        @"botId" : botId ?: @"",
        @"name" : [self defaultBotName],
        @"portraitUri" : [self defaultPortraitUri]
    }];
}

+ (void)refreshBotInfo:(RCDOpenClawBot *)bot {
    if (bot.botId.length == 0) {
        return;
    }
    RCUserInfo *userInfo = [self userInfoForBotId:bot.botId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:bot.botId];
        [[NSNotificationCenter defaultCenter] postNotificationName:RCDOpenClawBotInfoDidUpdateNotification object:bot.botId];
        [[NSNotificationCenter defaultCenter] postNotificationName:RCDOpenClawRefreshConversationListNotification object:nil];
    });
}

@end
