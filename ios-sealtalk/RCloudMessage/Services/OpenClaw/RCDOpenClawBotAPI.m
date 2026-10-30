//
//  RCDOpenClawBotAPI.m
//  SealTalk
//
//  Created by RC on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotAPI.h"
#import "RCDOpenClawBot.h"
#import "RCDHTTPUtility.h"

static NSString *const RCDOpenClawBotErrorDomain = @"cn.rongcloud.sealtalk.openclaw.bot";
static NSString *const RCDOpenClawCreateBotPath = @"bot/create";
static NSString *const RCDOpenClawRefreshTokenPath = @"bot/refreshToken";
static NSString *const RCDOpenClawMyBotsPath = @"user/bots";
static NSString *const RCDOpenClawBotDetailPath = @"user/bot";
static NSString *const RCDOpenClawGroupBotsPath = @"group/bot";
static NSString *const RCDOpenClawAddGroupBotPath = @"group/bot/add";
static NSString *const RCDOpenClawRemoveGroupBotPath = @"group/bot/remove";

@implementation RCDOpenClawBotAPI

+ (void)createBotWithName:(NSString *)name
              portraitUri:(NSString *)portraitUri
                  success:(RCDOpenClawBotSuccessBlock)success
                    error:(RCDOpenClawErrorBlock)error {
    NSMutableDictionary *params = [@{@"name" : name ?: @""} mutableCopy];
    if (portraitUri.length > 0) {
        params[@"portraitUri"] = portraitUri;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:RCDOpenClawCreateBotPath
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     [self handleBotResult:result success:success error:error];
                                 }];
}

+ (void)refreshTokenWithBotId:(NSString *)botId
                      success:(RCDOpenClawBotSuccessBlock)success
                        error:(RCDOpenClawErrorBlock)error {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:RCDOpenClawRefreshTokenPath
                               parameters:@{@"botId" : botId ?: @""}
                                 response:^(RCDHTTPResult *result) {
                                     [self handleBotResult:result success:success error:error];
                                 }];
}

+ (void)getMyBotsWithSuccess:(RCDOpenClawBotListSuccessBlock)success
                       error:(RCDOpenClawErrorBlock)error {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:RCDOpenClawMyBotsPath
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     [self handleBotListResult:result success:success error:error];
                                 }];
}

+ (void)getBotWithBotId:(NSString *)botId
                success:(RCDOpenClawBotSuccessBlock)success
                  error:(RCDOpenClawErrorBlock)error {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:RCDOpenClawBotDetailPath
                               parameters:@{@"botId" : botId ?: @""}
                                 response:^(RCDHTTPResult *result) {
                                     [self handleBotResult:result success:success error:error];
                                 }];
}

+ (void)getGroupBotsWithGroupId:(NSString *)groupId
                         success:(RCDOpenClawBotListSuccessBlock)success
                           error:(RCDOpenClawErrorBlock)error {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:RCDOpenClawGroupBotsPath
                               parameters:@{@"groupId" : groupId ?: @""}
                                 response:^(RCDHTTPResult *result) {
                                     [self handleBotListResult:result success:success error:error];
                                 }];
}

+ (void)addBots:(NSArray<NSString *> *)botIds
      toGroupId:(NSString *)groupId
        success:(RCDOpenClawBoolSuccessBlock)success
          error:(RCDOpenClawErrorBlock)error {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:RCDOpenClawAddGroupBotPath
                               parameters:@{@"groupId" : groupId ?: @"", @"botIds" : botIds ?: @[]}
                                 response:^(RCDHTTPResult *result) {
                                     [self handleBoolResult:result success:success error:error];
                                 }];
}

+ (void)removeBots:(NSArray<NSString *> *)botIds
       fromGroupId:(NSString *)groupId
          success:(RCDOpenClawBoolSuccessBlock)success
            error:(RCDOpenClawErrorBlock)error {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:RCDOpenClawRemoveGroupBotPath
                               parameters:@{@"groupId" : groupId ?: @"", @"botIds" : botIds ?: @[]}
                                 response:^(RCDHTTPResult *result) {
                                     [self handleBoolResult:result success:success error:error];
                                 }];
}

+ (void)handleBotResult:(RCDHTTPResult *)result
                success:(RCDOpenClawBotSuccessBlock)success
                  error:(RCDOpenClawErrorBlock)error {
    if (result.success && [result.content isKindOfClass:[NSDictionary class]]) {
        RCDOpenClawBot *bot = [[RCDOpenClawBot alloc] initWithDictionary:result.content];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(bot);
            }
        });
    } else {
        [self dispatchErrorWithResult:result error:error];
    }
}

+ (void)handleBotListResult:(RCDHTTPResult *)result
                    success:(RCDOpenClawBotListSuccessBlock)success
                      error:(RCDOpenClawErrorBlock)error {
    if (result.success && (!result.content || result.content == (id)[NSNull null])) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(@[]);
            }
        });
    } else if (result.success && [result.content isKindOfClass:[NSArray class]]) {
        NSMutableArray *bots = [NSMutableArray array];
        for (NSDictionary *dictionary in (NSArray *)result.content) {
            if ([dictionary isKindOfClass:[NSDictionary class]]) {
                [bots addObject:[[RCDOpenClawBot alloc] initWithDictionary:dictionary]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(bots.copy);
            }
        });
    } else {
        [self dispatchErrorWithResult:result error:error];
    }
}

+ (void)handleBoolResult:(RCDHTTPResult *)result
                 success:(RCDOpenClawBoolSuccessBlock)success
                   error:(RCDOpenClawErrorBlock)error {
    if (result.success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(YES);
            }
        });
    } else {
        [self dispatchErrorWithResult:result error:error];
    }
}

+ (void)dispatchErrorWithResult:(RCDHTTPResult *)result error:(RCDOpenClawErrorBlock)error {
    NSString *message = RCDLocalizedString(@"OpenClawOperationFailed");
    if ([result.content isKindOfClass:[NSString class]] && [(NSString *)result.content length] > 0) {
        message = result.content;
    }
    NSError *requestError = [NSError errorWithDomain:RCDOpenClawBotErrorDomain
                                               code:result.errorCode
                                           userInfo:@{NSLocalizedDescriptionKey : message}];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            error(requestError);
        }
    });
}

@end
