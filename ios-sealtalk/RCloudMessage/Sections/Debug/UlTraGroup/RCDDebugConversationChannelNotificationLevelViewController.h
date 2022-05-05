//
//  RCDDebugConversationChannelNotificationLevelViewController.h
//  SealTalk
//
//  Created by jiangchunyu on 2022/2/25.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCDUltraGroupSettingType) {
    RCDUltraGroupSettingTypeConversationChannel, //0表示设置频道通知级别
    RCDUltraGroupSettingTypeConversation, //1表示设置会话通知级别
    RCDUltraGroupSettingTypeConversationType,  //2表示设置会话类型通知级别
    RCDUltraGroupSettingTypeConversationDefault, // 会话默认级别设置
    RCDUltraGroupSettingTypeConversationChannelDefault // 频道默认级别设置
};
@interface RCDDebugConversationChannelNotificationLevelViewController : UIViewController

@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, assign) RCConversationType type;
@property (nonatomic, assign) RCDUltraGroupSettingType settingType; /* 0表示设置频道通知级别，1表示设置会话通知级别, 2表示设置会话类型通知级别 */

@end

NS_ASSUME_NONNULL_END
