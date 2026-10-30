//
//  RCDateUtility.m
//  RongIMKit
//
//  Created by RobinCui on 2024/8/29.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUDateUtility.h"

@implementation RCUDateUtility
+ (NSInteger)startOfToday {
    NSDate *now = [NSDate date];
    NSDate *date = [[NSCalendar currentCalendar] startOfDayForDate:now];
    return [date timeIntervalSince1970] * 1000;
}

+ (NSInteger)timeOfDaysBefore:(NSInteger)dayDiff start:(BOOL)start {
    NSDate *now = [NSDate date];
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                            value:dayDiff
                                                           toDate:now options:NSCalendarMatchStrictly];
    NSDate *dateStart = [[NSCalendar currentCalendar] startOfDayForDate:date];

    if (start) {
        return [dateStart timeIntervalSince1970] * 1000;
    } else {
        NSDate *dateEnd = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                value:1
                                                               toDate:dateStart options:NSCalendarWrapComponents];
        return [dateEnd timeIntervalSince1970] * 1000 - 1;
    }

}

+ (NSInteger)startTimeOfDaysBefore:(NSInteger)dayDiff {
    return [self timeOfDaysBefore:dayDiff start:YES];;
}

+ (NSInteger)endTimeOfDaysBefore:(NSInteger)dayDiff {
    return [self timeOfDaysBefore:dayDiff start:NO];;
}
@end
