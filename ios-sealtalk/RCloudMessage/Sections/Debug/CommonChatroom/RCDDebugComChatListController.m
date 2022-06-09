//
//  RCDDebugComChatListController.m
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDDebugComChatListController.h"
#import "RCDDebugComChatViewController.h"
#import "RCDebugHeader.h"

@interface RCloudImageView : UIImageView
- (void)setPlaceholderImage:(UIImage *)__placeholderImage;
@end

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
    
    RCDebugCollectionModifyMode modifyMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectConversationCollectionInfoModifyType"];
    if (RCDebugCollectionModifyModeWillDisplayCell == modifyMode ||
        RCDebugCollectionModifyModeGlobalConfig == modifyMode) {
        NSArray *collectionConversationTypeArr = self.collectionConversationTypeArray;
        if (collectionConversationTypeArr && ![collectionConversationTypeArr containsObject:@(ConversationType_PRIVATE)]) {
            NSArray *modifyCollectionTypeArray = [NSArray arrayWithArray:collectionConversationTypeArr];
            modifyCollectionTypeArray = [modifyCollectionTypeArray arrayByAddingObject:@(ConversationType_PRIVATE)];
            [self setCollectionConversationType:modifyCollectionTypeArray];
        }else {
            [self setCollectionConversationType:@[ @(ConversationType_PRIVATE) ]];
        }
    }
    if (RCDebugCollectionModifyModeGlobalConfig == modifyMode) {
        // 设置聚合头像标题测试
        RCKitConfigCenter.ui.globalConversationCollectionTitleDic = @{
            @(ConversationType_PRIVATE): @"全局配置修改聚合"
        };
        RCKitConfigCenter.ui.globalConversationCollectionAvatarDic = @{
            @(ConversationType_PRIVATE): @"http://7xogjk.com1.z0.glb.clouddn.com/R0zowp7aX1614149348444531982"
            //        @(ConversationType_PRIVATE): [[NSBundle mainBundle] pathForResource:@"add_phonebook" ofType:@"png"]
        };
    }else {
        RCKitConfigCenter.ui.globalConversationCollectionTitleDic = nil;
        RCKitConfigCenter.ui.globalConversationCollectionAvatarDic = nil;
    }
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RCDebugCollectionModifyMode modifyMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectConversationCollectionInfoModifyType"];
    if (RCDebugCollectionModifyModeWillDisplayCell == modifyMode) {
        RCConversationModel *model = self.conversationListDataSource[indexPath.row];
        if (RC_CONVERSATION_MODEL_TYPE_COLLECTION == model.conversationModelType &&
            ConversationType_PRIVATE == model.conversationType) {
            RCConversationCell *conversationCell = (RCConversationCell *)cell;
            conversationCell.conversationTitle.text = @"显示前修改聚合";
            [conversationCell.headerImageView setPlaceholderImage:[UIImage imageNamed:@"icon_person"]];
        }
    }
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath  {
    NSInteger collectionModifyType = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectConversationCollectionInfoModifyType"];
    if (1 == collectionModifyType || 2 == collectionModifyType) {
        [super onSelectedTableRow:conversationModelType
                conversationModel:model
                      atIndexPath:indexPath];
        return;
    }

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
