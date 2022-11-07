//
//  RCDChatViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDChatViewController.h"
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
#import "RCDChatTitleAlertView.h"

/*******************实时位置共享***************/
#import <objc/runtime.h>
#import "RealTimeLocationEndCell.h"
#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationViewController.h"
#import "RealTimeLocationDefine.h"
#import <RongLocation/RongLocation.h>
#import "RCDSemanticContext.h"
static const char *kRealTimeLocationKey = "kRealTimeLocationKey";
static const char *kRealTimeLocationStatusViewKey = "kRealTimeLocationStatusViewKey";

#define PLUGIN_BOARD_ITEM_POKE_TAG 20000

@interface RCConversationViewController ()
// 小视频录制失败回调
- (void)sightDidRecordFailedWith:(NSError *)error status:(NSInteger)status;
@end

@interface RCDChatViewController () <RCMessageCellDelegate, RCDQuicklySendManagerDelegate, UIGestureRecognizerDelegate, RealTimeLocationStatusViewDelegate, RCRealTimeLocationObserver, RCMessageBlockDelegate, RCChatRoomMemberDelegate>
@property (nonatomic, strong) RCDGroupInfo *groupInfo;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL loading;

/*******************实时位置共享***************/
@property (nonatomic, weak) id<RCRealTimeLocationProxy> realTimeLocation;
@property (nonatomic, strong) RealTimeLocationStatusView *realTimeLocationStatusView;
@property (nonatomic, assign) BOOL drawAsyncEnable;
@property (nonatomic, assign) BOOL hidePortrait;
@end

@implementation RCDChatViewController

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
        self.loadMessageType = [[NSUserDefaults standardUserDefaults] integerForKey:@"RCDChatLoadMessageType"];
    }
    return self;
}

- (id)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId {
    self = [super initWithConversationType:conversationType targetId:targetId];
    [self initData];
    return self;
}

- (void)initData {
    int defalutHistoryMessageCount = (int)[DEFAULTS integerForKey:RCDChatroomDefalutHistoryMessageCountKey];
    self.defaultHistoryMessageCountOfChatRoom = defalutHistoryMessageCount;

    // 初始化时需要读取焚毁状态
    BOOL isBurnMessageOn = [DEFAULTS boolForKey:RCDDebugBurnMessageKey];
    RCKitConfigCenter.message.enableDestructMessage = isBurnMessageOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loading = NO;
    self.enableSaveNewPhotoToLocalSystem = YES;
    [self notifyUpdateUnreadMessageCount];
    [self addOtherPluginBoard];

    [self refreshUserInfoOrGroupInfo];
    [self addNotifications];
    //    [self addToolbarItems];
    
    // 防欺诈层级要比共享位置低
    [self setupFraudPreventionTipsView];
    
    /*******************实时位置共享***************/
    [self registerRealTimeLocationCell];
    [self getRealTimeLocationProxy];
    /******************实时位置共享**************/

    //    self.enableContinuousReadUnreadVoice = YES;//开启语音连读功能

    [self handleChatSessionInputBarControlDemo];
    [self insertMessageDemo];
    [self addEmoticonTabDemo];
    [self addQuicklySendImage];
    [self setupChatBackground];
    
    [RCCoreClient sharedCoreClient].messageBlockDelegate = self;
    
    if (self.conversationType == ConversationType_CHATROOM) {
        // 此功能需要提交工单开通才能使用
        [RCChatRoomClient sharedChatRoomClient].memberDelegate = self;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *hidePortrait = [userDefault valueForKey:RCDDebugHidePortraitEnable];
    self.hidePortrait = [hidePortrait boolValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 持久化中读取焚毁状态
    self.defaultInputType = [[RCDIMService sharedService] getInputStatus:self.conversationType targetId:self.targetId];
    
    [self refreshTitle];
    self.isShow = YES;
    RCConversation *conver = [[RCConversation alloc] init];
    conver.conversationType = self.conversationType;
    conver.targetId = self.targetId;
    [RCDPokeManager sharedInstance].currentConversation = conver;
    //    [self.chatSessionInputBarControl updateStatus:self.chatSessionInputBarControl.currentBottomBarStatus
    //    animated:NO];
    [self showDynamicPhrasesIfNeed];
}


/// 动态常用语
- (void)showDynamicPhrasesIfNeed {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL ret = [[userDefault valueForKey:RCDDebugCommonPhrasesEnable] boolValue];
    if (ret) {
        NSMutableArray *array = [NSMutableArray array];
        int num = random()%10;
        for (int i = 0; i< num; i++) {
            NSString *phrase = [NSString stringWithFormat:@"常用语 -> %d", i];
            [array addObject:phrase];
        }
        [self.chatSessionInputBarControl setCommonPhrasesList:array];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resetQucilySendView];
    self.isShow = NO;
    [RCDPokeManager sharedInstance].currentConversation = nil;
    
    // 退出页面时， 保存当前状态
    [self saveInputDestructStatus];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self updateSubviews:size];
        }];
}

- (void)updateSubviews:(CGSize)size {
    CGRect frame = self.realTimeLocationStatusView.frame;
    frame.size.width = self.view.bounds.size.width;
    self.realTimeLocationStatusView.frame = frame;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [self.realTimeLocation quitRealTimeLocation];
    }
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.conversationMessageCollectionView removeObserver:self forKeyPath:@"frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 小视频录制失败回调
- (void)sightDidRecordFailedWith:(NSError *)error status:(NSInteger)status {
    [super sightDidRecordFailedWith:error status:status];
    NSString *msg = [NSString stringWithFormat:@"录制失败（code:%lu, AVAssetWriter status: %lu)", error.code, status];
    [NormalAlertView showAlertWithTitle:nil
                                message:msg
                          describeTitle:nil
                           confirmTitle:RCDLocalizedString(@"confirm")
                                confirm:^{
    }];
}

