//
//  RCDDebugUltraGroupChatViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2021/11/29.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugMsgShortageChatController.h"
#import "RCDUltraGroup.h"
#import "RCDChannel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCDDebugUltraGroupChatViewController : RCConversationViewController
@property (nonatomic, assign) BOOL isDebugEnter;
@property (nonatomic, strong) RCDUltraGroup *ultraGroup;

/// 是否为私有频道
@property (nonatomic, assign) BOOL isPrivate;
@end

NS_ASSUME_NONNULL_END
