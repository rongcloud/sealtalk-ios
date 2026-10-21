//
//  RCDDebugComChatViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDDebugComChatViewController.h"

#import "RCDAddFriendViewController.h"
#import "RCDGroupSettingsTableViewController.h"
#import "RCDPersonDetailViewController.h"
#import "RCDPrivateSettingsTableViewController.h"
#import "RCDReceiptDetailsTableViewController.h"
#import "RCDTestMessage.h"
#import "RCDTestMessageCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDForwardManager.h"

#import "RCDCommonString.h"
#import "RCDIMService.h"
#import "RCDCustomerEmoticonTab.h"
#import <RongContactCard/RongContactCard.h>
#import "RCDGroupManager.h"
#import "RCDImageSlideController.h"
#import "RCDForwardSelectedViewController.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDChatNotificationMessage.h"
#import "RCDTipMessageCell.h"
#import "RCDChooseUserController.h"
#import "RCDChatManager.h"
#import "RCDPokeAlertView.h"
#import "RCDQuicklySendManager.h"
#import "RCDPokeMessage.h"
#import "RCDPokeMessageCell.h"
#import "RCDRecentPictureViewController.h"
#import "RCDPokeManager.h"
#import "NormalAlertView.h"
#import <Masonry/Masonry.h>
#import "UIView+MBProgressHUD.h"
#import "RCDSettingViewController.h"
#import <RongPublicService/RongPublicService.h>

/*******************实时位置共享***************/
#import <objc/runtime.h>
#import "RealTimeLocationEndCell.h"
#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationViewController.h"
#import "RealTimeLocationDefine.h"

#import "RCDebugComAPIViewController.h"

@interface RCDChatViewController()
- (void)rightBarButtonItemClicked:(RCConversationModel *)model;
@end
@interface RCDDebugComChatViewController ()<RCMessageBlockDelegate>
@property (nonatomic, strong) RCMessageModel *currMessageModel;
@end

@implementation RCDDebugComChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
    self.placeholderLabel.text = @"测试 Placeholder";
    self.placeholderLabel.textColor = [UIColor grayColor];
    
    [RCCoreClient sharedCoreClient].messageBlockDelegate = self;
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    NSArray<UIMenuItem *> *menuList = [[super getLongTouchMessageCellMenuList:model] mutableCopy];
    
    // 测试删除消息
    /*!
     删除消息并更新UI

     @param model 消息Cell的数据模型
     @discussion
     v5.2.3 之前 会话页面只删除本地消息，如果需要删除远端历史消息，需要
        1.重写该方法，并调用 super 删除本地消息
        2.调用删除远端消息接口，删除远端消息
     
     v5.2.3及以后，会话页面会根据 needDeleteRemoteMessage 设置进行处理
        如未设置默认值为NO， 只删除本地消息
        设置为 YES 时， 会同时删除远端消息
     
     - (void)deleteMessage:(RCMessageModel *)model;
     */

    int idx = 0;
    int i = 0;
    NSMutableArray *list = menuList.mutableCopy;
    for (UIMenuItem *item in menuList) {
        i++;
        if ([item.title isEqualToString:RCLocalizedString(@"Delete")]) {
            idx = i;
            break;
        }
    }

    UIMenuItem *delItem = [[UIMenuItem alloc] initWithTitle:@"删除远端" action:@selector(onDeleteRemoteMessage:)];
    [list insertObject:delItem atIndex:idx];
    
    UIMenuItem *updateBlockKVItem = [[UIMenuItem alloc] initWithTitle:@"更新敏感KV" action:@selector(updateBlockKV)];
    [list addObject:updateBlockKVItem];

    self.currMessageModel = model;
    return list.copy;
}

#pragma mark - target action

//删除远端消息内容
- (void)onDeleteRemoteMessage:(id)sender {
    BOOL isSourceValue = self.needDeleteRemoteMessage;
    // 标记删除远端
    self.needDeleteRemoteMessage = YES;
    [self deleteMessage:self.currMessageModel];
    // 恢复原值
    self.needDeleteRemoteMessage = isSourceValue;
}

