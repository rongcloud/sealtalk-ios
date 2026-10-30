//
//  RCDOpenClawCreateBotViewController.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawCreateBotViewController : RCDViewController

@property (nonatomic, copy, nullable) void (^createSuccessBlock)(void);

@end

NS_ASSUME_NONNULL_END
