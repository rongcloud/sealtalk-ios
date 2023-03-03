//
//  RCDDebugUltraGroupSendMessage.m
//  SealTalk
//
//  Created by zafer on 2021/12/28.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugUltraGroupSendMessage.h"

@implementation RCDDebugUltraGroupSendMessage

+ (void)sendMessage:(NSString *)text conversationType:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId {
    RCTextMessage *messageContent = [RCTextMessage messageWithContent:text];
    RCMessage *message = [[RCMessage alloc] initWithType:conversationType targetId:targetId direction:MessageDirection_SEND messageId:0 content:messageContent];
    message.messagePushConfig = [RCDDebugUltraGroupSendMessage getPushConfig];
    message.messageConfig = [RCDDebugUltraGroupSendMessage getConfig];
    if (channelId && channelId.length > 0) {
        message.channelId = channelId;
    }
    
    [[RCCoreClient sharedCoreClient] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
        NSLog(@"...");
    } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
        NSAssert(nErrorCode, @"");
    }];
}

+ (RCMessagePushConfig *)getPushConfig {
    RCMessagePushConfig *pushConfig = [[RCMessagePushConfig alloc] init];
    pushConfig.disablePushTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-disablePushTitle"] boolValue];
    pushConfig.pushTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-title"];
    pushConfig.pushContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-content"];
    pushConfig.pushData = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-data"];
    pushConfig.forceShowDetailContent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-forceShowDetailContent"] boolValue];
    pushConfig.templateId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-templateId"];
    
    pushConfig.iOSConfig.threadId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-threadId"];
    pushConfig.iOSConfig.apnsCollapseId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-apnsCollapseId"];
    pushConfig.iOSConfig.richMediaUri = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-richMediaUri"];
    pushConfig.iOSConfig.category = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-category"];
    
    pushConfig.androidConfig.notificationId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-id"];
    pushConfig.androidConfig.channelIdMi = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-mi"];
    pushConfig.androidConfig.channelIdHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw"];
    pushConfig.androidConfig.categoryHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw-category"];
    pushConfig.androidConfig.channelIdOPPO = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-oppo"];
    pushConfig.androidConfig.typeVivo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-vivo"];
    pushConfig.androidConfig.fcmCollapseKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcm"];
    pushConfig.androidConfig.fcmImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcmImageUrl"];
    pushConfig.androidConfig.importanceHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-importanceHW"];
    pushConfig.androidConfig.hwImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hwImageUrl"];
    pushConfig.androidConfig.miLargeIconUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-miLargeIconUrl"];
    pushConfig.androidConfig.fcmChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcmChannelId"];
    return pushConfig;
}

+ (RCMessageConfig *)getConfig {
    RCMessageConfig *config = [[RCMessageConfig alloc] init];
    config.disableNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"config-disableNotification"] boolValue];
    return config;
}
@end
