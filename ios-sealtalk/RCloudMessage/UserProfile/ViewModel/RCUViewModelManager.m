//
//  RCUViewModelManager.m
//  SealTalk
//
//  Created by zgh on 2024/9/5.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUViewModelManager.h"
#import <RongIMKit/RongIMKit.h>
#import <RongCallKit/RongCallKit.h>
#import "RCDSearchHistoryMessageController.h"
#import "RCUChatViewController.h"
#import "RCUGroupNotificationMessage.h"

@interface RCDGroupNotificationMessage ()
@property (nonatomic, copy) NSString *targetGroupName;
@property (nonatomic, strong) NSArray *targetUserNames;
@property (nonatomic, copy) NSString *operationName;
@end

@interface RCUViewModelManager ()<RCProfileFooterViewModelDelegate, RCProfileViewModelDelegate, RCGroupCreateViewModelDelegate, RCGroupEventDelegate, RCGroupManagerListViewModelDelegate, RCGroupTransferViewModelDelegate, RCGroupMembersCollectionViewModelDelegate, RCGroupNoticeViewModelDelegate>

@end

@implementation RCUViewModelManager
+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [[RCCoreClient sharedCoreClient] addGroupEventDelegate:instance];
    });
    return instance;
}

+ (void)registerViewModel {
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCUserProfileViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCProfileFooterViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCGroupProfileViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCGroupCreateViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCGroupManagerListViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCGroupTransferViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCGroupMembersCollectionViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCGroupNoticeViewModel.class];
}

#pragma mark -- RCGroupCreateViewModelDelegate

- (NSString *)generateGroupId {
    return [[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]  stringByAppendingString:[RCCoreClient sharedCoreClient].currentUserInfo.userId];
}

- (BOOL)groupCreateDidSuccess:(RCGroupInfo *)group processCode:(RCErrorCode)processCode inViewController:(UIViewController *)inViewController {
    RCUGroupNotificationMessage *message = [RCUGroupNotificationMessage new];
    message.operatorUserId = [RCIM sharedRCIM].currentUserInfo.userId;
    message.operation = RCDGroupCreate;
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:group.groupId content:message pushContent:nil pushData:nil success:nil error:nil];
    RCUChatViewController *conversationVC = [[RCUChatViewController alloc] initWithConversationType:ConversationType_GROUP targetId:group.groupId];
    conversationVC.needPopToRootView = YES;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [inViewController.navigationController pushViewController:conversationVC animated:YES];
    if (processCode == RC_GROUP_NEED_INVITEE_ACCEPT) {
        [RCAlertView showAlertController:nil message:RCLocalizedString(@"CreateSuccessAndNeedInviteeAcceptTip") hiddenAfterDelay:2];
    }
    return YES;
}

#pragma mark -- RCProfileFooterViewModelDelegate

- (NSArray<RCButtonItem *> *)profileFooterViewModel:(RCProfileFooterViewModel *)viewModel willLoadButtonItemsViewModels:(NSArray<RCButtonItem *> *)models {
    if (viewModel.type == RCProfileFooterViewTypeChat) {
        NSMutableArray *list = models.mutableCopy;
        if (viewModel.type == RCProfileFooterViewTypeChat) {
            [models.firstObject setClickBlock:^{
                RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
                chatVC.conversationType = ConversationType_PRIVATE;
                chatVC.targetId = viewModel.targetId;
                [viewModel.responder.navigationController pushViewController:chatVC animated:YES];
            }];
            RCButtonItem *voiceItem = [RCButtonItem itemWithTitle:RCDLocalizedString(@"voice_call")
                                                       titleColor:RCDynamicColor(@"primary_color", @"0x111f2c", @"0xD3E1EE")
                                                  backgroundColor:RCDynamicColor(@"common_background_color", @"0xffffff", @"0x3C3C3C")];
            voiceItem.borderColor =
            RCDynamicColor(@"clear_color", @"0xCFCFCF", @"0x3C3C3C");
            if (![RCKitUtility isTraditionInnerThemes]) {
                voiceItem.buttonIcon = [UIImage imageNamed:@"user_info_voice_call"];
            }
            [voiceItem setClickBlock:^{
                [[RCCall sharedRCCall] startSingleCall:viewModel.targetId mediaType:RCCallMediaAudio];
            }];
            
            RCButtonItem *videoItem = [RCButtonItem itemWithTitle:RCDLocalizedString(@"video_call") titleColor:RCDynamicColor(@"primary_color", @"0x111f2c", @"0xD3E1EE") backgroundColor:RCDynamicColor(@"common_background_color", @"0xffffff", @"0x3C3C3C")];
            videoItem.borderColor = RCDynamicColor(@"clear_color", @"0xCFCFCF", @"0x3C3C3C");
            
            if (![RCKitUtility isTraditionInnerThemes]) {
                videoItem.buttonIcon = [UIImage imageNamed:@"user_info_video_call"];
            }
            [videoItem setClickBlock:^{
                [[RCCall sharedRCCall] startSingleCall:viewModel.targetId mediaType:RCCallMediaVideo];
            }];
            if (list.count > 0) {
                [list insertObject:voiceItem atIndex:1];
                [list insertObject:videoItem atIndex:2];
            }
        }
        return list;
    }
    return models;
}

