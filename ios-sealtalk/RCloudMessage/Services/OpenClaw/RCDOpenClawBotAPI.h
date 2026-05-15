//
//  RCDOpenClawBotAPI.h
//  SealTalk
//
//  Created by Codex on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCDOpenClawBot;

NS_ASSUME_NONNULL_BEGIN

typedef void (^RCDOpenClawBotSuccessBlock)(RCDOpenClawBot *bot);
typedef void (^RCDOpenClawBotListSuccessBlock)(NSArray<RCDOpenClawBot *> *bots);
typedef void (^RCDOpenClawBoolSuccessBlock)(BOOL success);
typedef void (^RCDOpenClawErrorBlock)(NSError *error);

@interface RCDOpenClawBotAPI : NSObject

+ (void)createBotWithName:(NSString *)name
              portraitUri:(nullable NSString *)portraitUri
                  success:(RCDOpenClawBotSuccessBlock)success
                    error:(RCDOpenClawErrorBlock)error;

+ (void)refreshTokenWithBotId:(NSString *)botId
                      success:(RCDOpenClawBotSuccessBlock)success
                        error:(RCDOpenClawErrorBlock)error;

+ (void)getMyBotsWithSuccess:(RCDOpenClawBotListSuccessBlock)success
                       error:(RCDOpenClawErrorBlock)error;

+ (void)getBotWithBotId:(NSString *)botId
                success:(RCDOpenClawBotSuccessBlock)success
                  error:(RCDOpenClawErrorBlock)error;

+ (void)getGroupBotsWithGroupId:(NSString *)groupId
                         success:(RCDOpenClawBotListSuccessBlock)success
                           error:(RCDOpenClawErrorBlock)error;

+ (void)addBots:(NSArray<NSString *> *)botIds
      toGroupId:(NSString *)groupId
        success:(RCDOpenClawBoolSuccessBlock)success
          error:(RCDOpenClawErrorBlock)error;

+ (void)removeBots:(NSArray<NSString *> *)botIds
        fromGroupId:(NSString *)groupId
          success:(RCDOpenClawBoolSuccessBlock)success
            error:(RCDOpenClawErrorBlock)error;

@end

NS_ASSUME_NONNULL_END
