//
//  RCDFraudPreventionManager.h
//  SealTalk
//
//  Created by lizhipeng on 2022/5/18.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDFraudPreventionAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDFraudPreventionManager : NSObject

+ (instancetype) sharedInstance ;

/* 验证当前账号 在当前设备下是否为封禁状态 */
- (void)reqestFrandPreventionRiskLevelREJECTWithPhone:(nonnull NSString *)phone
                                           withRegion:(nonnull NSString *)region
                                             complate:(void (^)(BOOL reject))complate ;

@end

NS_ASSUME_NONNULL_END
