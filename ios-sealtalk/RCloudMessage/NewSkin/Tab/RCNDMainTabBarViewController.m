//
//  RCNDMainTabBarViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMainTabBarViewController.h"
#import "RCDUltraGroupController.h"
#import "RCDChatListViewController.h"
#import "RCDContactViewController.h"
#import "RCNDMeViewController.h"
#import "RCNDChatroomViewController.h"
#import "UITabBar+badge.h"
#import "RCDUtilities.h"
#import "RCDCommonDefine.h"
#import "RCTransationPersistModel.h"
#import "RCDNavigationViewController.h"
#import "RCUDateUtility.h"
#import "RCUChatViewController.h"
// 2025-11-20
#import "RCNDMeViewController.h"
#import "RCNDFriendListViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCGroupQRCellViewModel.h"
#import "RCNDFriendListViewModel.h"
#import "RCUChatListViewController.h"
#import "RCNDSearchMoreViewController.h"
#import "RCNDSearchMoreMessagesViewModel.h"
#import "RCDIMService.h"
#import "NormalAlertView.h"

extern NSString *const RCDDebugMessageDisableUserInfoEntrust;
static NSInteger RCD_MAIN_TAB_INDEX = 0;
extern NSString * const RCUChatViewControllerCleanMessage;
@interface RCNDMainTabBarViewController ()<RCFriendListViewModelDelegate,RCMyGroupsViewModelDelegate>

@property NSUInteger previousIndex;

@property (nonatomic, strong) NSArray *tabTitleArr;

@property (nonatomic, strong) NSArray *imageArr;

@property (nonatomic, strong) NSArray *selectImageArr;

@property (nonatomic, strong) NSArray *animationImages;

@property (nonatomic, assign) BOOL ultraGroupEnable;
@end

@implementation RCNDMainTabBarViewController



- (instancetype)init {
    self = [super init];
    if (self) {
        RCD_MAIN_TAB_INDEX = 0;
    }
    return self;
}

+ (NSInteger)currentTabBarItemIndex {
    return RCD_MAIN_TAB_INDEX;;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkUltraGroup];
    self.view.backgroundColor = RCDDYCOLOR(0xffffff, 0x1c1c1c);
    bool ret = [[[NSUserDefaults standardUserDefaults] valueForKey:RCDDebugMessageDisableUserInfoEntrust] boolValue];
    self.viewControllers = [self createViewControllers:!ret];
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeSelectedIndex:)
                                                 name:@"ChangeTabBarIndex"
                                               object:nil];
    [self configureTranslationLanguange];
    [self ready];
}

- (void)checkUltraGroup {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [userDefault valueForKey:@"RCDDebugUltraGroupEnable"];
    self.ultraGroupEnable = [value boolValue];
}

