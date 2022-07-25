//
//  RCDDebugUltraGroupListController.m
//  SealTalk
//
//  Created by 孙浩 on 2021/11/25.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugUltraGroupListController.h"
#import "RCDDebugUltraGroupChatViewController.h"
#import "RCDUIBarButtonItem.h"
#import "RCDDebugUltraGroupSendMessage.h"
#import "UIView+MBProgressHUD.h"

@interface RCDDebugUltraGroupListController ()

@property (nonatomic, strong) UITextField *targetIdTextField;

@end

@implementation RCDDebugUltraGroupListController

- (id)init {
    self = [super init];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
            @(ConversationType_ULTRAGROUP)
        ]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavi];
}

- (void)setNavi {
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"add"] target:self action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    self.navigationItem.title = @"超级群id【频道id】";
}

- (void)rightBarButtonItemClicked:(id)sender {
    
//    [RCDDebugUltraGroupSendMessage sendMessage:@"dda" conversationType:ConversationType_ULTRAGROUP targetId:@"1228" channelId:@"lsq2"];
//    return;
    
    NSString *title = @"发起超级群会话";
    NSString *message = @"请输入超级群 ID";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"发起会话" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        NSString *userId = self.targetIdTextField.text;
        [self toChatVCWithUserId:userId];
    }];
    okAction.enabled = NO;
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = @"请输入超级群 ID";
        self.targetIdTextField = textField;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = self.targetIdTextField.text.length > 0;
    }
}


- (void)toChatVCWithUserId:(NSString *)userId {
    [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP targetId:userId];
    RCDDebugUltraGroupChatViewController *chatVC = [[RCDDebugUltraGroupChatViewController alloc] initWithConversationType:ConversationType_ULTRAGROUP targetId:userId];

    chatVC.title = userId;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath{

    [[RCChannelClient sharedChannelManager] clearMessages:ConversationType_GROUP targetId:model.targetId channelId:model.channelId];
    RCDDebugUltraGroupChatViewController *chatVC = [[RCDDebugUltraGroupChatViewController alloc] init];
    chatVC.isDebugEnter = YES;
    chatVC.conversationType = model.conversationType;
    chatVC.targetId = model.targetId;
    chatVC.channelId = model.channelId;
    chatVC.title = model.conversationTitle;
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        chatVC.unReadMessage = model.unreadMessageCount;
        chatVC.enableNewComingMessageIcon = YES; //开启消息提醒
        chatVC.enableUnreadMessageIcon = NO;
        if (model.conversationType == ConversationType_SYSTEM) {
            chatVC.title = RCDLocalizedString(@"de_actionbar_sub_system");
        } else if (model.conversationType == ConversationType_PRIVATE) {
            chatVC.displayUserNameInCell = NO;
        }
    }
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    
    if (model.conversationType == ConversationType_ULTRAGROUP) {
        int totalMentionCount = [[RCChannelClient sharedChannelManager] getUltraGroupUnreadMentionedCount:model.targetId];
        
        int conversationMentionCount = 0;
        //超级群未读
        if (model.channelId.length == 0) {
            RCConversation *conversation = 
                [[RCCoreClient sharedCoreClient] getConversation:ConversationType_ULTRAGROUP 
                                                        targetId:model.targetId];
            conversationMentionCount = conversation.mentionedCount;
        } else {
            RCConversation *conversation =
                [[RCChannelClient sharedChannelManager] getConversation:ConversationType_ULTRAGROUP
                                                        targetId:model.targetId 
                                                              channelId:model.channelId];
            conversationMentionCount = conversation.mentionedCount;
        }
        
        if (totalMentionCount > 0 && conversationMentionCount > 0) {
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(0, 0, 80, 20);
            label.textColor = [UIColor redColor];
            label.backgroundColor = [UIColor yellowColor];
            [((RCConversationCell *)cell).conversationTagView addSubview:label];
            label.text = [NSString stringWithFormat:@"%d-%d", conversationMentionCount, totalMentionCount];
        }
    }
    
    ((RCConversationCell *)cell).conversationTitle.text = [NSString stringWithFormat:@"%@【%@】",model.targetId,model.channelId];
}

- (void)didLongPressCellPortrait:(RCConversationModel *)model {
    NSArray *list = [[RCChannelClient sharedChannelManager] getUnreadMentionedMessages:model.conversationType targetId:model.targetId channelId:model.channelId];    
    [RCAlertView showAlertController:nil message:[NSString stringWithFormat:@"超级群获取未读@列表, %@", list] cancelTitle:RCDLocalizedString(@"confirm")];
}

- (NSMutableArray<RCConversationModel *> *)willReloadTableData:(NSMutableArray<RCConversationModel *> *)dataSource {
    
    NSMutableArray *dataSources = [NSMutableArray new];
    
    SEL sel = NSSelectorFromString(@"getUltraGroupConversationListForAllChannel");
    if ([[RCChannelClient sharedChannelManager] respondsToSelector:sel]) {
        NSArray *conversationList = [[RCChannelClient sharedChannelManager] performSelector:sel];
        for (RCConversation *conversation in conversationList) {
            RCConversationModel *model = [[RCConversationModel alloc] initWithConversation:conversation extend:nil];
            model.channelId = conversation.channelId;
            [dataSources addObject:model];
        }
    }
    return dataSources;
}

@end
