//
//  RCDFraudPreventionAPI.h
//  SealTalk
//
//  Created by lizhipeng on 2022/5/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDFraudPreventionAPI : NSObject

/* 是否开启天美验证系统*/
+ (void)fraudPreventionStatusSuccess:(void (^)(BOOL openEnable))successBlock
                               error:(void (^)(NSInteger code))errorBlock ;

/* 使用天美验证是否当前设备为禁用设备*/
+ (void)fraudPreventionVerifyWithPhone:(nonnull NSString *)phone
                                region:(nonnull NSString *)region
                              deviceId:(nonnull NSString *)deviceId
                               success:(void (^)(RCDFraudPreventionRiskLevelCode code))successBlock
                                 error:(void (^)(NSInteger code))errorBlock ;

@end

NS_ASSUME_NONNULL_END