#pragma mark - RCMessageBlockDelegate
- (void)messageDidBlock:(RCBlockedMessageInfo *)blockedMessageInfo {
    rcd_dispatch_main_async_safe((^{
        [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
        NSString *blockTypeName = [RCDUtilities getBlockTypeName:blockedMessageInfo.blockType];
        NSString *ctypeName = [RCDUtilities getConversationTypeName:blockedMessageInfo.type];
        NSString *sentTimeFormat = [RCDUtilities getDateString:blockedMessageInfo.sentTime];
        NSString *sourceTypeName = [RCDUtilities getSourceTypeName:blockedMessageInfo.sourceType];
        NSString *msg = [NSString stringWithFormat:@"会话类型: %@,\n会话ID: %@,\n消息ID:%@,\n消息时间戳:%@,\n频道ID: %@,\n附加信息: %@,\n拦截原因:%@(%@),\n消息源类型:%@(%@),\n消息源内容:%@", ctypeName, blockedMessageInfo.targetId, blockedMessageInfo.blockedMsgUId, sentTimeFormat, blockedMessageInfo.channelId, blockedMessageInfo.extra, @(blockedMessageInfo.blockType), blockTypeName, @(blockedMessageInfo.sourceType), sourceTypeName, blockedMessageInfo.sourceContent];

        [NormalAlertView showAlertWithTitle:nil
                                    message:msg
                              describeTitle:nil
                               confirmTitle:RCDLocalizedString(@"confirm")
                                    confirm:^{
        }];
    }));
}

#pragma mark - RCChatRoomMemberDelegate
- (void)memberDidChange:(NSArray<RCChatRoomMemberAction *> *)members inRoom:(NSString *)roomId {
    NSLog(@"%luu",(unsigned long) (unsigned long)members.count);
    
    NSString *text = @"";
    for (RCChatRoomMemberAction *member in members) {
        text = [text stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"成员 %@ %@了聊天室：%@\n", member.memberId, (member.action == RC_ChatRoom_Member_Join) ? @"加入": @"退出", roomId]];
    }
    
    rcd_dispatch_main_async_safe((^{
        [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
        [NormalAlertView showAlertWithTitle:nil
                                    message:text
                              describeTitle:nil
                               confirmTitle:RCDLocalizedString(@"confirm")
                                    confirm:^{
        }];
    }));
}

#pragma mark - RCMessageCellDelegate
- (void)didTapReceiptCountView:(RCMessageModel *)model {
    if ([model.content isKindOfClass:[RCTextMessage class]]) {
        RCDReceiptDetailsTableViewController *vc = [[RCDReceiptDetailsTableViewController alloc] init];
        vc.message = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)inputTextView:(UITextView *)inputTextView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    [super inputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
    [self resetQucilySendView];
}

#pragma mark - RCDQuicklySendManagerDelegate
- (void)quicklySendViewDidTapImage:(UIImage *)image {
    RCDRecentPictureViewController *vc = [[RCDRecentPictureViewController alloc] init];
    vc.image = image;
    __weak typeof(self) weakSelf = self;
    vc.sendBlock = ^(BOOL isFull) {
        RCImageMessage *imageMsg = [RCImageMessage messageWithImage:image];
        imageMsg.full = isFull;
        [weakSelf sendMessage:imageMsg pushContent:nil];
    };
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    [self resetQucilySendView];
    return YES;
}

#pragma mark - over methods

- (void)sendMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent {
    if (!self.drawAsyncEnable || ![messageContent isKindOfClass:[RCTextMessage class]]) {
        [super sendMessage:messageContent pushContent:pushContent];
        return;
    } else {
        RCTextMessage *msg = (RCTextMessage *)messageContent;
        if ([msg.content isEqualToString:@"a"]) {
            msg.content = [self longString];
        } else if ([msg.content isEqualToString:@"b"]) {
            msg.content = [self complexText];
        }
        [super sendMessage:msg pushContent:pushContent];
    }
   
}


// 注册自定义消息和cell
- (void)registerCustomCellsAndMessages {
    [super registerCustomCellsAndMessages];

    ///注册自定义测试消息Cell
    [self registerClass:[RCDTestMessageCell class] forMessageClass:[RCDTestMessage class]];
    [self registerClass:RCDTipMessageCell.class forMessageClass:RCDGroupNotificationMessage.class];
    [self registerClass:RCDTipMessageCell.class forMessageClass:RCDChatNotificationMessage.class];
    [self registerClass:RCDPokeMessageCell.class forMessageClass:RCDPokeMessage.class];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [userDefault valueForKey:RCDDebugTextAsyncDrawEnable];
    self.drawAsyncEnable = [value boolValue];
    if ([value boolValue]) { //异步绘制
        [self registerClass:[RCComplexTextMessageCell class] forMessageClass:[RCTextMessage class]];
    }
}

- (void)didTapMessageCell:(RCMessageModel *)model {
    if ([model.content isKindOfClass:[RCContactCardMessage class]]) {
        RCContactCardMessage *cardMSg = (RCContactCardMessage *)model.content;
        RCDUserInfo *user =
            [[RCDUserInfo alloc] initWithUserId:cardMSg.userId name:cardMSg.name portrait:cardMSg.portraitUri];
        [self pushPersonDetailVC:user];
        return;
    }
    [super didTapMessageCell:model];
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    NSArray<UIMenuItem *> *menuList = [[super getLongTouchMessageCellMenuList:model] mutableCopy];
    /*
     在这里添加删除菜单。
     [menuList enumerateObjectsUsingBlock:^(UIMenuItem * _Nonnull obj, NSUInteger
     idx, BOOL * _Nonnull stop) {
     if ([obj.title isEqualToString:@"删除"] || [obj.title
     isEqualToString:@"delete"]) {
     [menuList removeObjectAtIndex:idx];
     *stop = YES;
     }
     }];

     UIMenuItem *forwardItem = [[UIMenuItem alloc] initWithTitle:@"转发"
     action:@selector(onForwardMessage:)];
     [menuList addObject:forwardItem];

     如果您不需要修改，不用重写此方法，或者直接return［super
     getLongTouchMessageCellMenuList:model]。
     */
    NSMutableArray *list = menuList.mutableCopy;
    //戳一下消息不能撤回
    if ([[[model.content class] getObjectName] isEqualToString:RCDPokeMessageTypeIdentifier]) {
        for (UIMenuItem *item in menuList) {
            if ([item.title isEqualToString:RCLocalizedString(@"Recall")]) {
                if ([list containsObject:item]) {
                    [list removeObject:item];
                }
            }
        }
    }
    return list.copy;
}

- (void)didTapCellPortrait:(NSString *)userId {
    if (self.conversationType == ConversationType_GROUP || self.conversationType == ConversationType_PRIVATE ||
        self.conversationType == ConversationType_CHATROOM) {
        __weak typeof(self) weakSelf = self;
        [RCDUserInfoManager getUserInfoFromServer:userId
                                         complete:^(RCDUserInfo *userInfo) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakSelf pushPersonDetailVC:userInfo];
                                             });
                                         }];
    }
}

- (void)resendMessageWithModel:(RCMessageModel *)model {
    if ([model.content isKindOfClass:[RCRealTimeLocationStartMessage class]]) {
        [self showRealTimeLocationViewController];
    } else {
        [super resendMessageWithModel:model];
    }
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageContent {
    //可以在这里修改将要发送的消息
    if ([messageContent isMemberOfClass:[RCTextMessage class]]) {
        // RCTextMessage *textMsg = (RCTextMessage *)messageContent;
        // textMsg.extra = @"";
    }
    if (messageContent.mentionedInfo && messageContent.mentionedInfo.userIdList) {
        for (int i = 0; i < messageContent.mentionedInfo.userIdList.count; i++) {
            NSString *userId = messageContent.mentionedInfo.userIdList[i];
            if ([userId isEqualToString:RCDMetionAllUsetId]) {
                messageContent.mentionedInfo.type = RC_Mentioned_All;
                messageContent.mentionedInfo.userIdList = nil;
                break;
            }
        }
    }
    return messageContent;
}

/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param imageMessageContent 图片消息内容
 */
- (void)presentImagePreviewController:(RCMessageModel *)model {
    RCDImageSlideController *previewController = [[RCDImageSlideController alloc] init];
    previewController.messageModel = model;

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:previewController];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    [super didLongTouchMessageCell:model inView:view];
    NSLog(@"%s", __FUNCTION__);
}

