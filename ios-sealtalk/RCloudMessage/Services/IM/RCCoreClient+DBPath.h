//
//  RCCoreClient+DBPath.h
//  SealTalk
//
//  Created by Qi on 2022/3/24.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCoreClient (DBPath)
/*!
 更新消息数据路径，必须要 SDK 初始化之前使用
 @param dbPath 数据库路径，SDK 将会用  dbPath 作为消息数据库路径
 @param bundleId bundleId ，需要设置为 APP 的 BundleId，否则会影响远程推送
 */
- (void)updateMessageDBPath:(NSString *)dbPath withAppBundleId:(NSString *)bundleId;
/*!
 更新实时日志数据库路径，必须要 SDK 初始化之前使用
 @param rtlogPath 数据库路径，SDK 将会用  rtlogPath 作为实时日志数数据库路径
 */
- (void)updateRtLogPath:(NSString *)rtlogPath;

//数据库是否打开，数据库打开关闭的场景
//1. 首次 connect 成功后打开数据库库
//2. 后续使用同一 token，connect 会立即打开数据库，再进行连接
//3. 主动 disconnect 会关闭数据库
//4. 后台任务挂起，会关闭数据库
//5. 后台任务挂起，点击推送或者点击 app，唤醒 app ，SDK 内部会使用同一 token 连接，同 2
- (BOOL)isMessageDBOpened;

/// 更新推送消息发送时间
/// @param time   当前收到的消息时间
- (void)updatePushMessageSentTime:(long long)time;
@end

NS_ASSUME_NONNULL_END