- (void)configureTranslationLanguange {
    RCTransationPersistModel *model = [RCTransationPersistModel loadTranslationConfig];
    if ([model.srcLanguage isKindOfClass:[NSString class]]
        && [model.targetLanguage isKindOfClass:[NSString class]]) {
        RCKitTranslationConfig *translationConfig = [[RCKitTranslationConfig alloc] initWithSrcLanguage:model.srcLanguage
                                                                                         targetLanguage:model.targetLanguage];
        [RCKitConfig defaultConfig].message.translationConfig = translationConfig;
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}


- (NSArray *)createViewControllers:(BOOL)enableInfoManage {
    NSArray *viewControllers = nil;
    UIViewController *chatVC = nil;
    if (enableInfoManage) {
        chatVC = [[RCUChatListViewController alloc] init];
    } else {
        chatVC = [[RCDChatListViewController alloc] init];
    }
    RCDNavigationViewController *naviChatVC = [self navigationWithRootVC:chatVC
                                                                   title: RCDLocalizedString(@"Messages")
                                                               imageName:@"chat_list_unselect"
                                                         selectImageName:@"chat_list_select"];
    
    UIViewController *contactVC = nil;
    if (enableInfoManage) {
        contactVC = [self createFriendListViewController:YES];
    } else {
        contactVC = [[RCDContactViewController alloc] init];
    }
    RCDNavigationViewController *naviContactVC = [self navigationWithRootVC:contactVC
                                                                      title:RCDLocalizedString(@"good_friend")
                                                                  imageName:@"contact_unselect"
                                                            selectImageName:@"contact_select"];
    
    
    RCNDChatroomViewController *chatroomVC = [RCNDChatroomViewController new];
    RCDNavigationViewController *naviDiscoveryVC = [self navigationWithRootVC:chatroomVC
                                                                        title:RCDLocalizedString(@"chatroom")
                                                                    imageName:@"chatroom_unselect"
                                                              selectImageName:@"chatroom_select"];
    
    RCNDMeViewModel *meViewModel = [[RCNDMeViewModel alloc] init];
    RCNDMeViewController *meVC = [[RCNDMeViewController alloc] initWithViewModel:meViewModel];
    RCDNavigationViewController *naviMeVC = [self navigationWithRootVC:meVC
                                                                 title:RCDLocalizedString(@"me")
                                                             imageName:@"me_unselect"
                                                       selectImageName:@"me_select"];
    
    
    
    if (self.ultraGroupEnable) {
        RCDUltraGroupController *ultraGroupVC = [[RCDUltraGroupController alloc] init];
        RCDNavigationViewController *naviUltraGroupVC =  [self navigationWithRootVC:ultraGroupVC
                                                                              title:RCDLocalizedString(@"UltraGroup")
                                                                          imageName:@"ultra_unselect"
                                                                    selectImageName:@"ultra_select"];
        
        viewControllers = @[naviChatVC, naviUltraGroupVC, naviDiscoveryVC, naviContactVC, naviMeVC ];
    } else {
        viewControllers = @[naviChatVC, naviDiscoveryVC, naviContactVC,  naviMeVC ];
    }
    return viewControllers;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBadgeValueForTabBarItem];
}

- (void)updateBadgeValueForTabBarItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.viewControllers
         enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull objNavi, NSUInteger idx, BOOL *_Nonnull stop) {
            if([objNavi isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navi = (UINavigationController *)objNavi;
                UIViewController *obj = [navi.childViewControllers firstObject];
                if ([obj isKindOfClass:[RCUChatListViewController class]]) {
                    RCUChatListViewController *chatListVC = (RCUChatListViewController *)obj;
                    [chatListVC updateBadgeValueForTabBarItem];
                    *stop = YES;
                }
            }
        }];
    });
    
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    NSUInteger index = tabBarController.selectedIndex;
    RCD_MAIN_TAB_INDEX = index;
    if (self.previousIndex != index) {
        [self tabBarImageAnimation:index];
    }
    
    switch (index) {
        case 0: {
            if (self.previousIndex == index) {
                //判断如果有未读数存在，发出定位到未读数会话的通知
                if ([[RCCoreClient sharedCoreClient] getTotalUnreadCount] > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoNextConversation" object:nil];
                }
            }
        } break;
            
        default:
            break;
    }
    self.previousIndex = index;
    if(self.ultraGroupEnable) {
        self.navigationController.navigationBarHidden = (index == 1);
    }
}

- (void)changeSelectedIndex:(NSNotification *)notify {
    NSInteger index = [notify.object integerValue];
    self.selectedIndex = index;
}

- (void)tabBarImageAnimation:(NSUInteger)index {
    NSMutableArray *arry = [NSMutableArray array];
    for (UIControl *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            for (UIView *imageView in tabBarButton.subviews) {
                if ([imageView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                    //添加动画:放大效果
                    [arry addObject:imageView];
                }
            }
        }
    }
    
    //快速切换时会出现前一个动画还在播放的情况，所以需要先停止前一个动画
    if (self.previousIndex >= arry.count) {
        return;
    }
    UIImageView *preImageView = arry[self.previousIndex];
    [preImageView stopAnimating];
    preImageView.animationImages = nil;
    
    UIImageView *imgView = arry[index];
    imgView.animationImages = self.animationImages[index];
    imgView.animationDuration = 1;
    imgView.animationRepeatCount = 1;
    [imgView startAnimating];
}