- (void)didLongPressCellPortrait:(NSString *)userId {
    if (self.conversationType != ConversationType_GROUP ||
        [userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        return;
    }
    RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:userId];
    RCDGroupMember *memberDetail = [RCDGroupManager getGroupMember:userId groupId:self.targetId];
    if (memberDetail.groupNickname.length > 0) {
        userInfo.name = memberDetail.groupNickname;
    }
    [self.chatSessionInputBarControl addMentionedUser:userInfo];
    [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message {
    if ([message.content isKindOfClass:[RCDGroupNotificationMessage class]]) {
        RCDGroupNotificationMessage *groupNotif = (RCDGroupNotificationMessage *)message.content;
        if ([groupNotif.operation isEqualToString:RCDGroupMemberManagerRemove]) {
            return nil;
        }
    }
    return message;
}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    [self resetQucilySendView];
    switch (tag) {
    case PLUGIN_BOARD_ITEM_LOCATION_TAG: {
        if (self.realTimeLocation) {
            [RCActionSheetView showActionSheetView:nil cellArray:@[RTLLocalizedString(@"send_location"), RTLLocalizedString(@"location_share")]
                                       cancelTitle:RTLLocalizedString(@"cancel")
                                     selectedBlock:^(NSInteger index) {
                if (index == 0) {
                    [super pluginBoardView:self.chatSessionInputBarControl.pluginBoardView
                        clickedItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
                }else{
                    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
                    if (RC_NotReachable == status) {
                        [self.view showHUDMessage:RCDLocalizedString(@"network_can_not_use_please_check")];
                    }else{
                        [self showRealTimeLocationViewController];
                    }
                }
            } cancelBlock:^{
                
            }];
        } else {
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
        }
    }break;
    case PLUGIN_BOARD_ITEM_POKE_TAG: {
        if (self.conversationType == ConversationType_GROUP) {
            RCDGroupMember *member =
                [RCDGroupManager getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:self.targetId];
            if (member) {
                if (member.role == RCDGroupMemberRoleMember) {
                    [NormalAlertView showAlertWithTitle:nil
                                                message:RCDLocalizedString(@"Only_group_owner_and_manager_can_manage")
                                          describeTitle:nil
                                           confirmTitle:RCDLocalizedString(@"confirm")
                                                confirm:^{
                                                }];
                } else {
                    [RCDPokeAlertView showPokeAlertView:self.conversationType
                                               targetId:self.targetId
                                       inViewController:self];
                }
            } else {
                [RCDGroupManager
                    getGroupMembersFromServer:self.targetId
                                     complete:^(NSArray<NSString *> *memberIdList) {
                                         if (memberIdList) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 RCDGroupMember *member = [RCDGroupManager
                                                     getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId
                                                            groupId:self.targetId];
                                                 if (member.role == RCDGroupMemberRoleMember) {
                                                     [NormalAlertView
                                                         showAlertWithTitle:nil
                                                                    message:
                                                                        RCDLocalizedString(
                                                                            @"Only_group_owner_and_manager_can_manage")
                                                              describeTitle:nil
                                                               confirmTitle:RCDLocalizedString(@"confirm")
                                                                    confirm:^{
                                                                    }];
                                                 } else {
                                                     [RCDPokeAlertView showPokeAlertView:self.conversationType
                                                                                targetId:self.targetId
                                                                        inViewController:self];
                                                 }
                                             });
                                         }
                                     }];
            }
        } else if (self.conversationType == ConversationType_PRIVATE) {
            [RCDPokeAlertView showPokeAlertView:self.conversationType targetId:self.targetId inViewController:self];
        }
    } break;
    case PLUGIN_BOARD_ITEM_DESTRUCT_TAG: {
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
        [self saveInputDestructStatus];
    } break;
    default:
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
        break;
    }
}

/**
 *  更新左上角未读消息数
 */
- (void)notifyUpdateUnreadMessageCount {
    if (self.allowsMessageCellSelection) {
        [super notifyUpdateUnreadMessageCount];
        return;
    }
    rcd_dispatch_main_async_safe(^{
        [self setLeftNavigationItem];
        [self setRightNavigationItems];
    });
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage {
    //保存图片, 调用者保障了相册权限已开启
    [RCDUtilities savePhotosAlbumWithImage:newImage authorizationStatusBlock:nil resultBlock:nil];
}

- (void)showChooseUserViewController:(void (^)(RCUserInfo *selectedUserInfo))selectedBlock
                              cancel:(void (^)(void))cancelBlock {
    RCDChooseUserController *userListVC = [[RCDChooseUserController alloc] initWithGroupId:self.targetId];
    userListVC.selectedBlock = selectedBlock;
    userListVC.cancelBlock = cancelBlock;
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:userListVC];
    rootVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:rootVC animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    if ([model.content isKindOfClass:[RCDGroupNotificationMessage class]]) {
        RCDGroupNotificationMessage *groupNotif = (RCDGroupNotificationMessage *)model.content;
        if ([groupNotif.operation isEqualToString:RCDGroupMemberManagerRemove]) {
            [[RCIMClient sharedRCIMClient] deleteMessages:@[ @(model.messageId) ]];
            return CGSizeZero;
        }
    }
    return [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.hidePortrait && [cell isKindOfClass:[RCMessageCell class]]) {
        RCMessageCell *c =  (RCMessageCell *)cell;
        c.showPortrait = indexPath.row%2 == 0;
    }
    [super willDisplayMessageCell:cell atIndexPath:indexPath];
}
#pragma mark - target action
/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
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
}

- (void)updateForSharedMessageInsertSuccess:(NSNotification *)notification {
    RCMessage *message = notification.object;
    if (message.conversationType == self.conversationType && [message.targetId isEqualToString:self.targetId]) {
        [self appendAndDisplayMessage:message];
    }
}

- (void)updateTitleForGroup:(NSNotification *)notification {
    NSString *groupId = notification.object;
    if ([groupId isEqualToString:self.targetId]) {
        [self refreshTitle];
    }
}

- (void)didGroupMemberUpdateNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    if ([dic[@"targetId"] isEqualToString:self.targetId]) {
        [self setRightNavigationItems];
    }
}

- (void)leftBarButtonItemPressed:(id)sender {
    if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_OUTGOING ||
        [self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_CONNECTED) {
        [self.chatSessionInputBarControl resetToDefaultStatus];
        [RCAlertView showAlertController:nil message:RTLLocalizedString(@"leave_location_share_when_leave_chat") actionTitles:nil cancelTitle:RTLLocalizedString(@"cancel") confirmTitle:RCLocalizedString(@"Confirm") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:nil confirmBlock:^{
            [self.realTimeLocation quitRealTimeLocation];
            [self popupChatViewController];
        } inViewController:self];
    } else {
        [self popupChatViewController];
    }
}

- (void)quicklySendImage:(UIButton *)button {
    CGRect targetFrame =
        CGRectMake(RCDScreenWidth - 108, self.chatSessionInputBarControl.frame.origin.y - 148 - 2, 106, 148);
    if ([RCDSemanticContext isRTL]) {
        targetFrame =
            CGRectMake(2, self.chatSessionInputBarControl.frame.origin.y - 148 - 2, 106, 148);
    }
    [[RCDQuicklySendManager sharedManager] showQuicklySendViewWithframe:targetFrame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    [self resetQucilySendView];
}

#pragma mark - Demo
- (void)handleChatSessionInputBarControlDemo {
    //    self.chatSessionInputBarControl.hidden = YES;
    //    CGRect intputTextRect = self.conversationMessageCollectionView.frame;
    //    intputTextRect.size.height = intputTextRect.size.height+50;
    //    [self.conversationMessageCollectionView setFrame:intputTextRect];
    //    [self scrollToBottomAnimated:YES];
    /***********如何自定义面板功能***********************
     //     自定义面板功能首先要继承RCConversationViewController，如现在所在的这个文件。
     //     然后在viewDidLoad函数的super函数之后去编辑按钮：
     //     插入到指定位置的方法如下：
     [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:imagePic
     title:title
     atIndex:0
     tag:101];
     删除指定位置的方法：
     [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:0];
     删除指定标签的方法：
     [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:101];
     删除所有：
     [self.chatSessionInputBarControl.pluginBoardView removeAllItems];
     更换现有扩展项的图标和标题:
     [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:0 image:newImage title:newTitle];
     或者根据tag来更换
     [self.chatSessionInputBarControl.pluginBoardView updateItemWithTag:101 image:newImage title:newTitle];
     以上所有的接口都在RCPluginBoardView.h可以查到。

     当编辑完扩展功能后，下一步就是要实现对扩展功能事件的处理，放开被注掉的函数
     pluginBoardView:clickedItemWithTag:
     在super之后加上自己的处理。

     */

    //默认输入类型为语音
    // self.defaultInputType = RCChatSessionInputBarInputExtention;
    if ([self.targetId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_VOIP_TAG];
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_VIDEO_VOIP_TAG];
    }
}

