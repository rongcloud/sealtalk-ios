//
//  RCDEnvironmentModel.m
//  SealTalk
//
//  Created by RobinCui on 2022/3/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDEnvironmentModel.h"
#import "RCDCommonDefine.h"
#import "RCDCommonString.h"
NSString* const RCDEnvironmentCategoryKey = @"RCDEnvironmentCategoryKey";
NSString* const RCDEnvironmentOverseaBundleID = @"cn.rongcloud.im.sg";
NSString* const RCDDefaultRegionNameKey = @"RegionNameDefault";

NSString* const RCDSigaporeAppKey = @"";
NSString* const RCDSigaporeServiceID = @"";
NSString* const RCDSigaporevServerURL = @"";
NSString* const RCDSigaporeNavServer = @"";
NSString* const RCDSigaporeFileServer = @"";
NSString* const RCDSigaporeStatsServer = @"";
NSString* const RCDSigaporeRegionNameKey = @"RegionNameSigapore";

NSString* const RCDNorthAmericanAppKey = @"";
NSString* const RCDNorthAmericanServiceID = @"";
NSString* const RCDNorthAmericanServerURL = @"";
NSString* const RCDNorthAmericanNavServer = @"";
NSString* const RCDNorthAmericanFileServer = @"";
NSString* const RCDNorthAmericanStatsServer = @"";
NSString* const RCDNorthAmericanRegionNameKey = @"RegionNameNorthAmerican";

NSString* const RCDTestAppKey = @"";
NSString* const RCDTestServiceID = SERVICE_ID;
NSString* const RCDTestServerURL = @"";
NSString* const RCDTestNavServer = @"";
NSString* const RCDTestFileServer = @"";
NSString* const RCDTestStatsServer = @"";
NSString* const RCDTestRegionNameKey = @"吕布";

@implementation RCDEnvironmentModel

#pragma mark - Public

+ (instancetype)currentEnvironment {
    RCDEnvironmentCategory category = [self currentEnvironmentCategory];
    return [self appEnvironmentByCategory:category];
}

+ (void)saveEnvironmentCategory:(RCDEnvironmentCategory)category {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(category) forKey:RCDEnvironmentCategoryKey];
    [userDefaults synchronize];
    [self saveShareDemoServer:category];
}

+ (void)saveShareDemoServer:(RCDEnvironmentCategory)category{
    RCDEnvironmentModel *model = [self appEnvironmentByCategory:category];
    NSUserDefaults *shareUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:MCShareExtensionKey];
    [shareUserDefaults setValue:model.serverURL forKey:RCDDemoServerKey];
    [shareUserDefaults synchronize];
}

+ (NSArray <NSDictionary *>*)appEnvironments {
    NSMutableArray *array = @[@{RCDDefaultRegionNameKey:@(RCDEnvironmentCategoryDefault)},
                       @{RCDSigaporeRegionNameKey:@(RCDEnvironmentCategorySigapore)},
                       @{RCDNorthAmericanRegionNameKey:@(RCDEnvironmentCategoryNorthAmerican)}].mutableCopy;
    BOOL showTest = [DEFAULTS boolForKey:RCDSwitchTestEnvKey];
    if (showTest) {
        [array addObject:@{RCDTestRegionNameKey:@(RCDEnvironmentCategoryTest)}];
    }
    return array;
}

+ (instancetype)appEnvironmentByCategory:(RCDEnvironmentCategory)category {
    RCDEnvironmentModel *model = nil;
    switch (category) {
        case RCDEnvironmentCategorySigapore:
            model = [self appEnvironmentOfSigapore];
            break;
        case RCDEnvironmentCategoryNorthAmerican:
            model = [self appEnvironmentOfNorthAmerican];
            break;
        case RCDEnvironmentCategoryTest:
            model = [self appEnvironmenTest];
            break;
        default:
            model = [self appEnvironmentDefault];
            break;
    }
    return model;
}

#pragma mark - Private
+ (instancetype)appEnvironmenTest{
    RCDEnvironmentModel *model = [[RCDEnvironmentModel alloc] init];
    model.appKey = RCDTestAppKey;
    model.serviceID = SERVICE_ID;
    model.serverURL = RCDTestServerURL;
    model.navServer = RCDTestNavServer;
    model.fileServer = RCDTestFileServer;
    model.statsServer = RCDTestStatsServer;
    model.category = RCDEnvironmentCategoryTest;
    model.regionNameKey = RCDTestRegionNameKey;
    return model;
}

+ (instancetype)appEnvironmentDefault {
    RCDEnvironmentModel *model = [[RCDEnvironmentModel alloc] init];
    model.appKey = RONGCLOUD_IM_APPKEY;
    model.serviceID = SERVICE_ID;
    model.serverURL = DEMO_SERVER;
    model.navServer = RONGCLOUD_NAVI_SERVER;
    model.fileServer = RONGCLOUD_FILE_SERVER;
    model.statsServer = RONGCLOUD_STATS_SERVER;
    model.category = RCDEnvironmentCategoryDefault;
    model.regionNameKey = RCDDefaultRegionNameKey;
    return model;
}

+ (instancetype)appEnvironmentOfSigapore {
    RCDEnvironmentModel *model = [[RCDEnvironmentModel alloc] init];
    model.appKey = RCDSigaporeAppKey;
    model.serviceID = RCDSigaporeServiceID;
    model.serverURL = RCDSigaporevServerURL;
    model.navServer = RCDSigaporeNavServer;
    model.fileServer = RCDSigaporeFileServer;
    model.statsServer = RCDSigaporeStatsServer;
    model.category = RCDEnvironmentCategorySigapore;
    model.regionNameKey = RCDSigaporeRegionNameKey;
    return model;
}

+ (instancetype)appEnvironmentOfNorthAmerican {
    RCDEnvironmentModel *model = [[RCDEnvironmentModel alloc] init];
    model.appKey = RCDNorthAmericanAppKey;
    model.serviceID = RCDNorthAmericanServiceID;
    model.serverURL = RCDNorthAmericanServerURL;
    model.navServer = RCDNorthAmericanNavServer;
    model.fileServer = RCDNorthAmericanFileServer;
    model.statsServer = RCDNorthAmericanStatsServer;
    model.category = RCDEnvironmentCategoryNorthAmerican;
    model.regionNameKey = RCDNorthAmericanRegionNameKey;
    return model;
}



+ (RCDEnvironmentCategory)currentEnvironmentCategory {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [userDefaults valueForKey:RCDEnvironmentCategoryKey];
    if (num) {
        return [num integerValue];
    }
    RCDEnvironmentCategory category = RCDEnvironmentCategoryDefault;
    if (![self isShowDefault]){
        category = RCDEnvironmentCategorySigapore;
    }
    [self saveEnvironmentCategory:category];
    return category;
}

//根据时区判断当前是否在中国
+ (BOOL)isShowDefault {
    BOOL result = NO;
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language containsString:@"zh-Hans"]) {
        return YES;
    }
    return result;
}

@end
