//
//  RCDProxySettingControllerViewController.h
//  SealTalk
//
//  Created by chinaspx on 2022/9/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class RCIMProxy, RCRTCProxy;
@interface RCDProxySettingControllerViewController : RCDViewController
@property (nonatomic, copy) dispatch_block_t saveCallback;

+ (nullable RCIMProxy *)currentAPPSettingIMProxy;
+ (nullable RCRTCProxy *)currentAPPSettingRTCProxy;

@end

NS_ASSUME_NONNULL_END