- (void)insertMessageDemo {
    /***********如何在会话页面插入提醒消息***********************

     RCInformationNotificationMessage *warningMsg =
     [RCInformationNotificationMessage
     notificationWithMessage:@"请不要轻易给陌生人汇钱！" extra:nil];
     BOOL saveToDB = NO;  //是否保存到数据库中
     RCMessage *savedMsg ;
     if (saveToDB) {
     savedMsg = [[RCIMClient sharedRCIMClient]
     insertOutgoingMessage:self.conversationType targetId:self.targetId
     sentStatus:SentStatus_SENT content:warningMsg];
     } else {
     savedMsg =[[RCMessage alloc] initWithType:self.conversationType
     targetId:self.targetId direction:MessageDirection_SEND messageId:-1
     content:warningMsg];//注意messageId要设置为－1
     }
     [self appendAndDisplayMessage:savedMsg];
     */
}

- (void)addEmoticonTabDemo {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugDisableSystemEmoji] boolValue];
    if (!enable) {
        return;
    }
    
//      //表情面板添加自定义表情包
      UIImage *icon = [RCKitUtility imageNamed:@"emoji_btn_normal"
                                      ofBundle:@"RongCloud.bundle"];
      RCDCustomerEmoticonTab *emoticonTab1 = [[RCDCustomerEmoticonTab alloc] initWith:self.chatSessionInputBarControl.emojiBoardView];
      emoticonTab1.identify = @"1";
      emoticonTab1.image = icon;
      emoticonTab1.pageCount = 2;
      [self.chatSessionInputBarControl.emojiBoardView addEmojiTab:emoticonTab1];
    
    RCDCustomerEmoticonTab *emoticonTab2 = [[RCDCustomerEmoticonTab alloc] initWith:self.chatSessionInputBarControl.emojiBoardView];
      emoticonTab2.identify = @"2";
      emoticonTab2.image = icon;
      emoticonTab2.pageCount = 4;
      [self.chatSessionInputBarControl.emojiBoardView addEmojiTab:emoticonTab2];
}

#pragma mark - helper
- (void)addOtherPluginBoard {
    if (self.conversationType != ConversationType_APPSERVICE &&
        self.conversationType != ConversationType_PUBLICSERVICE) {
        //加号区域增加发送文件功能，Kit中已经默认实现了该功能，但是为了SDK向后兼容性，目前SDK默认不开启该入口，可以参考以下代码在加号区域中增加发送文件功能。
        RCPluginBoardView *pluginBoardView = self.chatSessionInputBarControl.pluginBoardView;
        [pluginBoardView insertItem:RCResourceImage(@"plugin_item_file")
                   highlightedImage:RCResourceImage(@"plugin_item_file_highlighted")
                              title:RCLocalizedString(@"File")
                            atIndex:3
                                tag:PLUGIN_BOARD_ITEM_FILE_TAG];
    }
    if (self.conversationType == ConversationType_PRIVATE || self.conversationType == ConversationType_GROUP) {
        [self.chatSessionInputBarControl.pluginBoardView insertItem:[UIImage imageNamed:@"plugin_item_poke"]
                                                   highlightedImage:[UIImage imageNamed:@"plugin_item_poke_highlighted"]
                                                              title:RCDLocalizedString(@"Poke")
                                                                tag:PLUGIN_BOARD_ITEM_POKE_TAG];
    }
}

- (void)pushPersonDetailVC:(RCDUserInfo *)user {
    if (self.conversationType == ConversationType_GROUP) {
        UIViewController *vc = [RCDPersonDetailViewController configVC:user.userId groupId:self.targetId];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIViewController *vc = [RCDPersonDetailViewController configVC:user.userId groupId:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushFriendVC:(RCDUserInfo *)user {
    RCDAddFriendViewController *vc = [[RCDAddFriendViewController alloc] init];
    vc.targetUserId = user.userId;
    if (self.conversationType == ConversationType_GROUP) {
        vc.groupId = self.targetId;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)setLeftNavigationItem {
    int count = [RCDUtilities getTotalUnreadCount];
    NSString *backString = nil;
    if (self.conversationType != ConversationType_CHATROOM) {
        if (count > 0 && count < 100) {
            backString = [NSString stringWithFormat:@"(%d)", count];
        }else if (count >= 100 && count < 1000) {
            backString = @"99+";
        } else if (count >= 1000) {
            backString = [NSString stringWithFormat:@"(...)"];
        }
    }
    UIImage *img = RCResourceImage(@"navigator_btn_back");
    img = [RCDSemanticContext imageflippedForRTL:img];
    [self.navigationItem setLeftBarButtonItems:[RCKitUtility getLeftNavigationItems:img title:backString target:self action:@selector(leftBarButtonItemPressed:)]];
}

- (void)setRightNavigationItem:(UIImage *)image{
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:image target:self action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)clearHistoryMSG {
    [self.conversationDataRepository removeAllObjects];
    [self.conversationMessageCollectionView reloadData];
}

- (void)popupChatViewController {
    [self.realTimeLocation removeRealTimeLocationObserver:self];
    if (self.needPopToRootView == YES) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [super leftBarButtonItemPressed:nil];
    }
}

- (void)refreshUserInfoOrGroupInfo {
    if ([[RCIMClient sharedRCIMClient] getCurrentNetworkStatus] == RC_NotReachable ) {
        return;
    }
    //打开单聊强制从demo server 获取用户信息更新本地数据库
    if (self.conversationType == ConversationType_PRIVATE) {
        if (![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            __weak typeof(self) weakSelf = self;
            [RCDUserInfoManager
                getUserInfoFromServer:self.targetId
                             complete:^(RCUserInfo *userInfo) {
                                 [RCDUserInfoManager
                                     getFriendInfoFromServer:userInfo.userId
                                                    complete:^(RCDFriendInfo *friendInfo) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            weakSelf.navigationItem.title = [RCKitUtility getDisplayName:friendInfo];
                                                        });
                                                    }];
                             }];
        }
    }

    //打开群聊强制从demo server 获取群组信息更新本地数据库
    if (self.conversationType == ConversationType_GROUP) {
        __weak typeof(self) weakSelf = self;
        [RCDGroupManager getGroupInfoFromServer:self.targetId
                                       complete:^(RCDGroupInfo *_Nonnull groupInfo) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (groupInfo) {
                                                   weakSelf.groupInfo = groupInfo;
                                                   [weakSelf refreshTitle];
                                                   [RCDGroupManager
                                                       getGroupMembersFromServer:self.targetId
                                                                        complete:^(NSArray<NSString *> *memberIdList) {
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                [weakSelf setRightNavigationItems];
                                                                            });
                                                                        }];
                                               }
                                           });
                                       }];
    }
}

