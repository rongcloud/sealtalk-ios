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

@end

@implementation RCDDebugComChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
    self.placeholderLabel.text = @"测试 Placeholder";
    self.placeholderLabel.textColor = [UIColor grayColor];
}

#pragma mark - target action
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
