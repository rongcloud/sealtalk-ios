//
//  RCDOpenClawBotSelectViewModel.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotSelectViewModel.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotAPI.h"
#import "RCDOpenClawBotManager.h"

@interface RCDOpenClawBotSelectViewModel ()

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) NSSet<NSString *> *existingBotIds;

@end

@implementation RCDOpenClawBotSelectViewModel

- (instancetype)initWithGroupId:(NSString *)groupId
                  existingBotIds:(NSArray<NSString *> *)existingBotIds {
    self = [super init];
    if (self) {
        _groupId = [groupId copy];
        _existingBotIds = [NSSet setWithArray:existingBotIds ?: @[]];
    }
    return self;
}

- (BOOL)isBotAlreadyAddedAtIndex:(NSInteger)index {
    RCDOpenClawBot *bot = [self botAtIndex:index];
    return [self isBotAlreadyAdded:bot];
}

- (BOOL)isBotAlreadyAdded:(RCDOpenClawBot *)bot {
    return bot.botId.length > 0 && [self.existingBotIds containsObject:bot.botId];
}

- (void)addBotAtIndex:(NSInteger)index success:(void (^)(RCDOpenClawBot *bot))success error:(RCDOpenClawViewModelErrorBlock)error {
    RCDOpenClawBot *bot = [self botAtIndex:index];
    if (bot.botId.length == 0) {
        return;
    }
    [RCDOpenClawBotAPI addBots:@[ bot.botId ] toGroupId:self.groupId success:^(BOOL requestSuccess) {
        [RCDOpenClawBotManager cacheBot:bot];
        if (success) {
            success(bot);
        }
    } error:error];
}

- (NSArray<RCDOpenClawBot *> *)botsWithBotIds:(NSArray<NSString *> *)botIds {
    NSMutableArray<RCDOpenClawBot *> *result = [NSMutableArray array];
    NSSet<NSString *> *botIdSet = [NSSet setWithArray:botIds ?: @[]];
    for (RCDOpenClawBot *bot in [self allLoadedBots]) {
        if (bot.botId.length > 0 && [botIdSet containsObject:bot.botId]) {
            [result addObject:bot];
        }
    }
    return result.copy;
}

- (void)addBotsWithBotIds:(NSArray<NSString *> *)botIds
                  success:(void (^)(NSArray<RCDOpenClawBot *> *bots))success
                    error:(RCDOpenClawViewModelErrorBlock)error {
    NSArray<RCDOpenClawBot *> *bots = [self botsWithBotIds:botIds];
    if (bots.count == 0) {
        return;
    }
    NSMutableArray<NSString *> *validBotIds = [NSMutableArray array];
    for (RCDOpenClawBot *bot in bots) {
        if (bot.botId.length > 0) {
            [validBotIds addObject:bot.botId];
        }
    }
    [RCDOpenClawBotAPI addBots:validBotIds toGroupId:self.groupId success:^(BOOL requestSuccess) {
        [RCDOpenClawBotManager cacheBots:bots];
        if (success) {
            success(bots);
        }
    } error:error];
}

@end
