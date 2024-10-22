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
@interface RCUViewModelManager ()<RCProfileFooterViewModelDelegate, RCProfileViewModelDelegate, RCGroupCreateViewModelDelegate>

@end

@implementation RCUViewModelManager
+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)registerViewModel {
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCUserProfileViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCProfileFooterViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCGroupProfileViewModel.class];
    [RCViewModelAdapterCenter registerDelegate:[self sharedInstance] forViewModelClass:RCGroupCreateViewModel.class];
}

#pragma mark -- RCGroupCreateViewModelDelegate

- (NSString *)generateGroupId {
    return [[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]  stringByAppendingString:[RCCoreClient sharedCoreClient].currentUserInfo.userId];
}

- (BOOL)groupCreateDidSuccess:(RCGroupInfo *)group processCode:(RCErrorCode)processCode inViewController:(UIViewController *)inViewController {
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
            RCButtonItem *voiceItem = [RCButtonItem itemWithTitle:RCDLocalizedString(@"voice_call") titleColor:RCDYCOLOR(0x111f2c, 0xD3E1EE) backgroundColor:RCDYCOLOR(0xffffff, 0x3C3C3C)];
            voiceItem.borderColor = RCDYCOLOR(0xcfcfcf, 0x3C3C3C);
            [voiceItem setClickBlock:^{
                [[RCCall sharedRCCall] startSingleCall:viewModel.targetId mediaType:RCCallMediaAudio];
            }];
            
            RCButtonItem *videoItem = [RCButtonItem itemWithTitle:RCDLocalizedString(@"video_call") titleColor:RCDYCOLOR(0x111f2c, 0xD3E1EE) backgroundColor:RCDYCOLOR(0xffffff, 0x3C3C3C)];
            videoItem.borderColor = RCDYCOLOR(0xcfcfcf, 0x3C3C3C);
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

- (NSArray<NSArray<RCProfileCellViewModel *> *> *)profileViewModel:(RCProfileViewModel *)viewModel willLoadProfileCellViewModel:(NSArray<NSArray<RCProfileCellViewModel *> *> *)profileList{
    if ([viewModel isKindOfClass:RCGroupProfileViewModel.class]) {
        NSMutableArray *list = profileList.mutableCopy;
        [list addObject:@[[self disturbVM:(RCGroupProfileViewModel *)viewModel],[self topVM:(RCGroupProfileViewModel *)viewModel]]];
        return list;
    }
    return profileList;
}
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

#pragma mark -- private

- (RCProfileSwitchCellViewModel *)topVM:(RCGroupProfileViewModel *)viewModel {
    RCProfileSwitchCellViewModel *topVM = [RCProfileSwitchCellViewModel new];
    topVM.title = RCDLocalizedString(@"stick_on_top");
    RCConversationIdentifier * con = [[RCConversationIdentifier alloc] initWithConversationIdentifier:ConversationType_GROUP targetId:viewModel.groupId];
    [[RCCoreClient sharedCoreClient] getConversationTopStatus:con completion:^(BOOL ret) {
        dispatch_async(dispatch_get_main_queue(), ^{
            topVM.switchOn = ret;
        });
    }];
    topVM.switchValueChanged = ^(BOOL on) {
        [[RCCoreClient sharedCoreClient] setConversationToTop:ConversationType_GROUP targetId:viewModel.groupId isTop:on completion:^(BOOL ret) {
            
        }];
    };
    return topVM;
}

- (RCProfileSwitchCellViewModel *)disturbVM:(RCGroupProfileViewModel *)viewModel {
    RCProfileSwitchCellViewModel *disturbVM = [RCProfileSwitchCellViewModel new];
    disturbVM.title = RCLocalizedString(@"SetNotDisturb");
    [[RCCoreClient sharedCoreClient] getConversationNotificationStatus:ConversationType_GROUP targetId:viewModel.groupId success:^(RCConversationNotificationStatus nStatus) {
        dispatch_async(dispatch_get_main_queue(), ^{
            disturbVM.switchOn = !nStatus;
            [viewModel.responder reloadData:NO];
        });
    }  error:^(RCErrorCode status){
        
    }];
    disturbVM.switchValueChanged = ^(BOOL on) {
        [[RCChannelClient sharedChannelManager] setConversationChannelNotificationLevel:ConversationType_GROUP targetId:viewModel.groupId channelId:nil level:(on ? RCPushNotificationLevelBlocked : RCPushNotificationLevelAllMessage) success:^{
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewModel.responder reloadData:NO];
            });
        }];
    };
    return disturbVM;
}
@end
