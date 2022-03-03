//
//  RCDDebugUltraGroupDefine.h
//  SealTalk
//
//  Created by zafer on 2021/12/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RCDDebugNotificationType) {
    RCDDebugNotificationTypeDelete = 0,
    RCDDebugNotificationTypeSendMsgKV
};

extern NSString *kRCDDebugChatSettingNotification;

extern NSString *kRCDebugKVMessageKey;
