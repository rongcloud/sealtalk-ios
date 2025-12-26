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
#import "UIViewController+RCN.h"
#import "RCNDScannerViewController.h"
#import "RCDNavigationViewController.h"
#import "RCNDJoinGroupViewController.h"
#import "RCNDCollectionConversationsViewController.h"

@interface RCDChatListViewController ()<RCNDScannerViewModelDelegate>
- (void)pushChat:(id)sender;
@end

@interface RCUChatListViewController ()
@property (nonatomic, assign) BOOL restoreNaviBar;
@end

@implementation RCUChatListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBackground];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)configureBackground {
    self.conversationListTableView.backgroundColor = [UIColor clearColor];
    UIImage *img = [UIImage imageNamed:@"sealtalk_background"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:imageView belowSubview:self.conversationListTableView];
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    [NSLayoutConstraint activateConstraints:@[
        [imageView.heightAnchor constraintEqualToConstant:height],
        [imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.restoreNaviBar = YES;
    [self rcn_configureTransparentNavigationBar];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.restoreNaviBar) {
        [self rcn_restoreDefaultNavigationBarAppearance];
    }
}

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

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    //聚合会话类型，此处自定设置。
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        RCNDCollectionConversationsViewController *temp = [[RCNDCollectionConversationsViewController alloc] initWithDisplayConversationTypes:@[@(model.conversationType)] collectionConversationType:@[]];
        temp.isEnteredToCollectionViewController = YES;
        [self.navigationController pushViewController:temp animated:YES];
    } else {
        [super onSelectedTableRow:conversationModelType
                conversationModel:model
                      atIndexPath:indexPath];
    }
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
                       image:[UIImage imageNamed:@"new_conversation"]
                      target:self
                      action:@selector(pushChat:)],
        
        [KxMenuItem menuItem:RCDLocalizedString(@"create_groups")
                       image:[UIImage imageNamed:@"create_new_group"]
                      target:self
                      action:@selector(pushContactSelected:)],
        
        [KxMenuItem menuItem:RCDLocalizedString(@"add_contacts")
                       image:[UIImage imageNamed:@"add_new_friend"]
                      target:self
                      action:@selector(pushAddFriend:)],
        [KxMenuItem menuItem:RCDLocalizedString(@"qr_scan")
                       image:[UIImage imageNamed:@"scan_qr"]
                      target:self
                      action:@selector(showScanView)]
    ];
    CGRect navigationBarRect = self.navigationController.navigationBar.frame;
    CGRect targetFrame = CGRectMake(self.view.frame.size.width - 30, navigationBarRect.origin.y-navigationBarRect.size.height-24, 100, 80);
    if ([RCKitUtility isRTL]) {
        targetFrame = CGRectMake(30, navigationBarRect.origin.y-navigationBarRect.size.height-24, 100, 80);
    }
    [KxMenu setTintColor:RCDYCOLOR(0xFFFFFF, 0x000000)];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
    [KxMenu showMenuInView:self.tabBarController.tabBar.superview
                  fromRect:targetFrame
                 menuItems:menuItems];
}

- (void)showScanView {
    RCNDScannerViewController *qrcodeVC = [[RCNDScannerViewController alloc] init];
    qrcodeVC.delegate = self;
    RCDNavigationViewController *navi = [[RCDNavigationViewController alloc] initWithRootViewController:qrcodeVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

#pragma mark - RCNDScannerViewModelDelegate
- (void)openURLInQRCode:(NSString *)urlString {
    [RCKitUtility openURLInSafariViewOrWebView:urlString base:self];
    
}
- (void)showUserProfileInQRCode:(NSString *)userID {
    RCUserProfileViewModel *vm = [RCUserProfileViewModel viewModelWithUserId:userID];
    RCProfileViewController *vc = [[RCProfileViewController alloc] initWithViewModel:vm];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)showGroupConversationInQRCode:(NSString *)groupId title:(NSString *)title {
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.targetId = groupId;
    chatVC.title = title;
    chatVC.conversationType = ConversationType_GROUP;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)showGroupJoinViewInQRCode:(RCGroupInfo *)info {
    RCNDJoinGroupViewController *vc = [[RCNDJoinGroupViewController alloc] initWithGroupInfo:info];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