- (UIViewController *)createFriendListViewController:(BOOL)enableManagement {
    
    [RCViewModelAdapterCenter registerDelegate:self
                             forViewModelClass:[RCSearchGroupsViewModel class]];
    RCFriendListViewController *contactVC = nil;
    if (enableManagement) {
        [RCViewModelAdapterCenter registerDelegate:self
                                 forViewModelClass:[RCNDFriendListViewModel class]];
        RCNDFriendListViewModel *vm = [[RCNDFriendListViewModel alloc] init];
        contactVC = [[RCNDFriendListViewController alloc] initWithViewModel:vm];
    } else {
        [RCViewModelAdapterCenter registerDelegate:self
                                 forViewModelClass:[RCFriendListViewModel class]];
        RCFriendListViewModel *vm = [[RCFriendListViewModel alloc] init];
        contactVC = [[RCFriendListViewController alloc] initWithViewModel:vm];
    }
    return contactVC;
}

- (RCDNavigationViewController *)navigationWithRootVC:(UIViewController *)vc
                                                title:(NSString *)title
                                            imageName:(NSString *)imageName
                                      selectImageName:(NSString *)selectImageName {
    RCDNavigationViewController *navi = [[RCDNavigationViewController alloc] initWithRootViewController:vc];
    navi.tabBarItem.title = title;
    navi.tabBarItem.image =
    [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navi.tabBarItem.selectedImage =
    [[UIImage imageNamed:selectImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return navi;
}

#pragma mark - RCUFriendListViewModelDelegate



- (NSArray <RCFriendListPermanentCellViewModel *>*_Nullable)appendPermanentCellViewModelsForFriendListViewModel:(RCFriendListViewModel *)viewModel {
    
    __weak __typeof(self)weakSelf = self;
    
    RCFriendListPermanentCellViewModel *newFriend = [[RCFriendListPermanentCellViewModel alloc] initWithTitle:RCLocalizedString(@"FriendApplicationNewFriend")
                                                                                                     portrait:[UIImage imageNamed:@"contact_new"] touchBlock:^(UIViewController * vc) {
        [weakSelf showFriendApplyWithController:vc];
    }];
    
    RCFriendListPermanentCellViewModel *myGroup = [[RCFriendListPermanentCellViewModel alloc] initWithTitle:RCLocalizedString(@"MyGroups")
                                                                                                   portrait:[UIImage imageNamed:@"contact_group"] touchBlock:^(UIViewController * vc) {
        [weakSelf showMyGroupsWithController:vc];
    }];
    RCFriendListCellViewModel *me = [[RCFriendListCellViewModel alloc] initWithFriend:nil];
    [[RCCoreClient sharedCoreClient] getMyUserProfile:^(RCUserProfile * _Nonnull userProfile) {
        RCFriendInfo *info = [RCFriendInfo new];
        info.userId = userProfile.userId;
        info.name = userProfile.name;
        info.portraitUri = userProfile.portraitUri;
        [me refreshWithFriend:info];
    } error:^(RCErrorCode errorCode) {
        
    }];
    RCFriendListPermanentCellViewModel *notificationVC = [[RCFriendListPermanentCellViewModel alloc] initWithTitle:RCLocalizedString(@"MyGroupNotifications")
                                                                                                          portrait:[UIImage imageNamed:@"contact_public"] touchBlock:^(UIViewController * vc) {
        [weakSelf showMyGroupNotificationsWithController:vc];
    }];
    return @[newFriend,myGroup,notificationVC,me];
}

- (void)showMyGroupsWithController:(UIViewController *)controller {
    RCMyGroupsViewModel *vm = [[RCMyGroupsViewModel alloc] initWithOption:nil];
    vm.delegate = self;
    RCMyGroupsViewController *vc = [[RCMyGroupsViewController alloc] initWithViewModel:vm];
    [controller.navigationController pushViewController:vc animated:YES];
}

- (BOOL)myGroupsViewModel:(RCMyGroupsViewModel *)viewModel
           viewController:(UIViewController*)viewController
                tableView:(UITableView *)tableView
             didSelectRow:(NSIndexPath *)indexPath
            cellViewModel:(RCBaseCellViewModel *)cellViewModel {
    
    RCGroupInfoCellViewModel *vm = (RCGroupInfoCellViewModel *)cellViewModel;
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.targetId = vm.groupInfo.groupId;;
    chatVC.title = vm.groupInfo.groupName;
    [viewController.navigationController pushViewController:chatVC animated:YES];
    return YES;
}
- (BOOL)searchGroupsViewModel:(RCSearchGroupsViewModel *_Nonnull)viewModel
               viewController:(UIViewController*_Nonnull)viewController
                    tableView:(UITableView *_Nonnull)tableView
                 didSelectRow:(NSIndexPath *_Nonnull)indexPath
                cellViewModel:(RCBaseCellViewModel *_Nonnull)cellViewModel {
    RCGroupInfoCellViewModel *vm = (RCGroupInfoCellViewModel *)cellViewModel;
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.targetId = vm.groupInfo.groupId;;
    chatVC.title = vm.groupInfo.groupName;
    [viewController.navigationController pushViewController:chatVC animated:YES];
    return YES;
}



- (void)showMyGroupNotificationsWithController:(UIViewController *)controller {
    NSArray *status = @[@(RCGroupApplicationStatusManagerUnHandled),
                        @(RCGroupApplicationStatusManagerRefused),
                        @(RCGroupApplicationStatusInviteeUnHandled),
                        @(RCGroupApplicationStatusInviteeRefused),
                        @(RCGroupApplicationStatusJoined),
                        @(RCGroupApplicationStatusExpired)];
    NSArray *types = @[@(RCGroupApplicationDirectionApplicationSent),
                       @(RCGroupApplicationDirectionInvitationSent),
                       @(RCGroupApplicationDirectionInvitationReceived),
                       @(RCGroupApplicationDirectionApplicationReceived)];
    RCGroupNotificationViewModel *vm = [[RCGroupNotificationViewModel alloc] initWithOption:nil
                                                                                      types:types
                                                                                     status:status];
    RCGroupNotificationViewController *listVC = [[RCGroupNotificationViewController alloc] initWithViewModel:vm];
    [controller.navigationController pushViewController:listVC animated:YES];
    
}

- (void)showFriendApplyWithController:(UIViewController *)controller {
    NSMutableArray *sections = [NSMutableArray array];
    RCFriendApplyItemFilterBlock block = ^BOOL(RCApplyFriendCellViewModel *obj, NSInteger start, NSInteger end, BOOL * _Nonnull stop) {
        if (obj.application.operationTime >= start && obj.application.operationTime <end) {
            return YES;
        }
        //        if(obj.application.operationTime >= end) {
        //            *stop = YES;
        //        }
        return NO;
    };
    // TODO: 本地化
    RCApplyFriendSectionItem *justNow = [[RCApplyFriendSectionItem alloc] initWithFilterBlock:block compareBlock:nil];
    justNow.title = RCDLocalizedString(@"Just");
    justNow.timeStart = [RCUDateUtility startOfToday];
    justNow.timeEnd  = [[NSDate date]timeIntervalSince1970] * 1000;
    [sections addObject:justNow];
    
    RCApplyFriendSectionItem *oneDays = [[RCApplyFriendSectionItem alloc] initWithFilterBlock:block compareBlock:nil];
    oneDays.title = RCDLocalizedString(@"OneDay");
    oneDays.timeStart = [RCUDateUtility startTimeOfDaysBefore:-1];
    oneDays.timeEnd  = [RCUDateUtility startOfToday];
    [sections addObject:oneDays];
    
    RCApplyFriendSectionItem *threeDays = [[RCApplyFriendSectionItem alloc] initWithFilterBlock:block compareBlock:nil];
    threeDays.title = RCDLocalizedString(@"LastThreeDay");
    threeDays.timeStart = [RCUDateUtility startTimeOfDaysBefore:-4];
    threeDays.timeEnd  = [RCUDateUtility startTimeOfDaysBefore:-1];
    [sections addObject:threeDays];
    
    RCApplyFriendSectionItem *longAgo = [[RCApplyFriendSectionItem alloc] initWithFilterBlock:block compareBlock:nil];
    longAgo.title = RCDLocalizedString(@"ThreeDaysAgo");
    longAgo.timeStart = 0;
    longAgo.timeEnd  = [RCUDateUtility startTimeOfDaysBefore:-4];
    [sections addObject:longAgo];
    
    RCApplyFriendListViewModel *vm = [[RCApplyFriendListViewModel alloc] initWithSectionItems:sections option:nil types:@[] status:@[]];
    RCApplyFriendListViewController *listVC = [[RCApplyFriendListViewController alloc] initWithViewModel:vm];
    [controller.navigationController pushViewController:listVC animated:YES];
}

- (void)ready {
    [RCViewModelAdapterCenter registerDelegate:self
                             forViewModelClass:[RCGroupProfileViewModel class]];
    
    [self configureTabBarAppearance];
}

- (void)configureTabBarAppearance {
    UIColor *selectedColor = RCDynamicColor(@"text_primary_color", @"0x020814", @"0xffffff");
    UIColor *unselectedColor = RCDynamicColor(@"text_secondary_color", @"0x7C838E", @"0x7C838E");
    UIColor *backgroundColor = RCDynamicColor(@"common_background_color", @"0xFFFFFF", @"0x000000");
    
    if (@available(iOS 15.0, *)) {
        // iOS 15+ 使用 UITabBarAppearance
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = backgroundColor;
        
        // 去除顶部黑线
        appearance.shadowColor = [UIColor clearColor];
        
        // 设置选中状态的颜色
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor;
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: selectedColor};
        
        // 设置未选中状态的颜色
        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor;
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: unselectedColor};
        
        UITabBarItemAppearance *itemAppearance = [[UITabBarItemAppearance alloc] init];

        // 2. 配置【未选中】状态的字体
        NSDictionary *normalAttrs = @{
            NSFontAttributeName: [UIFont systemFontOfSize:14], // 未选中字号12
            NSForegroundColorAttributeName: unselectedColor // 未选中颜色
        };
        itemAppearance.normal.titleTextAttributes = normalAttrs;
        
        // 3. 配置【选中】状态的字体
        NSDictionary *selectedAttrs = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:14], // 选中加粗+字号12
            NSForegroundColorAttributeName: selectedColor // 选中颜色
        };
        itemAppearance.selected.titleTextAttributes = selectedAttrs;
        appearance.stackedLayoutAppearance = itemAppearance;
        appearance.inlineLayoutAppearance = itemAppearance;
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    } else {
        // iOS 15 以下使用传统方式
        self.tabBar.tintColor = selectedColor;
        if (@available(iOS 10.0, *)) {
            self.tabBar.unselectedItemTintColor = unselectedColor;
        }
        self.tabBar.barTintColor = backgroundColor;
        
        // 去除顶部黑线
        self.tabBar.shadowImage = [UIImage new];
        self.tabBar.backgroundImage = [UIImage new];
    }
}

