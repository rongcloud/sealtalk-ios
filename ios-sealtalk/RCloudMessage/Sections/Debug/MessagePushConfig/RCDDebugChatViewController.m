//
//  RCDDebugChatViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2020/12/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugChatViewController.h"

@class RCGroupMessageDeliverUser;
@class RCGroupMessageDeliverInfo;
@class RCPrivateMessageDeliverInfo;
@interface RCGroupMessageDeliverInfo : RCMessageContent

@property (nonatomic, copy)  NSString *messageUId;

@property (nonatomic, assign) int deliverCount;
@end

@interface RCGroupMessageDeliverUser : NSObject

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, assign) long long deliverTime;
@end

@interface RCPrivateMessageDeliverInfo : NSObject
@property (nonatomic, copy) NSString *messageUId;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) NSString *objectName;
@property (nonatomic, assign) long long deliverTime;
@end

#pragma mark - 消息送达（使用需开通）
/**
 IMLib 消息送达监听器
 */
@protocol RCMessageDeliverDelegate <NSObject>
@optional
/**
 单聊中消息送达的回调
 
 @param deliverList 送达列表
 */
- (void)onPrivateMessageDelivered:(NSArray <RCPrivateMessageDeliverInfo *>*)deliverList;

/**
群聊中消息送达的回调
@param targetId 群 Id
@param totalCount 群内总人数
@param deliverList 送达列表
*/
- (void)onGroupMessageDelivered:(NSString *)targetId
                      channelId:(NSString *)channelId
                     totalCount:(int)totalCount
                    deliverList:(NSArray <RCGroupMessageDeliverInfo *>*)deliverList;
@end


@interface RCChannelClient ()

/*!
 单聊消息送达代理
 
 @discussion 只支持单聊
 */
@property (nonatomic, weak) id<RCMessageDeliverDelegate> messageDeliverDelegate;

- (void)getPrivateMessageDeliverTime:(NSString *)messageUId
                           channelId:(NSString *)channelId
                             success:(void (^)(long long deliverTime))successBlock
                               error:(void (^)(RCErrorCode errorCode))errorBlock;

- (void)getGroupMessageDeliverList:(NSString *)messageUId
                          targetId:(NSString *)targetId
                         channelId:(NSString *)channelId
                           success:(void (^)(int totalCount, NSArray <RCGroupMessageDeliverUser *> *deliverList))successBlock
                             error:(void (^)(RCErrorCode errorCode))errorBlock;

@end

@interface RCConversationViewController ()
- (void)reloadRecalledMessage:(long)recalledMsgId;
@end

@interface RCDDebugChatViewController ()<RCMessageInterceptor, RCMessageDeliverDelegate>

@end

@implementation RCDDebugChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [RCCoreClient sharedCoreClient].messageInterceptor = self;
    [RCChannelClient sharedChannelManager].messageDeliverDelegate = self;
    [self addTestPlugin];
}

- (void)addTestPlugin {
    [self.chatSessionInputBarControl.pluginBoardView insertItem:RCResourceImage(@"plugin_item_file") highlightedImage:RCResourceImage(@"plugin_item_file_highlighted") title:@"系统消息" tag:9900];
}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    if (tag == 9900) {
        NSString *str = [NSString stringWithFormat:@"系统消息%@",[NSDate date]];
        RCTextMessage *content = [RCTextMessage messageWithContent:str];
        [[RCCoreClient sharedCoreClient] sendMessage:ConversationType_SYSTEM targetId:self.targetId content:content pushContent:nil pushData:nil success:nil error:nil];
    }else {
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    }
}

- (void)didTapMessageCell:(RCMessageModel *)model {
    if (self.conversationType == ConversationType_PRIVATE) {
        // 获取单聊中对应消息的送达时间
        [[RCChannelClient sharedChannelManager] getPrivateMessageDeliverTime:model.messageUId channelId:@"" success:^(long long deliverTime) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [NSString stringWithFormat:@"送达时间：%@", [RCKitUtility convertMessageTime:deliverTime / 1000]];
                [RCAlertView showAlertController:@"主动获取单聊消息送达" message:message cancelTitle:@"cancel"];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [NSString stringWithFormat:@"errorCode：%@", @(errorCode)];
                [RCAlertView showAlertController:@"主动获取单聊消息送达失败" message:message cancelTitle:@"cancel"];
            });
        }];
    }else if (self.conversationType == ConversationType_GROUP) {
        // 获取群组中对应消息的送达时间
        [[RCChannelClient sharedChannelManager] getGroupMessageDeliverList:model.messageUId  targetId:self.targetId channelId:@"" success:^(int totalCount, NSArray<RCGroupMessageDeliverUser *> *deliverList) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableString *message = [[NSMutableString alloc] init];
                for (RCGroupMessageDeliverUser *info in deliverList) {
                    NSString *tempMsg = [NSString stringWithFormat:@"userId：%@，deliverTime：%@\n", info.userId, [RCKitUtility convertMessageTime:info.deliverTime / 1000]];
                    [message appendString:tempMsg];
                }
                [RCAlertView showAlertController:@"主动获取群聊消息送达" message:message cancelTitle:@"cancel"];
            });
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [NSString stringWithFormat:@"errorCode：%@", @(errorCode)];
                [RCAlertView showAlertController:@"主动获取群聊消息送达失败" message:message cancelTitle:@"cancel"];
            });
        }];
    } else {
        [super didTapMessageCell:model];
    }
}

