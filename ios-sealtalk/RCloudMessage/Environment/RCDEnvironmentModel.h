//
//  RCDEnvironmentModel.h
//  SealTalk
//
//  Created by RobinCui on 2022/3/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCDEnvironmentCategory) {
    RCDEnvironmentCategoryDefault, //默认
    RCDEnvironmentCategorySigapore, // 新加坡
    RCDEnvironmentCategoryNorthAmerican // 北美
};

@interface RCDEnvironmentModel : NSObject
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *serviceID;
@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, copy) NSString *navServer;
@property (nonatomic, copy) NSString *fileServer;
@property (nonatomic, copy) NSString *statsServer;
@property (nonatomic, copy) NSString *regionNameKey;
@property (nonatomic, assign) RCDEnvironmentCategory category;

// 当前环境
+ (instancetype)currentEnvironment;

+ (instancetype)appEnvironmentByCategory:(RCDEnvironmentCategory)category;

// 保存环境类型
+ (void)saveEnvironmentCategory:(RCDEnvironmentCategory)category;

// 获取环境列表
+ (NSArray <NSDictionary<NSString *, NSNumber *> *>*)appOverseaEnvironments;

// 是否为国外环境
+ (BOOL)isOverseaEnvironment;
@end

NS_ASSUME_NONNULL_END
