//
//  RCDSMSDKDelegate.h
//  SealTalk
//
//  Created by lizhipeng on 2022/5/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#if !RCDDebugFraundPreventionDisable
#import "SmAntiFraud.h"
#endif
NS_ASSUME_NONNULL_BEGIN

#if RCDDebugFraundPreventionDisable
@interface RCDSMSDKDelegate : NSObject
#else
@interface RCDSMSDKDelegate : NSObject <ServerSmidProtocol>
#endif
@end

NS_ASSUME_NONNULL_END
