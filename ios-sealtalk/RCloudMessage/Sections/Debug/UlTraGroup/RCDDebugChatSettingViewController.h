//
//  RCDDebugChatSettingViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2021/11/29.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDDebugChatSettingViewController : RCDViewController

@property (nonatomic, strong) NSString *targetId;

@property (nonatomic, strong) NSString *channelId;

@property (nonatomic, assign) RCConversationType type;

@property (nonatomic, assign) long long recordTime;

@end

NS_ASSUME_NONNULL_END
