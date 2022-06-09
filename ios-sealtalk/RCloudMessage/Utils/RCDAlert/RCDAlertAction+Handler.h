//
//  RCDAlertAction+Handler.h
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDAlertAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDAlertAction ()

@property(nonatomic, copy)void (^ handler)(RCDAlertAction *action)  ;

@end

NS_ASSUME_NONNULL_END
