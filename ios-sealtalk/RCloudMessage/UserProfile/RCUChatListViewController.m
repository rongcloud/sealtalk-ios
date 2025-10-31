//
//  RCUChatListViewController.m
//  SealTalk
//
//  Created by RobinCui on 2024/8/29.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUChatListViewController.h"
#import "KxMenu.h"
#import "RCUChatViewController.h"
#import "RCDCommonString.h"

@interface RCDChatListViewController ()
- (void)pushChat:(id)sender;
@end

@interface RCUChatListViewController ()

@end

@implementation RCUChatListViewController


- (void)pushChatVC:(RCConversationModel *)model {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugDisableSystemEmoji] boolValue];
    
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.conversationType = model.conversationType;
    chatVC.targetId = model.targetId;
    chatVC.title = model.conversationTitle;
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        chatVC.unReadMessage = model.unreadMessageCount;
        chatVC.enableNewComingMessageIcon = YES; //开启消息提醒
        chatVC.enableUnreadMessageIcon = YES;
        if (model.conversationType == ConversationType_SYSTEM) {
            chatVC.title = RCDLocalizedString(@"de_actionbar_sub_system");
        } else if (model.conversationType == ConversationType_PRIVATE) {
            chatVC.displayUserNameInCell = [[userDefault valueForKey:RCDDebugDisplayUserName] boolValue];
        }
    }
    NSInteger num = [DEFAULTS integerForKey:RCDChatroomDefalutHistoryMessageCountKey];
    if (num > 0) {
        chatVC.defaultMessageCount = [@(num) intValue];
    }

    chatVC.disableSystemEmoji = enable;
    [self.navigationController pushViewController:chatVC animated:YES];
}


/**
 *  创建群组
 *
 *  @param sender sender description
 */
- (void)pushContactSelected:(id)sender {
    RCSelectUserViewModel *vm = [RCSelectUserViewModel viewModelWithType:RCSelectUserTypeCreateGroup groupId:nil];
    RCSelectUserViewController *vc = [[RCSelectUserViewController alloc] initWithViewModel:vm];

    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  添加好友
 *
 *  @param sender sender description
 */
- (void)pushAddFriend:(id)sender {
    RCUserSearchViewModel *vm = [[RCUserSearchViewModel alloc] init];
    RCUserSearchViewController *addFriendListVC = [[RCUserSearchViewController alloc] initWithViewModel:vm];
    [self.navigationController pushViewController:addFriendListVC animated:YES];
}
 
- (void)showMenu {
    NSArray *menuItems = @[
        [KxMenuItem menuItem:RCDLocalizedString(@"start_chatting")
                       image:[UIImage imageNamed:@"startchat_icon"]
                      target:self
                      action:@selector(pushChat:)],

        [KxMenuItem menuItem:RCDLocalizedString(@"create_groups")
                       image:[UIImage imageNamed:@"creategroup_icon"]
                      target:self
                      action:@selector(pushContactSelected:)],

        [KxMenuItem menuItem:RCDLocalizedString(@"add_contacts")
                       image:[UIImage imageNamed:@"addfriend_icon"]
                      target:self
                      action:@selector(pushAddFriend:)]
    ];
    CGRect navigationBarRect = self.navigationController.navigationBar.frame;
    CGRect targetFrame = CGRectMake(self.view.frame.size.width - 30, navigationBarRect.origin.y-navigationBarRect.size.height-24, 100, 80);
    [KxMenu setTintColor:HEXCOLOR(0x000000)];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.tabBarController.tabBar.superview
                  fromRect:targetFrame
                 menuItems:menuItems];
}
@end