#pragma mark -- RCProfileViewModelDelegate
//
- (BOOL)profileViewModel:(RCProfileViewModel *)viewModel viewController:(UIViewController *)viewController tableView:(UITableView *)tableView didSelectRow:(NSIndexPath *)indexPath cellViewModel:(RCProfileCellViewModel *)cellViewModel {
    if ([viewModel isKindOfClass:RCGroupProfileViewModel.class] &&
        [cellViewModel isKindOfClass:RCProfileCommonCellViewModel.class]) {
        RCProfileCommonCellViewModel *tempVM = (RCProfileCommonCellViewModel *)cellViewModel;
        if ([tempVM.title isEqualToString:RCDLocalizedString(@"search_chat_history")]) {
            RCDSearchHistoryMessageController *searchViewController = [[RCDSearchHistoryMessageController alloc] init];
            searchViewController.conversationType = ConversationType_GROUP;
            searchViewController.targetId = ((RCGroupProfileViewModel *)viewModel).groupId;
            [viewController.navigationController pushViewController:searchViewController animated:YES];
            return YES;
        }
    }
    return NO;
}

- (RCProfileFooterViewModel *)profileViewModel:(RCProfileViewModel *)viewModel willLoadProfileFooterViewModel:(RCProfileFooterViewModel *)footerViewModel {
    footerViewModel.delegate = self;
    return footerViewModel;
}

#pragma mark -- RCGroupEventDelegate

#pragma mark -- RCGroupManagersViewModelDelegate

- (BOOL)groupManagersDidAdd:(NSString *)groupId addUserIds:(NSArray<NSString *> *)addUserIds viewController:(UIViewController *)viewController {
    RCUGroupNotificationMessage *message = [RCUGroupNotificationMessage new];
    message.operatorUserId = [RCIM sharedRCIM].currentUserInfo.userId;
    message.targetUserIds = addUserIds;
    message.operation = RCDGroupMemberManagerSet;
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:groupId content:message pushContent:nil pushData:nil success:nil error:nil];
    return NO;
}

- (BOOL)groupManagersDidRemove:(NSString *)groupId removeUserIds:(NSArray<NSString *> *)removeUserIds viewController:(UIViewController *)viewController {
    RCUGroupNotificationMessage *message = [RCUGroupNotificationMessage new];
    message.operatorUserId = [RCIM sharedRCIM].currentUserInfo.userId;
    message.targetUserIds = removeUserIds;
    message.operation = RCDGroupMemberManagerRemoveDisplay;
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:groupId content:message pushContent:nil pushData:nil success:nil error:nil];
    return NO;
}

#pragma mark -- RCGroupTransferOwnerViewModelDelegate
- (BOOL)groupOwnerDidTransfer:(NSString *)groupId newOwnerId:(NSString *)newOwnerId viewController:(UIViewController *)viewController {
    RCUGroupNotificationMessage *message = [RCUGroupNotificationMessage new];
    message.operatorUserId = [RCIM sharedRCIM].currentUserInfo.userId;
    message.targetUserIds = @[newOwnerId];
    message.operation = RCDGroupOwnerTransfer;
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:groupId content:message pushContent:nil pushData:nil success:nil error:nil];
    return NO;
}

#pragma mark -- RCGroupMembersCollectionViewModelDelegate
- (BOOL)groupMembersCollectionViewModel:(RCGroupMembersCollectionViewModel *)viewModel didInviteUsers:(NSArray<NSString *> *)userIds processCode:(RCErrorCode)processCode viewController:(UIViewController *)viewController {
    if (processCode != RC_SUCCESS) {
        return NO;
    }
    RCUGroupNotificationMessage *message = [RCUGroupNotificationMessage new];
    message.operatorUserId = [RCIM sharedRCIM].currentUserInfo.userId;
    message.targetUserIds = userIds;
    message.operation = RCDGroupMemberAdd;
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:viewModel.groupId content:message pushContent:nil pushData:nil success:nil error:nil];
    return NO;
}


#pragma mark -- RCGroupNoticeViewModelDelegate
- (BOOL)groupNoticeDidUpdate:(RCGroupInfo *)updatedGroup viewModel:(RCGroupNoticeViewModel *)viewModel inViewController:(UIViewController *)inViewController {
    NSString *noticeMsgContent = [NSString stringWithFormat:@"@%@ %@",RCDLocalizedString(@"mention_all"), updatedGroup.notice];
    RCTextMessage *textContent = [RCTextMessage messageWithContent:noticeMsgContent];
    RCMentionedInfo *mentionInfo = [RCMentionedInfo  new];
    mentionInfo.type = RC_Mentioned_All;
    textContent.mentionedInfo = mentionInfo;
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:updatedGroup.groupId content:textContent pushContent:nil pushData:nil success:^(long messageId) {
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        
    }];
    return NO;
}
@end
