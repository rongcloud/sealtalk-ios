//
//  RCDEnvironmentContext.h
//  SealTalk
//
//  Created by RobinCui on 2022/3/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDEnvironmentContext : NSObject
// 获取环境列表
+ (NSArray <NSDictionary<NSString *, NSNumber *> *>*)appEnvironments;

// 保存环境类型
+ (void)saveEnvironmentByCategory:(NSNumber *)category;

+ (BOOL)isOversea;
+ (NSString *)currentEnvironmentNameKey;

+ (NSString *)appKey;
+ (NSString *)serviceID;
+ (NSString *)serverURL;
+ (NSString *)navServer;
+ (NSString *)fileServer;
+ (NSString *)statsServer;
@end

NS_ASSUME_NONNULL_END
