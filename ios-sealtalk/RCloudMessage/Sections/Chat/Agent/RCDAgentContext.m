//
//  RCDAgentContext.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentContext.h"
#import "RCDEnvironmentContext.h"

NSString * const RCDAgentEnableKey = @"RCDAgentEnableKey";
NSString * const RCDAgentMessageAuthKey = @"RCDAgentMessageAuthKey";
NSString * const RCDAgentTagsKey = @"RCDAgentTagsKey";
NSString * const RCDAgentConversationToTagKey = @"RCDAgentConversationToTagKey";

@implementation RCDAgentContext

+ (BOOL)isAbilityValidForKey:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [userDefault objectForKey:key];
    return [num boolValue];
}

+ (void)updateAbilityFor:(NSString *)key result:(BOOL)result {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@(result) forKey:key];
    [userDefault synchronize];
}

+ (NSArray *)agentTags {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefault objectForKey:RCDAgentTagsKey];
    NSMutableArray *tags = [NSMutableArray array];
    NSString *regionKey = [RCDEnvironmentContext currentEnvironmentNameKey];
    if ([regionKey isEqualToString:@"RegionNameDefault"]) {
        array = @[
            @{
                @"name": @"温柔体贴",
                @"agentId":@"HO5JKXWBVYF"
            },
            @{
                @"name": @"幽默风趣",
                @"agentId":@"2XYL0WV3DF8"
            },
            @{
                @"name": @"热情洋溢",
                @"agentId":@"VCT7DUH3BBP"
            },
            @{
                @"name": @"文艺青年",
                @"agentId": @"WIQ5JJ8TTYM"
            }];
    } else {
        array = @[
            @{
                @"name": @"DeepSeek",
                @"agentId":@"JKRTT89HA5V"
            },
            @{
                @"name": @"火山-慢速",
                @"agentId":@"FA703PO3BKK"
            },
            @{
                @"name": @"火山-快速",
                @"agentId":@"JKRRUF3K6NV"
            },
            @{
                @"name": @"测试专线",
                @"agentId": @"14N2PEZDSPV"
            }
        ];
    }
    for (NSDictionary *info in array) {
        RCDAgentTag *tag = [[RCDAgentTag alloc] initWithDictionary:info];
        [tags addObject:tag];
    }
    return tags;
}

+ (void)saveAgentTags:(NSArray<NSDictionary *>*)tags {
    if (tags) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:tags forKey:RCDAgentTagsKey];
        [userDefault synchronize];
    }
}

+ (RCDAgentTag *)agentTagFor:(RCConversationIdentifier *)identifier {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefault objectForKey:RCDAgentConversationToTagKey];
    if (dic) {
        NSString *key = [self keyFor:identifier];
        NSDictionary *info = [dic objectForKey:key];
        if (info) {
            RCDAgentTag *tag = [[RCDAgentTag alloc] initWithDictionary:info];
            return tag;
        }
    }
    return nil;
}

+ (void)saveAgentTag:(RCDAgentTag *)tag forIdentifier:(RCConversationIdentifier *)identifier {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    
    NSDictionary *dic = [userDefault objectForKey:RCDAgentConversationToTagKey];
    if (dic) {
        mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
    NSString *key = [self keyFor:identifier];
    mDic[key] = [tag dictionaryInfo];
    [userDefault setObject:mDic forKey:RCDAgentConversationToTagKey];
    [userDefault synchronize];
}

+ (NSString *)keyFor:(RCConversationIdentifier *)identifier {
    NSString *userID = [[RCCoreClient sharedCoreClient] currentUserInfo].userId;
    NSString *key = [NSString stringWithFormat:@"%@-%@-%ld-%@",identifier.targetId,
                     identifier.channelId,
                     identifier.type,
                     userID];
    return key;
}
@end
