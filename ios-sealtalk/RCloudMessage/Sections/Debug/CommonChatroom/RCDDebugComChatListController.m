//
//  RCDDebugComChatListController.m
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDDebugComChatListController.h"
#import "RCDDebugComChatViewController.h"

@interface RCDDebugChatListViewController()
- (void)pushChatViewController:(RCConversationModel *)model;
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath ;
@end

@interface RCDDebugComChatListController ()

@end

@implementation RCDDebugComChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath  {
    //聚合会话类型，此处自定设置。
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        RCDDebugComChatListController *temp = [[RCDDebugComChatListController alloc] init];
        NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInteger:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        [self.navigationController pushViewController:temp animated:YES];
    } else {
        [super onSelectedTableRow:conversationModelType
                conversationModel:model
                      atIndexPath:indexPath];
    }
}

- (void)pushChatViewController:(RCConversationModel *)model {
    
    RCDDebugComChatViewController *chatVC = [[RCDDebugComChatViewController alloc] init];
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
            chatVC.displayUserNameInCell = NO;
        }
    }
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