- (RCMessage *)messageWillSendAfterDB:(RCMessage *)message {
    RCMessagePushConfig *pushConfig = [self getPushConfig];
    RCMessageConfig *config = [self getConfig];
    message.messagePushConfig = pushConfig;
    message.messageConfig = config;
    return message;
}

- (void)recallMessage:(long)messageId {
    RCMessagePushConfig *pushConfig = [self getPushConfig];
    RCMessageConfig *config = [self getConfig];
    RCMessage *msg = [[RCCoreClient sharedCoreClient] getMessage:messageId];
    msg.messagePushConfig = pushConfig;
    msg.messageConfig = config;
    if (msg.messageDirection != MessageDirection_SEND && msg.sentStatus != SentStatus_SENT) {
        NSLog(@"错误，只有发送成功的消息才能撤回！！！");
        return;
    }
    
    [[RCCoreClient sharedCoreClient] recallMessage:msg
                                     pushContent:nil
                                         success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadRecalledMessage:messageId];
        });
    }
                                           error:^(RCErrorCode errorcode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [RCAlertView showAlertController:nil message:RCLocalizedString(@"MessageRecallFailed") cancelTitle:RCLocalizedString(@"OK") inViewController:self];
        });
    }];
}

- (RCMessagePushConfig *)getPushConfig {
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
    pushConfig.iOSConfig.interruptionLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-interruptionLevel"];

    pushConfig.androidConfig.notificationId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-id"];
    pushConfig.androidConfig.channelIdMi = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-mi"];
    pushConfig.androidConfig.channelIdHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw"];
    pushConfig.androidConfig.categoryHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw-category"];
    pushConfig.androidConfig.channelIdOPPO = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-oppo"];
    pushConfig.androidConfig.typeVivo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-vivo"];
    pushConfig.androidConfig.categoryVivo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-vivo-category"];
    pushConfig.androidConfig.fcmCollapseKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcm"];
    pushConfig.androidConfig.fcmImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcmImageUrl"];
    pushConfig.androidConfig.importanceHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-importanceHW"];
    pushConfig.androidConfig.hwImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hwImageUrl"];
    pushConfig.androidConfig.miLargeIconUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-miLargeIconUrl"];
    pushConfig.androidConfig.fcmChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcmChannelId"];
    // honor
    pushConfig.androidConfig.importanceHonor = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-importanceHonor"];
    pushConfig.androidConfig.imageUrlHonor = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-imageUrlHonor"];
    return pushConfig;
}

- (RCMessageConfig *)getConfig {
    RCMessageConfig *config = [[RCMessageConfig alloc] init];
    config.disableNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"config-disableNotification"] boolValue];
    return config;
}

#pragma mark - RCMessageDeliverDelegate
- (void)onPrivateMessageDelivered:(NSArray <RCPrivateMessageDeliverInfo *>*)deliverList {
    
    NSMutableString *message = [[NSMutableString alloc] init];
    for (RCPrivateMessageDeliverInfo *info in deliverList) {
        NSString *tempMsg = [NSString stringWithFormat:@"targetId：%@，messageUId：%@，deliverTime：%@\n", info.targetId, info.messageUId, [RCKitUtility convertMessageTime:info.deliverTime / 1000]];
        [message appendString:tempMsg];
    }
    
    [RCAlertView showAlertController:@"单聊消息已送达" message:message cancelTitle:@"cancel"];
}


- (void)onGroupMessageDelivered:(NSString *)targetId channelId:(NSString *)channelId totalCount:(int)totalCount deliverList:(NSArray<RCGroupMessageDeliverInfo *> *)deliverList{
    NSMutableString *message = [NSMutableString stringWithFormat:@"targetId：%@,channelId:%@ totalCount:%@\n",targetId,channelId,@(totalCount)];
    for (RCGroupMessageDeliverInfo *info in deliverList) {
        NSString *tempMsg = [NSString stringWithFormat:@"messageUId：%@，deliverCount：%@\n", info.messageUId, @(info.deliverCount)];
        [message appendString:tempMsg];
    }
    [RCAlertView showAlertController:@"群聊消息送达百分比" message:message cancelTitle:@"cancel"];
}
@end
