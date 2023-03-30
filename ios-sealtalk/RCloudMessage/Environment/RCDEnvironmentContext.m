//
//  RCDEnvironmentContext.m
//  SealTalk
//
//  Created by RobinCui on 2022/3/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDEnvironmentContext.h"
#import "RCDEnvironmentModel.h"


static RCDEnvironmentContext *_instance;

static dispatch_once_t onceToken;

@interface RCDEnvironmentContext()
@property (nonatomic, strong) RCDEnvironmentModel *environmentModel;
@end

@implementation RCDEnvironmentContext

// 获取环境列表
+ (NSArray <NSDictionary<NSString *, NSNumber *> *>*)appEnvironments {
    return [RCDEnvironmentModel appEnvironments];
}

+ (void)saveEnvironmentByCategory:(NSNumber *)category {
    RCDEnvironmentCategory type = RCDEnvironmentCategoryDefault;
    if ([category isKindOfClass:[NSNumber class]]) {
        type = [category integerValue];
    }
    
    [RCDEnvironmentModel saveEnvironmentCategory:[category integerValue]];
    [RCDEnvironmentContext sharedInstance].environmentModel = [RCDEnvironmentModel appEnvironmentByCategory:type];
}

+ (NSString *)currentEnvironmentNameKey {
    return [RCDEnvironmentContext sharedInstance].environmentModel.regionNameKey;
}

+ (NSString *)appKey {
    return [RCDEnvironmentContext sharedInstance].environmentModel.appKey;
}

+ (NSString *)serviceID {
    return [RCDEnvironmentContext sharedInstance].environmentModel.serviceID;
}

+ (NSString *)serverURL {
    return [RCDEnvironmentContext sharedInstance].environmentModel.serverURL;
}

+ (NSString *)navServer {
    return [RCDEnvironmentContext sharedInstance].environmentModel.navServer;
}

+ (NSString *)fileServer {
    return [RCDEnvironmentContext sharedInstance].environmentModel.fileServer;
}

+ (NSString *)statsServer {
    return [RCDEnvironmentContext sharedInstance].environmentModel.statsServer;
}

#pragma mark -- Private

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.environmentModel = [RCDEnvironmentModel currentEnvironment];
    }
    return self;
}
@end
