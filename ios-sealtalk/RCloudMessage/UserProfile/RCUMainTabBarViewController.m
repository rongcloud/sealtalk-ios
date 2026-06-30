//
//  RCUMainTabBarViewController.m
//  SealTalk
//
//  Created by RobinCui on 2024/8/28.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUMainTabBarViewController.h"
#import "RCDUltraGroupController.h"
#import "RCUChatListViewController.h"
//#import "RCDContactViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCUMeTableViewController.h"
#import "RCDSquareTableViewController.h"
#import "UITabBar+badge.h"
#import "RCDUtilities.h"
#import "RCDCommonDefine.h"
#import "RCTransationPersistModel.h"
#import "RCDNavigationViewController.h"
#import "RCDGroupViewController.h"
#import "RCDPublicServiceListViewController.h"
#import "RCUMeTableViewController.h"
#import "RCUDateUtility.h"
#import "RCUChatViewController.h"

@interface RCUMainTabBarViewController ()<RCFriendListViewModelDelegate,RCMyGroupsViewModelDelegate>

@property NSUInteger previousIndex;

@property (nonatomic, strong) NSArray *tabTitleArr;

@property (nonatomic, strong) NSArray *imageArr;

@property (nonatomic, strong) NSArray *selectImageArr;

@property (nonatomic, strong) NSArray *animationImages;

@property (nonatomic, assign) BOOL ultraGroupEnable;
@end

@implementation RCUMainTabBarViewController



- (void)viewDidLoad {
    [super viewDidLoad];

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (UIViewController *)createFriendListViewController {
    [RCViewModelAdapterCenter registerDelegate:self
                             forViewModelClass:[RCFriendListViewModel class]];
    [RCViewModelAdapterCenter registerDelegate:self
                             forViewModelClass:[RCSearchGroupsViewModel class]];
    RCFriendListViewModel *vm = [[RCFriendListViewModel alloc] init];
    RCFriendListViewController *contactVC = [[RCFriendListViewController alloc] initWithViewModel:vm];
    return contactVC;
}

- (RCDNavigationViewController *)navigationControllerWithRootView:(UIViewController *)vc {
    RCDNavigationViewController *navi = [[RCDNavigationViewController alloc] initWithRootViewController:vc];
    return navi;
}
- (void)setControllers {
    RCUChatListViewController *chatVC = [[RCUChatListViewController alloc] init];
    RCDNavigationViewController *naviChatVC = [self navigationControllerWithRootView:chatVC];
    
    UIViewController *contactVC = [self createFriendListViewController];
    RCDNavigationViewController *naviContactVC = [self navigationControllerWithRootView:contactVC];
    
    
    RCDSquareTableViewController *discoveryVC = [[RCDSquareTableViewController alloc] init];
    RCDNavigationViewController *naviDiscoveryVC = [self navigationControllerWithRootView:discoveryVC];
    
    RCUMeTableViewController *meVC = [[RCUMeTableViewController alloc] init];
    RCDNavigationViewController *naviMeVC = [self navigationControllerWithRootView:meVC];
    
    NSArray *viewControllers = nil;

    if (self.ultraGroupEnable) {
        RCDUltraGroupController *ultraGroupVC = [[RCDUltraGroupController alloc] init];
        RCDNavigationViewController *naviUltraGroupVC = [self navigationControllerWithRootView:ultraGroupVC];
        
        viewControllers = @[naviChatVC, naviUltraGroupVC, naviContactVC, naviDiscoveryVC, naviMeVC ];
    } else {
        viewControllers = @[naviChatVC, naviContactVC, naviDiscoveryVC, naviMeVC ];
    }
    [self setTabBarItems:viewControllers];
    self.viewControllers = viewControllers;
}


- (void)setTabBarItems:(NSArray *)viewControllers {
    [viewControllers
     enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull objNavi, NSUInteger idx, BOOL *_Nonnull stop) {
        UIViewController *obj = nil;
        if([objNavi isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = (UINavigationController *)objNavi;
            obj = [navi.childViewControllers firstObject];
        }
        if ([obj isKindOfClass:[RCUChatListViewController class]] || [obj isKindOfClass:[RCFriendListViewController class]] || [obj isKindOfClass:[RCDSquareTableViewController class]] || [obj isKindOfClass:[RCUMeTableViewController class]] || [obj isKindOfClass:[RCDUltraGroupController class]]) {
            objNavi.tabBarItem.title = self.tabTitleArr[idx];
            objNavi.tabBarItem.image =
            [[UIImage imageNamed:self.imageArr[idx]]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            objNavi.tabBarItem.selectedImage =
            [[UIImage imageNamed:self.selectImageArr[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            NSLog(@"Unknown TabBarController");
        }
        [objNavi.tabBarController.tabBar bringBadgeToFrontOnItemIndex:(int)idx];
    }];
}

#pragma mark - RCUFriendListViewModelDelegate



- (NSArray <RCFriendListPermanentCellViewModel *>*_Nullable)appendPermanentCellViewModelsForFriendListViewModel:(RCFriendListViewModel *)viewModel {

    __weak __typeof(self)weakSelf = self;
    
    RCFriendListPermanentCellViewModel *newFriend = [[RCFriendListPermanentCellViewModel alloc] initWithTitle:RCLocalizedString(@"FriendApplicationNewFriend")
                                                                                                     portrait:[UIImage imageNamed:@"newFriend"] touchBlock:^(UIViewController * vc) {
        [weakSelf showFriendApplyWithController:vc];
    }];
    
    RCFriendListPermanentCellViewModel *myGroup = [[RCFriendListPermanentCellViewModel alloc] initWithTitle:RCLocalizedString(@"MyGroups")
                                                                                                     portrait:[UIImage imageNamed:@"myGroups"] touchBlock:^(UIViewController * vc) {
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
                                                                                                     portrait:[UIImage imageNamed:@"groupNotification"] touchBlock:^(UIViewController * vc) {
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

@end
