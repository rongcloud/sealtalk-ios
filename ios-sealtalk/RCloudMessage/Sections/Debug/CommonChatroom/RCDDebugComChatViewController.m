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
@interface RCDDebugComChatViewController ()
@property (nonatomic, strong) RCMessageModel *currMessageModel;
@end

@implementation RCDDebugComChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
    self.placeholderLabel.text = @"测试 Placeholder";
    self.placeholderLabel.textColor = [UIColor grayColor];
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


/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
    RCDebugComAPIViewController *vc = [RCDebugComAPIViewController new];
    vc.targetId = self.targetId;
    vc.type = self.conversationType;
    vc.channelId = self.channelId;
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

@end