//更新携带敏感词KV
- (void)updateBlockKV {
    
    NSString *currentUserId = [RCCoreClient sharedCoreClient].currentUserInfo.userId;
    NSString *senderUserId = self.currMessageModel.senderUserId;
    
    RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:self.currMessageModel.messageUId];

    if ([currentUserId isEqualToString:senderUserId] && message.canIncludeExpansion) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        dic[@"123"] = @"毛泽东";
        [[RCCoreClient sharedCoreClient] updateMessageExpansion:dic messageUId:message.messageUId success:^{
            RCMessage *msg = [[RCCoreClient sharedCoreClient] getMessageByUId:message.messageUId];
            NSLog(@"Expansion %@", msg.expansionDic);
            NSString *text = [NSString stringWithFormat:@"KV已改为%@", msg.expansionDic];
            [self showAlertTitle:msg.messageUId message:text];
        } error:^(RCErrorCode status) {
            [self showToastMsg:[NSString stringWithFormat:@"msgUid:%@的KV更新失败%zd",message.messageUId,status]];
        }];
    } else {
        [self showAlertTitle:nil message:@"请确定是否是自己发的可扩展消息"];
    }
}

- (void)sendKVTextMessage {
    
    RCTextMessage *messageContent = [RCTextMessage messageWithContent:@"携带KV的文本消息"];
    RCMessage *message = [[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:MessageDirection_SEND messageId:-1 content:messageContent];
    message.messagePushConfig = [self getPushConfig];
    message.messageConfig = [self getConfig];
    message.channelId = self.channelId;
    message.canIncludeExpansion = YES;
    message.expansionDic = @{@"tKey":[self getTimeString]};
    
    __weak typeof(self) weakSelf = self;
    [[RCCoreClient sharedCoreClient] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
        [weakSelf appendAndDisplayMessage:successMessage];
        [self showToastMsg:@"发送携带KV的文本消息成功"];
    } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
        [self showAlertTitle:nil message:[NSString stringWithFormat:@"send message failed:%ld",(long)nErrorCode]];
    }];
}

// 发送携带敏感词KV的消息
- (void)sendBlockKVTextMessage {
    
    RCTextMessage *messageContent = [RCTextMessage messageWithContent:@"携带敏感词KV的文本消息"];
    RCMessage *message = [[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:MessageDirection_SEND messageId:-1 content:messageContent];
    message.messagePushConfig = [self getPushConfig];
    message.messageConfig = [self getConfig];
    message.channelId = self.channelId;
    message.canIncludeExpansion = YES;
    message.expansionDic = @{@"123":@"毛泽东"};
    
    __weak typeof(self) weakSelf = self;
    [[RCCoreClient sharedCoreClient] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
        [weakSelf appendAndDisplayMessage:successMessage];
        [self showToastMsg:@"发送携带敏感词KV的文本消息成功"];
    } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
        [self showAlertTitle:nil message:[NSString stringWithFormat:@"send message failed:%ld",(long)nErrorCode]];
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
    pushConfig.hmosConfig.category = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-HarmonyOS-category"];
    pushConfig.hmosConfig.imageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-HarmonyOS-imageUrl"];
    return pushConfig;
}

- (RCMessageConfig *)getConfig {
    RCMessageConfig *config = [[RCMessageConfig alloc] init];
    config.disableNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"config-disableNotification"] boolValue];
    return config;
}

- (NSString *)getTimeString {
    NSDateFormatter *dateFormart = [[NSDateFormatter alloc]init];
    [dateFormart setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateFormart.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateString = [dateFormart stringFromDate:[NSDate date]];
    return dateString;
}

- (void)showToastMsg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}

- (void)showAlertTitle:(NSString *)title message:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCAlertView showAlertController:title message:msg cancelTitle:RCDLocalizedString(@"confirm")];
    });
}