- (void)refreshTitle {
    if (self.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *groupInfo = [RCDGroupManager getGroupInfo:self.targetId];
        if (groupInfo.groupName) {
            if ([groupInfo.number intValue] > 0) {
                self.title = [NSString stringWithFormat:@"%@(%d)", groupInfo.groupName, [groupInfo.number intValue]];
            } else {
                self.title = [NSString stringWithFormat:@"%@", groupInfo.groupName];
            }
        }
    } else if(self.conversationType == ConversationType_PRIVATE){
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:self.targetId];
        if (userInfo) {
            self.title = [RCKitUtility getDisplayName:userInfo];
        }
    }
    else if(self.conversationType == ConversationType_CHATROOM){
     
        self.title = [NSString stringWithFormat:@"%@ -> 默认数据（%d）条", self.title, self.defaultHistoryMessageCountOfChatRoom];
    }
}

- (BOOL)stayAfterJoinChatRoomFailed {
    //加入聊天室失败之后，是否还停留在会话界面
    return [DEFAULTS boolForKey:RCDStayAfterJoinChatRoomFailedKey];
}

- (void)alertErrorAndLeft:(NSString *)errorInfo {
    if (![self stayAfterJoinChatRoomFailed]) {
        [super alertErrorAndLeft:errorInfo];
    }
}

- (void)setRightNavigationItems {
    if (self.conversationType == ConversationType_GROUP) {
        if (self.groupInfo.isDismiss ||
            ![[RCDGroupManager getGroupMembers:self.targetId]
                containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
            self.navigationItem.rightBarButtonItem = nil;
            return;
        }
        [self setRightNavigationItem:[UIImage imageNamed:@"Setting"]];
    } else if (self.conversationType == ConversationType_CHATROOM) {
        [self setRightNavigationItem:nil];
    } else {
        [self setRightNavigationItem:[UIImage imageNamed:@"Setting"]];
    }
}
- (void)addNotifications {
    if (self.conversationType == ConversationType_GROUP) {
        //群组改名之后，更新当前页面的Title
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTitleForGroup:)
                                                     name:RCDGroupInfoUpdateKey
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didGroupMemberUpdateNotification:)
                                                     name:RCDGroupMemberUpdateKey
                                                   object:nil];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateForSharedMessageInsertSuccess:)
                                                 name:@"RCDSharedMessageInsertSuccess"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEndForwardMessage:)
                                                 name:@"RCDForwardMessageEnd"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

    [self.conversationMessageCollectionView addObserver:self
                                             forKeyPath:@"frame"
                                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                context:nil];
}

- (void)addQuicklySendImage {
    [(UIButton *)self.chatSessionInputBarControl.additionalButton addTarget:self
                                                                     action:@selector(quicklySendImage:)
                                                           forControlEvents:UIControlEventTouchUpInside];
    [RCDQuicklySendManager sharedManager].delegate = self;
}

- (void)setupChatBackground {
    NSString *imageName = [DEFAULTS objectForKey:RCDChatBackgroundKey];
    UIImage *image = [UIImage imageNamed:imageName];
    if ([imageName isEqualToString:RCDChatBackgroundFromAlbum]) {
        NSData *imageData = [DEFAULTS objectForKey:RCDChatBackgroundImageDataKey];
        image = [UIImage imageWithData:imageData];
    }
    if (image) {
        self.conversationMessageCollectionView.backgroundColor = [UIColor clearColor];
        image = [RCKitUtility fixOrientation:image];
        self.view.layer.contents = (id)image.CGImage;
    }
}

// 创建防欺诈提示条
- (void)setupFraudPreventionTipsView {
    RCDChatTitleAlertView *alertView = [[RCDChatTitleAlertView alloc] initWithTitleAlertMessage:RCDLocalizedString(@"Fraud_Prevention_Tips")];
    [self.view addSubview:alertView];

    CGFloat topHeight = [self statusBarHeight] +
                                      CGRectGetMaxY(self.navigationController.navigationBar.bounds);

    alertView.frame = CGRectMake(0, topHeight, self.view.frame.size.width, 63);

    CGRect collectionFrame = self.conversationMessageCollectionView.frame;
    collectionFrame.origin.y = alertView.frame.size.height + alertView.frame.origin.y;
    self.conversationMessageCollectionView.frame = collectionFrame;
}

- (CGFloat)statusBarHeight {
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;

    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = appWindow.safeAreaInsets;
    }
    
    CGFloat statusBarHeight = (CGFloat)(safeAreaInsets.top != 0 ? safeAreaInsets.top : [UIApplication sharedApplication].statusBarFrame.size.height);
    return statusBarHeight;
}

- (void)resetQucilySendView {
    [[RCDQuicklySendManager sharedManager] hideQuicklySendView];
}

- (void)saveInputDestructStatus {
    KBottomBarStatus inputType = self.chatSessionInputBarControl.currentBottomBarStatus;
    if (self.chatSessionInputBarControl.destructMessageMode) {
        inputType = KBottomBarDestructStatus;
    }
    [[RCDIMService sharedService] saveInputStatus:self.conversationType targetId:self.targetId inputType:inputType];
}

#pragma mark - *************消息多选功能:转发、删除*************
/******************消息多选功能:转发、删除**********************/
- (void)addToolbarItems {
    //转发按钮
    UIButton *forwardBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [forwardBtn setImage:[UIImage imageNamed:@"forward_message"] forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(forwardMessage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];
    //删除按钮
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [deleteBtn setImage:RCResourceImage(@"delete_message")
               forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteMessages) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    //按钮间 space
    UIBarButtonItem *spaceItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.messageSelectionToolbar
        setItems:@[ spaceItem, forwardBarButtonItem, spaceItem, deleteBarButtonItem, spaceItem ]
        animated:YES];
}

- (void)forwardMessage {
    [RCDForwardManager sharedInstance].selectedMessages = self.selectedMessages;
    if ([[RCDForwardManager sharedInstance] allSelectedMessagesAreLegal]) {
        [RCDForwardManager sharedInstance].isForward = YES;
        RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
        navi.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:navi animated:YES completion:nil];
    } else {
        [RCAlertView showAlertController:nil message:RCDLocalizedString(@"Forwarding_is_not_supported") cancelTitle:RCDLocalizedString(@"confirm")];
    }
}

- (void)onEndForwardMessage:(NSNotification *)notification {
    //置为 NO,将消息 cell 重置为初始状态
    self.allowsMessageCellSelection = NO;
    [self.view showHUDMessage:RCDLocalizedString(@"send_success")];
    [self scrollToBottomAnimated:YES];
}

- (void)deleteMessages {
    NSArray *tempArray = [self.selectedMessages mutableCopy];
    for (int i = 0; i < tempArray.count; i++) {
        [self deleteMessage:tempArray[i]];
    }
    //置为 NO,将消息 cell 重置为初始状态
    self.allowsMessageCellSelection = NO;
}

