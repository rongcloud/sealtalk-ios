//
//  RCDOpenClawViewModel.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCDOpenClawBot;

NS_ASSUME_NONNULL_BEGIN

typedef void (^RCDOpenClawBotViewModelSuccessBlock)(RCDOpenClawBot *bot);
typedef void (^RCDOpenClawViewModelErrorBlock)(NSError *error);

NS_ASSUME_NONNULL_END
