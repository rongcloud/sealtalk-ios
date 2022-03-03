//
//  RCDDebugChatViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2020/12/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugChatViewController.h"

@interface RCConversationViewController ()
- (void)reloadRecalledMessage:(long)recalledMsgId;
@end

@interface RCDDebugChatViewController ()<RCMessageInterceptor>

@end

@implementation RCDDebugChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [RCCoreClient sharedCoreClient].messageInterceptor = self;
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
    RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    msg.messagePushConfig = pushConfig;
    msg.messageConfig = config;
    if (msg.messageDirection != MessageDirection_SEND && msg.sentStatus != SentStatus_SENT) {
        NSLog(@"错误，只有发送成功的消息才能撤回！！！");
        return;
    }
    
    [[RCIMClient sharedRCIMClient] recallMessage:msg
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
    
    pushConfig.androidConfig.notificationId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-id"];
    pushConfig.androidConfig.channelIdMi = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-mi"];
    pushConfig.androidConfig.channelIdHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw"];
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

- (RCMessageConfig *)getConfig {
    RCMessageConfig *config = [[RCMessageConfig alloc] init];
    config.disableNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"config-disableNotification"] boolValue];
    return config;
}

@end