- (NSArray <NSArray <RCProfileCellViewModel*> *> * )profileViewModel:(RCProfileViewModel *)viewModel
                                        willLoadProfileCellViewModel:(NSArray <NSArray <RCProfileCellViewModel*> *> *)profileList {
    if ([viewModel isKindOfClass:[RCGroupProfileViewModel class]]) {
        RCGroupProfileViewModel *groupVM = (RCGroupProfileViewModel *)viewModel;
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i< profileList.count; i++) {
            NSArray *tmp = profileList[i];
            if (i == 1) {
                NSMutableArray *items = [NSMutableArray arrayWithArray:tmp];
                RCGroupQRCellViewModel *vm = [RCGroupQRCellViewModel viewModelWithGroupId:groupVM.groupId];
                [items insertObject:vm atIndex:2];
                [array addObject:items];
            } else if(i == 2) {
                [array addObject:tmp];
                NSMutableArray *items = [NSMutableArray array];
                RCProfileCommonCellViewModel *historyVM = [[RCProfileCommonCellViewModel alloc] initWithCellType:RCUProfileCellTypeText title:RCDLocalizedString(@"search_chat_history") detail:nil];
                [items addObject:historyVM];
                [array addObject:items];
                
            } else {
                [array addObject:tmp];
            }
        }
        NSMutableArray *items = [NSMutableArray array];
        RCProfileCommonCellViewModel *clearVM = [[RCProfileCommonCellViewModel alloc] initWithCellType:RCUProfileCellTypeText title:RCDLocalizedString(@"clear_chat_history") detail:nil];
        [items addObject:clearVM];
        [array addObject:items];
        return array;
    }
    return profileList;
}

