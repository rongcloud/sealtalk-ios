//
//  RCDOpenClawBotTokenViewController.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

@class RCDOpenClawBot;

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawBotTokenViewController : RCDViewController

- (instancetype)initWithBot:(RCDOpenClawBot *)bot created:(BOOL)created;

@end

NS_ASSUME_NONNULL_END
