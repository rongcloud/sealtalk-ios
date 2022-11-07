//
//  RCNotificationServiceAppPlugin.h
//  SealTalk
//
//  Created by Qi on 2022/3/31.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 本类由 APP 使用
@interface RCNotificationServiceAppPlugin : NSObject

+ (instancetype)sharedInstance;

/// 配置接口
/// @warning 必须在 SDK init 之前调用，否则会出现正在使用的消息数据库被移动到共享路径而无法收发消息的问题
/// @param identifier AppGroup 的 identifier
/// @param appkey 融云 AppKey
/// @param userId 当前用户 ID
/// @param imToken 当前用户的  imToken
/// 会做以下事情
/// 1. 设置 APP & NotificationService 的跨进程监听
/// 2. 移动 IMLibCore 默认的消息数据路径到 APP & NotificationService 的共享路径
/// 3. 更新 IMLibCore 消息数据库路径为  APP & NotificationService 的共享路径
/// 4. 将 appkey userId imToken 等数据存到 NotificationService AppGroup 路径中，方便 NotificationService 获取
/// @warning APP 必须保证 imToken & userId 是同一个用户的，否则会出现错误移动 {userId} 的数据，会导致对应用户本地数据库消息丢失
- (void)configWithApplicationGroupIdentifier:(NSString *)identifier appkey:(NSString *)appkey userId:(NSString *)userId token:(NSString *)imToken API_AVAILABLE(ios(10.0));

/// 更新 DeviceToken
/// @param deviceToken APNs 的 deviceToken
/// 说明：RCCoreClient 中设置 deviceToken 的接口需要调用，保证 APP 能正常推送
/// 此接口也需要调用，NotificationService 才能获取 deviceToken
/// @warning 如果 app 没有调用该接口，那么推送收到一次之后就不会再收到了
- (void)updateDeviceTokenData:(NSData *)deviceToken API_AVAILABLE(ios(10.0));

/// 更新 app 角标数字
/// @param badge 角标数字
/// @discussion 如果传入了 > 0 的角标，当 NotificationService 启动时，收到消息就会在角标基础上累加
- (void)updateAppBadge:(NSUInteger)badge;
@end

NS_ASSUME_NONNULL_END