- (BOOL)profileViewModel:(RCProfileViewModel *)viewModel
          viewController:(UIViewController*)viewController
               tableView:(UITableView *)tableView
            didSelectRow:(NSIndexPath *)indexPath
           cellViewModel:(RCProfileCellViewModel *)cellViewModel {
    RCGroupProfileViewModel *groupVM = nil;
    if ([viewModel isKindOfClass:[RCGroupProfileViewModel class]]) {
        groupVM = (RCGroupProfileViewModel*)viewModel;
    }
    if ([cellViewModel isKindOfClass:[RCGroupQRCellViewModel class]]) {
        RCGroupQRCellViewModel *vm = (RCGroupQRCellViewModel *)cellViewModel;
        
        [vm itemDidSelectedByViewController:viewController];
        return YES;
    }
    
    if ([cellViewModel isKindOfClass:[RCProfileCommonCellViewModel class]]) {
        RCProfileCommonCellViewModel *vm = (RCProfileCommonCellViewModel *)cellViewModel;
        if ([vm.title isEqualToString:RCDLocalizedString(@"search_chat_history")]) {
            RCConversation *conversation = [RCConversation new];
            conversation.conversationType = ConversationType_GROUP;
            conversation.targetId = groupVM.groupId;
            RCNDSearchMoreMessagesViewModel *viewModel = [[RCNDSearchMoreMessagesViewModel alloc] initWithTitle:@"" keyword:@"" conversation:conversation];
            RCNDSearchMoreViewController *controller = [[RCNDSearchMoreViewController alloc] initWithViewModel:viewModel];
            [viewController.navigationController pushViewController:controller animated:YES];
            return YES;
        }
        if ([vm.title isEqualToString:RCDLocalizedString(@"clear_chat_history")]) {
            [RCActionSheetView showActionSheetView:RCDLocalizedString(@"clear_chat_history_alert") cellArray:@[RCDLocalizedString(@"confirm")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
                [self clearHistoryMessage:groupVM.groupId];
                
            } cancelBlock:^{
                
            }];
            return YES;
        }
    }
    
    return NO;
}

- (void)clearHistoryMessage:(NSString *)groupID {
    [[RCDIMService sharedService] clearHistoryMessage:ConversationType_GROUP
                                             targetId:groupID
                                         successBlock:^{
        RCConversation *conversation = [[RCConversation alloc] init];
        conversation.targetId = groupID;
        conversation.conversationType = ConversationType_GROUP;
        [[NSNotificationCenter defaultCenter] postNotificationName:RCUChatViewControllerCleanMessage object:conversation];
        [NormalAlertView showAlertWithTitle:nil
                                    message:RCDLocalizedString(@"clear_chat_history_success")
                              describeTitle:nil
                               confirmTitle:RCDLocalizedString(@"confirm")
                                    confirm:^{
        }];
    }
                                           errorBlock:^(RCErrorCode status) {
        [NormalAlertView showAlertWithTitle:nil
                                    message:RCDLocalizedString(@"clear_chat_history_fail")
                              describeTitle:nil
                               confirmTitle:RCDLocalizedString(@"confirm")
                                    confirm:^{
        }];
    }];
}
@end