- (void)forwardMessage:(NSInteger)index completed:(void (^)(NSArray<RCConversation *> *))completedBlock {
    [RCDForwardManager sharedInstance].selectedMessages = self.selectedMessages;
    [RCDForwardManager sharedInstance].isForward = YES;
    [RCDForwardManager sharedInstance].selectConversationCompleted =
        ^(NSArray<RCConversation *> *_Nonnull conversationList) {
            completedBlock(conversationList);
        };
    RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

- (void)userDidTakeScreenshot:(NSNotification *)notification {
    if (self.isShow && [self.navigationController.topViewController isKindOfClass:[self class]]) {
        [RCDChatManager getScreenCaptureNotification:self.conversationType
            targetId:self.targetId
            complete:^(BOOL screenCaptureNotification) {
                if (screenCaptureNotification) {
                    [RCDChatManager sendScreenCaptureNotification:self.conversationType
                                                         targetId:self.targetId
                                                         complete:^(BOOL success){

                                                         }];
                }
            }
            error:^{

            }];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setupChatBackground];
}

#pragma mark - *************实时位置共享*************
- (void)initRealTimeLocationStatusView {
    self.realTimeLocationStatusView =
        [[RealTimeLocationStatusView alloc] initWithFrame:CGRectMake(0, 62, self.view.frame.size.width, 0)];
    self.realTimeLocationStatusView.delegate = self;
    [self.view addSubview:self.realTimeLocationStatusView];
}

//注册实时位置共享相关消息
- (void)registerRealTimeLocationCell {
    [self initRealTimeLocationStatusView];
    [self registerClass:[RealTimeLocationStartCell class] forMessageClass:[RCRealTimeLocationStartMessage class]];
    [self registerClass:[RealTimeLocationEndCell class] forMessageClass:[RCRealTimeLocationEndMessage class]];
}

//获取实时位置共享代理
- (void)getRealTimeLocationProxy {
    __weak typeof(self) weakSelf = self;
    [[RCRealTimeLocationManager sharedManager] getRealTimeLocationProxy:self.conversationType
        targetId:self.targetId
        success:^(id<RCRealTimeLocationProxy> realTimeLocation) {
            weakSelf.realTimeLocation = realTimeLocation;
            [weakSelf.realTimeLocation addRealTimeLocationObserver:weakSelf];
            [weakSelf updateRealTimeLocationStatus];
        }
        error:^(RCRealTimeLocationErrorCode status) {
            NSLog(@"get location share failure with code %d", (int)status);
        }];
}

//弹出实时位置共享页面
- (void)showRealTimeLocationViewController {
    RealTimeLocationViewController *lsvc = [[RealTimeLocationViewController alloc] init];
    lsvc.realTimeLocationProxy = self.realTimeLocation;
    if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_INCOMING) {
        [self.realTimeLocation joinRealTimeLocation];
    } else if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_IDLE) {
        [self.realTimeLocation startRealTimeLocation];
    }
    lsvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:lsvc
                                            animated:YES
                                          completion:^{

                                          }];
}

//更新实时位置共享状态
- (void)updateRealTimeLocationStatus {
    if (self.realTimeLocation) {
        [self.realTimeLocationStatusView updateRealTimeLocationStatus];
        __weak typeof(self) weakSelf = self;
        NSArray *participants = nil;
        switch ([self.realTimeLocation getStatus]) {
        case RC_REAL_TIME_LOCATION_STATUS_OUTGOING:
            [self.realTimeLocationStatusView updateText:RTLLocalizedString(@"you_location_sharing")];
            break;
        case RC_REAL_TIME_LOCATION_STATUS_CONNECTED:
        case RC_REAL_TIME_LOCATION_STATUS_INCOMING:
            participants = [self.realTimeLocation getParticipants];
            if (participants.count == 1) {
                NSString *userId = participants[0];
                [[RCIM sharedRCIM].userInfoDataSource getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
                    NSString *displayName = [RCKitUtility getDisplayName:userInfo];
                    if (displayName.length) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.realTimeLocationStatusView updateText:[NSString stringWithFormat:RTLLocalizedString(@"someone_location_sharing"), displayName]];
                        });
                    }
                }];
            } else {
                if (participants.count < 1)
                    [self.realTimeLocationStatusView removeFromSuperview];
                else
                    [self.realTimeLocationStatusView updateText:[NSString stringWithFormat:RTLLocalizedString(@"share_location_people_count"), (int)participants.count]];
            }
            break;
        default:
            break;
        }
    }
}

#pragma mark 实时位置共享监听代理方法
- (void)onRealTimeLocationStatusChange:(RCRealTimeLocationStatus)status {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRealTimeLocationStatus];
    });
}

- (void)onReceiveLocation:(CLLocation *)location type:(RCRealTimeLocationType)type fromUserId:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRealTimeLocationStatus];
    });
}

- (void)onParticipantsJoin:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self notifyParticipantChange:RTLLocalizedString(@"you_join_location_share")];
    } else {
        [[RCIM sharedRCIM].userInfoDataSource getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
            NSString *displayName = [RCKitUtility getDisplayName:userInfo];
            if (displayName.length) {
                [weakSelf notifyParticipantChange:[NSString stringWithFormat:RTLLocalizedString(@"someone_join_share_location"), displayName]];
            } else {
                [weakSelf notifyParticipantChange:[NSString stringWithFormat:RTLLocalizedString(@"user_join_share_location"), userId]];
            }
        }];
    }
}

- (void)onParticipantsQuit:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self notifyParticipantChange:RTLLocalizedString(@"you_quit_location_share")];
    } else {
        [[RCIM sharedRCIM].userInfoDataSource getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
            NSString *displayName = [RCKitUtility getDisplayName:userInfo];
            if (displayName.length) {
                [weakSelf notifyParticipantChange:[NSString stringWithFormat:RTLLocalizedString(@"someone_quit_location_share"), displayName]];
            } else {
                [weakSelf notifyParticipantChange:[NSString stringWithFormat:RTLLocalizedString(@"user_quit_location_share"), userId]];
            }
        }];
    }
}

- (void)onRealTimeLocationStartFailed:(long)messageId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
            if (model.messageId == messageId) {
                model.sentStatus = SentStatus_FAILED;
            }
        }
        NSArray *visibleItem = [self.conversationMessageCollectionView indexPathsForVisibleItems];
        for (int i = 0; i < visibleItem.count; i++) {
            NSIndexPath *indexPath = visibleItem[i];
            RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
            if (model.messageId == messageId) {
                [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
            }
        }
    });
}

- (void)notifyParticipantChange:(NSString *)text {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.realTimeLocationStatusView updateText:text];
        [weakSelf performSelector:@selector(updateRealTimeLocationStatus) withObject:nil afterDelay:0.5];
    });
}

- (void)onFailUpdateLocation:(NSString *)description {
}

#pragma mark - 实时位置共享状态 view 代理方法
- (void)onJoin {
    [self showRealTimeLocationViewController];
}
- (RCRealTimeLocationStatus)getStatus {
    return [self.realTimeLocation getStatus];
}

- (void)onShowRealTimeLocationView {
    [self showRealTimeLocationViewController];
}

- (void)setRealTimeLocation:(id<RCRealTimeLocationProxy>)realTimeLocation {
    objc_setAssociatedObject(self, kRealTimeLocationKey, realTimeLocation, OBJC_ASSOCIATION_ASSIGN);
}

- (id<RCRealTimeLocationProxy>)realTimeLocation {
    return objc_getAssociatedObject(self, kRealTimeLocationKey);
}

