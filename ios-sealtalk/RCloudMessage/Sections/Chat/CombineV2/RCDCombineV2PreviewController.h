//
//  RCDCombineV2PreviewController.h
//  SealTalk
//
//  Created by zgh on 2024/1/5.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCDChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class RCMessageModel;

@interface RCDCombineV2PreviewController : RCDChatViewController

- (instancetype)initWithMessage:(RCMessageModel *)messageModel;

@end

NS_ASSUME_NONNULL_END
