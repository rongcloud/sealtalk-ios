//
//  RCDEnvironmentModel.m
//  SealTalk
//
//  Created by RobinCui on 2022/3/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDEnvironmentModel.h"
#import "RCDCommonDefine.h"

NSString* const RCDEnvironmentCategoryKey = @"RCDEnvironmentCategoryKey";
NSString* const RCDEnvironmentOverseaBundleID = @"cn.rongcloud.im.sg";
NSString* const RCDDefaultRegionNameKey = @"RegionNameDefault";

NSString* const RCDSigaporeAppKey = @"8w7jv4qb8340y";
NSString* const RCDSigaporeServiceID = @"";
NSString* const RCDSigaporevServerURL = @"https://sealtalk-server-awssg.ronghub.com/";
NSString* const RCDSigaporeNavServer = @"https://navsg01.cn.ronghub.com";
NSString* const RCDSigaporeFileServer = @"";
NSString* const RCDSigaporeStatsServer = @"";
NSString* const RCDSigaporeRegionNameKey = @"RegionNameSigapore";

NSString* const RCDNorthAmericanAppKey = @"4z3hlwrv4hqwt";
NSString* const RCDNorthAmericanServiceID = @"";
NSString* const RCDNorthAmericanServerURL = @"https://sealtalk-server-us.ronghub.com/";
NSString* const RCDNorthAmericanNavServer = @"https://nav-us.ronghub.com";
NSString* const RCDNorthAmericanFileServer = @"";
NSString* const RCDNorthAmericanStatsServer = @"";
NSString* const RCDNorthAmericanRegionNameKey = @"RegionNameNorthAmerican";
@implementation RCDEnvironmentModel

#pragma mark - Public

+ (instancetype)currentEnvironment {
    RCDEnvironmentCategory category = [self currentEnvironmentCategory];
    return [self appEnvironmentByCategory:category];
}

+ (void)saveEnvironmentCategory:(RCDEnvironmentCategory)category {
    if ([self isOverseaEnvironment]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@(category) forKey:RCDEnvironmentCategoryKey];
        [userDefaults synchronize];
    }
}

+ (NSArray <NSDictionary *>*)appOverseaEnvironments {
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *dic = @{RCDSigaporeRegionNameKey:@(RCDEnvironmentCategorySigapore)};
    [array addObject:dic];
    
    dic = @{RCDNorthAmericanRegionNameKey:@(RCDEnvironmentCategoryNorthAmerican)};
    [array addObject:dic];
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
        default:
            model = [self appEnvironmentDefault];
            break;
    }
    return model;
}

// 是否为国外环境
+ (BOOL)isOverseaEnvironment {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return [bundleIdentifier isEqualToString:RCDEnvironmentOverseaBundleID];
}

#pragma mark - Private

+ (instancetype)appEnvironmentDefault {
    RCDEnvironmentModel *model = [[RCDEnvironmentModel alloc] init];
    model.appKey = RONGCLOUD_IM_APPKEY;
    model.serviceID = SERVICE_ID;
    model.serverURL = DEMO_SERVER;
    model.navServer = RONGCLOUD_NAVI_SERVER;
    model.fileServer = RONGCLOUD_FILE_SERVER;
    model.statsServer = RONGCLOUD_STATS_SERVER;
    model.category = RCDEnvironmentCategoryDefault;
    model.regionNameKey = RCDSigaporeRegionNameKey;
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
    if ([self isOverseaEnvironment]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber *num = [userDefaults valueForKey:RCDEnvironmentCategoryKey];
        if (num) {
            return [num integerValue];
        } else {
            return RCDEnvironmentCategorySigapore;
        }
    }
    return RCDEnvironmentCategoryDefault;
}

@end