/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
    RCDebugComAPIViewController *vc = [RCDebugComAPIViewController new];
    vc.targetId = self.targetId;
    vc.type = self.conversationType;
    vc.channelId = self.channelId;
    __weak typeof(self) weakSelf = self;
    vc.selectedBlock = ^(RCDComChatroomOptionCategory category) {
        switch (category) {
            case RCDComChatroomOptionCategory6_1:
                [weakSelf sendKVTextMessage];
                break;
            case RCDComChatroomOptionCategory6_2:
                [weakSelf sendBlockKVTextMessage];
                break;

            default:
                break;
        }
    };
    [self.navigationController pushViewController:vc animated:YES];

    /*
    if (self.conversationType == ConversationType_PRIVATE) {
        RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:self.targetId];
        if (friendInfo && friendInfo.status != RCDFriendStatusAgree && friendInfo.status != RCDFriendStatusBlock) {
            [self pushFriendVC:friendInfo];
        } else {
            RCDPrivateSettingsTableViewController *settingsVC = [[RCDPrivateSettingsTableViewController alloc] init];
            settingsVC.userId = self.targetId;
            __weak typeof(self) weakSelf = self;
            [settingsVC setClearMessageHistory:^{
                
                [weakSelf clearHistoryMSG];
            }];
            [self.navigationController pushViewController:settingsVC animated:YES];
        }
    }
    //群组设置
    else if (self.conversationType == ConversationType_GROUP) {
        RCDGroupSettingsTableViewController *settingsVC = [[RCDGroupSettingsTableViewController alloc] init];
        if (_groupInfo == nil) {
            settingsVC.group = [RCDGroupManager getGroupInfo:self.targetId];
        } else {
            settingsVC.group = self.groupInfo;
        }
        __weak typeof(self) weakSelf = self;
        [settingsVC setClearMessageHistory:^{
            [weakSelf clearHistoryMSG];
        }];
        [self.navigationController pushViewController:settingsVC animated:YES];
    }
    //客服设置
    else if (self.conversationType == ConversationType_CUSTOMERSERVICE ||
             self.conversationType == ConversationType_SYSTEM) {
        RCDSettingViewController *settingVC = [[RCDSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        //清除聊天记录之后reload data
        __weak RCDChatViewController *weakSelf = self;
        [settingVC setClearMessageHistory:^{
            [weakSelf.conversationDataRepository removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.conversationMessageCollectionView reloadData];
            });
        }];
        [self.navigationController pushViewController:settingVC animated:YES];
    } else if (ConversationType_APPSERVICE == self.conversationType ||
               ConversationType_PUBLICSERVICE == self.conversationType) {
        RCPublicServiceProfile *serviceProfile =
            [[RCPublicServiceClient sharedPublicServiceClient] getPublicServiceProfile:(RCPublicServiceType)self.conversationType
                                                   publicServiceId:self.targetId];

        RCPublicServiceProfileViewController *infoVC = [[RCPublicServiceProfileViewController alloc] init];
        infoVC.serviceProfile = serviceProfile;
        infoVC.fromConversation = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    }
     */
}


#pragma mark - RCMessageBlockDelegate
- (void)messageDidBlock:(RCBlockedMessageInfo *)blockedMessageInfo {
    NSString *blockTypeName = [RCDUtilities getBlockTypeName:blockedMessageInfo.blockType];
    NSString *ctypeName = [RCDUtilities getConversationTypeName:blockedMessageInfo.type];
    NSString *sentTimeFormat = [RCDUtilities getDateString:blockedMessageInfo.sentTime];
    NSString *sourceTypeName = [RCDUtilities getSourceTypeName:blockedMessageInfo.sourceType];
    NSString *msg = [NSString stringWithFormat:@"会话类型: %@,\n会话ID: %@,\n消息ID:%@,\n消息时间戳:%@,\n频道ID: %@,\n附加信息: %@,\n拦截原因:%@(%@),\n消息源类型:%@(%@),\n消息源内容:%@", ctypeName, blockedMessageInfo.targetId, blockedMessageInfo.blockedMsgUId, sentTimeFormat, blockedMessageInfo.channelId, blockedMessageInfo.extra, @(blockedMessageInfo.blockType), blockTypeName, @(blockedMessageInfo.sourceType), sourceTypeName, blockedMessageInfo.sourceContent];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showAlertTitle:nil message:msg];
    });
}

@end
