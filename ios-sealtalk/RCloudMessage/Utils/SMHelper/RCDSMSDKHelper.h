//
//  RCDSMSDKHelper.h
//  SealTalk
//
//  Created by lizhipeng on 2022/4/19.
//  Copyright © 2022 RongCloud. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ServerSmidProtocol;

@interface RCDSMSDKHelper : NSObject

+ (void)setupSMSDK ;

+ (NSString *)getDeviceId ;

@end

NS_ASSUME_NONNULL_END
