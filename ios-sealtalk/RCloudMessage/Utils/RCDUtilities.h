//
//  RCDUtilities.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>
#import "RCDChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDUtilities : NSObject
+ (nullable UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;
+ (nullable NSString *)defaultGroupPortrait:(RCGroup *)groupInfo;
+ (nullable NSString *)defaultUserPortrait:(RCUserInfo *)userInfo;
+ (nullable NSString *)defaultUltraChannelPortrait:(RCDChannel *)channel groupId:(NSString *)groupId;
+ (NSString *)getIconCachePath:(NSString *)fileName;
+ (nullable NSString *)hanZiToPinYinWithString:(NSString *)hanZi;
+ (nullable NSString *)getFirstUpperLetter:(NSString *)hanzi;
+ (nullable NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)userList;
+ (BOOL)isContains:(NSString *)firstString withString:(NSString *)secondString;
+ (UIImage *)getImageWithColor:(UIColor *)color andHeight:(CGFloat)height;
+ (NSString *)getDateString:(long long)time;
+ (CGFloat)getStringHeight:(NSString *)text font:(UIFont *)font viewWidth:(CGFloat)width;
+ (BOOL)isLowerLetter:(NSString *)string;
+ (BOOL)judgeSealTalkAccount:(NSString *)string;
+ (int)getTotalUnreadCount;
+ (void)getGroupUserDisplayInfo:(NSString *)userId
                        groupId:(NSString *)groupId
                         result:(void (^)(RCUserInfo *user))result;
+ (void)getUserDisplayInfo:(NSString *)userId complete:(void (^)(RCUserInfo *user))completeBlock;
+ (BOOL)stringContainsEmoji:(NSString *)string;
/**
动态颜色设置

 @param lightColor  亮色
 @param darkColor  暗色
 @return 修正后的图片
*/
+ (UIColor *)generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;

/// 判断字符串中是否包含汉字
+ (BOOL)includeChinese:(NSString *)string;

/// 转换会话类型为文字描述
+ (NSString *)getConversationTypeName:(RCConversationType)type;

/// 转换拦截类型为文字描述
+ (NSString *)getBlockTypeName:(RCMessageBlockType)type;

/// 转换拦截的消息源类型为文字描述
+ (NSString *)getSourceTypeName:(NSInteger)type;

/// 保存图片到相册
+ (void)savePhotosAlbumWithImage:(UIImage *)image authorizationStatusBlock:(nullable dispatch_block_t)authorizationStatusBlock resultBlock:(nullable void (^)(BOOL success))resultBlock;

@end

NS_ASSUME_NONNULL_END