- (void)setRealTimeLocationStatusView:(RealTimeLocationStatusView *)realTimeLocationStatusView {
    objc_setAssociatedObject(self, kRealTimeLocationStatusViewKey, realTimeLocationStatusView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RealTimeLocationStatusView *)realTimeLocationStatusView {
    return objc_getAssociatedObject(self, kRealTimeLocationStatusViewKey);
}

#pragma mark - 通知处理
- (void)appWillTerminate {
    // 杀进程时，保存一下输入框状态
    [self saveInputDestructStatus];
}

#pragma mark - 加载远端聊天室消息开始
//#pragma mark *************Load More Chatroom History Message From Server*************
////需要开通聊天室消息云端存储功能，调用getRemoteChatroomHistoryMessages接口才可以从服务器获取到聊天室消息的数据
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    //当会话类型是聊天室时，下拉加载消息会调用getRemoteChatroomHistoryMessages接口从服务器拉取聊天室消息
//    if (self.conversationType == ConversationType_CHATROOM) {
//        if (scrollView.contentOffset.y < -15.0f && !self.loading) {
//            self.loading = YES;
//            [self performSelector:@selector(loadMoreChatroomHistoryMessageFromServer) withObject:nil afterDelay:0.4f];
//        }
//    } else {
//        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//    }
//}
//
////从服务器拉取聊天室消息的方法
//- (void)loadMoreChatroomHistoryMessageFromServer {
//    long long recordTime = 0;
//    RCMessageModel *model;
//    if (self.conversationDataRepository.count > 0) {
//        model = [self.conversationDataRepository objectAtIndex:0];
//        recordTime = model.sentTime;
//    }
//    __weak typeof(self) weakSelf = self;
//    [[RCIMClient sharedRCIMClient] getRemoteChatroomHistoryMessages:self.targetId
//        recordTime:recordTime
//        count:20
//        order:RC_Timestamp_Desc
//        success:^(NSArray *messages, long long syncTime) {
//            self.loading = NO;
//            [weakSelf handleMessages:messages];
//        }
//        error:^(RCErrorCode status) {
//            NSLog(@"load remote history message failed(%zd)", status);
//        }];
//}
//
////对于从服务器拉取到的聊天室消息的处理
//- (void)handleMessages:(NSArray *)messages {
//    NSMutableArray *tempMessags = [[NSMutableArray alloc] initWithCapacity:0];
//    for (RCMessage *message in messages) {
//        RCMessageModel *model = [RCMessageModel modelWithMessage:message];
//        [tempMessags addObject:model];
//    }
//    //对去拉取到的消息进行逆序排列
//    NSArray *reversedArray = [[tempMessags reverseObjectEnumerator] allObjects];
//    tempMessags = [reversedArray mutableCopy];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //将逆序排列的消息加入到数据源
//        [tempMessags addObjectsFromArray:self.conversationDataRepository];
//        self.conversationDataRepository = tempMessags;
//        //显示消息发送时间的方法
//        [self figureOutAllConversationDataRepository];
//        [self.conversationMessageCollectionView reloadData];
//        if (self.conversationDataRepository != nil && self.conversationDataRepository.count > 0 &&
//            [self.conversationMessageCollectionView numberOfItemsInSection:0] >= messages.count - 1) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messages.count - 1 inSection:0];
//            [self.conversationMessageCollectionView scrollToItemAtIndexPath:indexPath
//                                                           atScrollPosition:UICollectionViewScrollPositionTop
//                                                                   animated:NO];
//        }
//    });
//}
//
////显示消息发送时间的方法
//- (void)figureOutAllConversationDataRepository {
//    for (int i = 0; i < self.conversationDataRepository.count; i++) {
//        RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
//        if (0 == i) {
//            model.isDisplayMessageTime = YES;
//        } else if (i > 0) {
//            RCMessageModel *pre_model = [self.conversationDataRepository objectAtIndex:i - 1];
//
//            long long previous_time = pre_model.sentTime;
//
//            long long current_time = model.sentTime;
//
//            long long interval =
//                current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
//            if (interval / 1000 <= 3 * 60) {
//                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
//                    CGSize size = model.cellSize;
//                    size.height = model.cellSize.height - 45;
//                    model.cellSize = size;
//                }
//                model.isDisplayMessageTime = NO;
//            } else if (![[[model.content class] getObjectName] isEqualToString:@"RC:OldMsgNtf"]) {
//                if (!model.isDisplayMessageTime && model.cellSize.height > 0) {
//                    CGSize size = model.cellSize;
//                    size.height = model.cellSize.height + 45;
//                    model.cellSize = size;
//                }
//                model.isDisplayMessageTime = YES;
//            }
//        }
//        if ([[[model.content class] getObjectName] isEqualToString:@"RC:OldMsgNtf"]) {
//            model.isDisplayMessageTime = NO;
//        }
//    }
//}
#pragma mark 加载远端聊天室消息结束

#pragma mark - Test

- (NSString *)longString {
    NSString *text = @"1.微型小说（要符合“小说要求”，一千字以下） [1] \
    比短篇更短的小说完全符合瞬息万变的现代社会中忙碌的人们的阅读习惯，几乎每天都可以看到人们为这类的小说赋予一个新名词和新定义。例如极短篇、精短小说、超短篇小说、微信息小说、一分钟小说、一袋烟小说、袖珍小说、焦点小说、瞳孔小说、拇指小说、迷你小说等，族繁不及备载，连专门的文学研究者也很难如数家珍分叙其定义，一般人更容易混淆，故总论之。一般认为小小说的篇幅应在一千字以下。因为题材常是生活经验的片段，因此可以是有头无尾、有尾无头、甚至无头无尾。高潮放在结尾，高潮一出马上完结，营造余音绕梁的意境。由于比短篇更短，字句也需要更加精练，题材能见微知著者为佳。一个意外的结局虽然能吸引眼球，但文章短还是要有伏笔呼应，甚至比起给予读者意外、应该更重视能否带给读者感动。\
    2.短篇小说［一千（含）至三万字（不含）］ www.baidu.com \
    一般认为，篇幅在一千（含）到两万多字的小说会被划归短篇小说。在它的特色中有所谓三一律：一人一地一时，也就是减少角色、缩小舞台、短化故事中流动的时间。另外，虽然它们时常惜墨如金，但一般认为短篇小说仍应符合小说的原始定义、也就是对细节有足够的刻划，绝非长篇故事的节略或纲要。所有小说基础，其发展初期并无长短之分，随时代而区分。今短篇小说多要求文笔洗练，且受西洋三一定律一时一地一物观念影响，使其更生动详实但也限制其发展。\
    3.中篇小说（三万至六万字）13488619755\
    一般认为，篇幅在三万字至六万字之间的小说。也有少数十几万字也被算作中篇而不归于长篇，这取决于文章内容的丰富度。其容量大小、篇幅长短、人物多寡、情节繁简等均介于长篇小说和短篇小说之间，通常只是截取主人公一个时期或某一段生活的典型事件塑造形象。反映社会生活的某个方面，故事情节完整。线索比较单一，矛盾斗争不如长篇小说复杂，人物较少。所以，相比于长篇，中篇小说比较容易把握，也更容易成功。因为对于初涉创作领域的人而言，写作长篇易陷入多数的情节造成凌乱难收的困境，而写作短篇不是转折太少而单调、就是转折太多却显得拥挤。这时考虑将原本的构想修改中篇是一个广受推荐的建议。\
    4.长篇小说（六万字或十万字以上）\
    一般认为，字数在六万或十万以上的为长篇小说，还可细分为小长篇（一般六万到十万字），中长篇（一般十几万到三五十万字），超长篇（一般超过百万字）。如果作者打算表现人生中常见的错综复杂关系，则必须使用这么大的篇幅。通常就算是笔调轻松的长篇小说，也会有一个内里的严肃主题，否则很容易陷入无组织或是零乱。初涉者在写作长篇时最需注意全局对主题的呼应、结构的严密性，以及避免重复矛盾或缺漏。\
    注：篇幅长短并非明文规定，但按照情节内容丰富度可能会把部分字数多的划入字数少的类别，例如某些十几万二三十万字的小说会因为内容太过不紧凑而被归入中篇小说，而某些仅有六万多字让人觉得篇幅过短的小说会因为内容情节十分紧凑而归为小长篇。\
    创作年代\
    1.古典小说\
    古典小说萌芽于先秦，发展于两汉，雏形于魏晋南北朝，形成于唐代，繁荣于宋元，鼎盛于明清。大致可分以下几个时期：\
    （1）先秦两汉时期：当时社会出现的神话传说、寓言故事、史传文学成为古典小说叙事的源头。神话传说已经具备人物和情节两个基本因素，散见于诸子百家书中的寓言典故提供了借鉴经验，历史著作有比较完整的结构、人物形象和历史背景。\
    （2）魏晋南北朝时期：出现了志怪、志人小说。严格意义上说这仍然算不上是小说，只能算是小说的雏形。《世说新语》也是这个时期的优秀作品，里面收集了许多短小精悍的小故事。\
    （3）唐朝时期：古代小说的发展趋于成熟，形成了独立的文学形式—传奇体小说，由此我国的小说脱离历史领域而成为文学创作。唐代三大爱情传奇是此时期的标志性作品。\
    （4）宋元时期：商品经济的发展和市井文化的兴起，给小说创作带来深厚的土壤。话本经过文人加工形成许多话本小说和演义小说。\
    （5）明清时期：小说开始走上了文人独立创作之路，这一时期，小说作家主体意识增强。《红楼梦》的出现，把中国古代小说发展推向了高峰，达到前所未有的成就。在明清这一段时间内涌现了无数的经典之作流传于世。如明代四大奇书（《西游记》《水浒传》《三国演义》《金瓶梅》）三言二拍（《醒世恒言》《警世通言》《喻世明言》《初刻拍案惊奇》《二刻拍案惊奇》）清代的《红楼梦》《儒林外史》《老残游记》《聊斋志异》等。明董其昌《袁伯应（袁可立子）诗集序》：“二十年来，破觚为圆，浸淫广肆，子史空玄，旁逮稗官小说，无一不为帖括用者”。\
    2.现代小说\
    现当代小说的兴起的标志性事件为新文化运动，新文化运动乃是五四运动的先导（时间从1915年-1919年），大致可分为四个时期：\
    （1）第一时期为民国时期，即1949年以前，是小说的多元文艺复兴阶段。\
    民国时期，尤其是五四以来，中国遭受列强侵略，社会各种思潮流行，舶来文化冲击传统文化，中国小说的发展出现多元化，各类小说题材涌现，其中现代言情小说的发端鸳鸯蝴蝶派就出在此时。小说的代表性人物有“鲁郭茅巴老曹”六大家。晚清民国报纸兴起为小说创作提供了一个上佳的舞台，报纸通过了连载小说招揽人气，小说家通过报纸赚取稿费。近现代几乎所有著名的小说家最初都是从报纸上连载小说开始，从鸳鸯蝴蝶派的张恨水到当代金庸。\
    （2）第二时期为建国后到文革结束，即1976年以前，是小说的阶级斗争阶段。\
    这一时期的大陆小说的带有明显的政治倾向，同时，这一时期的大陆文艺青年经历了重大的人生转变，命运的沉浮、多视角的阅历以及对价值的思考，为下一个时期的辉煌埋下了伏笔（中国第一位诺贝尔文学奖得主莫言的人生转变就在这一时期）。而在港台，这一时期的言情小说和武侠小说发展到了巅峰，分别产生了琼瑶时代和金庸时代。\
    （3）第三时期为改革开放后二十多年的时期，即2003年以前，是小说的反思和蜕变阶段。\
    这一时期的大陆小说展现了强劲的生命力，文革结束，对外开放，知识分子思想解放，对过去的反思，对未来的向往，传统和新时代的撞击，使得小说界出现欣欣向荣的勃勃生机。以莫言、贾平凹、陈忠实等为代表文革后作家，在此期间创作了许多经典作品，莫言更是凭借在此期间创作的文学作品和影响力，在2012年获得中国第一个诺贝尔文学奖。\
    （4）第四时期为二十一世纪初，是小说的“表性”网络文学阶段。\
    随着网络普及，网络文学的出现颠覆了传统的书写和传播模式，使小说的发展更加多元，80后90后的生力军开始步入文坛并展现了惊人的创作能力，标志着网络小说已经成为主流文学之外的又一创作主体。\
    内容题材\
    1.神话小说\
    借助神话的表现形式或以神话为题材内容的小说，它起源于远古时代原始先民的口头创作，当时出现大量的“用想象或借助想象力以征服自然、支配自然，把自然力加以形象化”的远古神话，实际上这就是人类创的神话小说。\
    2.武侠小说\
    也可称为武打小说，可看做男性言情和励志小说。\
    3.仙侠小说\
    仙侠的雏形与诞生，可以说起于武侠，却更盛武侠。在仙侠的初步探索期，比较遗憾未能融合仙与侠，到《灵仙》的创作开始融合形成这条道路。 [5]\
    4.侦探小说\
    侦探推理小说是指在故事的描述过程中带有足够的线索让读者可以推理出结局，也可以不加推理由小说中的“侦探”来推导出结局的小说。发展早期是受西方影响，而出现《霍桑探案》，当代摆脱西方影响的作品是《游戏侦探集》的出现，而刑侦严格上不算入，因为刑侦无法批判现实，只是为了当权者服务。\
    5.探险小说\
    它是以各种不寻常的冒险事件为描写的中心线索，主人公往往有不平凡的经历、遭遇和挫折，情节紧张、冲突尖锐、场面惊险、内容离奇。西方比较盛行，国内《游险记》与《寻龙诀》的出现，也带来了一点热度。\
    6.历史小说\
    历史小说通常与军事小说不分家，严格说历史小说主要是以史实记录为蓝本，重新记述刻画历史人物和事件。网络上出现的历史小说大多是使用中国古代历史为背景的穿越类小说。\
    7.言情小说\
    包括很多，如后宫文，穿越文，都市文，青春校园文等，以描述恋爱感情为主题。例如《唐伯虎不点秋香》《史上第一搞笑初恋》等。\
    8.科幻小说\
    是根据现有的科学理论进行幻想的小说，并非凭空捏造。\
    9.恐怖小说\
    以情节或者语言以达到让读者恐慌的目的。\
    10.玄幻小说\
    玄幻小说和科幻小说有很大区别，很多都是天马行空的想象，大多更具东方特征。";
    return text;
}

- (NSString *)complexText {
    NSString *text = @"A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n vA\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n A\n v";
    return text;
}

@end
