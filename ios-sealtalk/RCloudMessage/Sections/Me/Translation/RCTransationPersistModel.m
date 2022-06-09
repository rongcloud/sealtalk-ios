//
//  RCTransationPersistModel.m
//  RongTranslation
//
//  Created by RobinCui on 2022/3/1.
//

#import "RCTransationPersistModel.h"

#if RCDTranslationEnable
#import <RongTranslation/RongTranslation.h>
#endif

static NSString * const RCKitTranslationConfigSourceKey = @"RCKitTranslationConfigSourceKey";
static NSString * const RCKitTranslationConfigTargetKey = @"RCKitTranslationConfigTargetKey";


@implementation RCTransationPersistModel

+ (instancetype)loadTranslationConfig
{
    RCTransationPersistModel *config = [RCTransationPersistModel new];
    NSString *src = [self fetchLanguageBy:RCKitTranslationConfigSourceKey];
#if RCDTranslationEnable
    src = src ?: RCTranslationLanguageZH_CN;
#else
    src = src ?: @"zh_CN";
#endif
    
    NSString *target = [self fetchLanguageBy:RCKitTranslationConfigTargetKey];
#if RCDTranslationEnable
    target = target ?: RCTranslationLanguageEN;
#else
    target = target ?: @"en";
#endif
    
    config.srcLanguage = src;
    config.targetLanguage = target;
    return config;
}

- (BOOL)isConfigurationValid {
    if ([self.targetLanguage isKindOfClass:[NSString class]]
        && [self.srcLanguage isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}


- (void)save {
    [[self class] saveLanguage:self.srcLanguage byKey:RCKitTranslationConfigSourceKey];
    [[self class] saveLanguage:self.targetLanguage byKey:RCKitTranslationConfigTargetKey];
}

+ (NSString *)fetchLanguageBy:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id value = [userDefault valueForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}

+ (void)saveLanguage:(NSString *)language byKey:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (key && [key isKindOfClass:[NSString class]]) {
        [userDefault setValue:language forKey:key];
        [userDefault synchronize];
    }
}
@end
