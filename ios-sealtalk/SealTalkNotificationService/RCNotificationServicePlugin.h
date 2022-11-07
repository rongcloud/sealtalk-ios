//
//  RCNotificationServicePlugin.h
//  SealTalkNotificationService
//
//  Created by Qi on 2022/3/31.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
NS_ASSUME_NONNULL_BEGIN

/// 本类由 APP 的 NotificationService 使用
/// 在 NotificationService 的 didReceiveNotificationRequest: 方法中处理
/// 1. 设置 APPGroupId
/// 2. 连接 IM，接收完远程推送的消息后，立马断开连接
@interface RCNotificationServicePlugin : NSObject

+ (instancetype)sharedInstance;

/// 配置 AppGroupId 与代理
/// @param identifier AppGroupId
/// 保存 AppGroupId，并设置 APP & NotificationService 的跨进程监听
- (void)configApplicationGroupIdentifier:(NSString *)identifier API_AVAILABLE(ios(10.0));

/// 连接 IM
- (void)connectIMWithNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler API_AVAILABLE(ios(10.0));

/// 在 NotificationService  serviceExtensionTimeWillExpire 方法调用该方法，将会强制断开 IM，并使用传入的 contentHandler
- (void)serviceExtensionTimeWillExpire;
@end


NS_ASSUME_NONNULL_END
