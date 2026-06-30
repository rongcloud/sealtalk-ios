//
//  RCDateUtility.h
//  RongIMKit
//
//  Created by RobinCui on 2024/8/29.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCUDateUtility : NSObject

/// 今天的开始时间
+ (NSInteger)startOfToday;

/// 最近几天的起始时间
/// - Parameter dayDiff: 天数
+ (NSInteger)startTimeOfDaysBefore:(NSInteger)dayDiff;

/// 最近几天的截止时间
/// - Parameter dayDiff: 天数
+ (NSInteger)endTimeOfDaysBefore:(NSInteger)dayDiff;

@end

NS_ASSUME_NONNULL_END
