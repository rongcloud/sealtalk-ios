//
//  RCDMainTabBarViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMainTabBarViewController.h"
#import "RCDUltraGroupController.h"
#import "RCDChatListViewController.h"
#import "RCDContactViewController.h"
#import "RCDMeTableViewController.h"
#import "RCDSquareTableViewController.h"
#import "UITabBar+badge.h"
#import "RCDUtilities.h"
#import "RCDCommonDefine.h"
#import "RCTransationPersistModel.h"
#import "RCDNavigationViewController.h"
#import "RCUMainTabBarViewController.h"

extern NSString *const RCDDebugMessageEnableUserInfoEntrust;
static NSInteger RCD_MAIN_TAB_INDEX = 0;

@interface RCDMainTabBarViewController ()

@property NSUInteger previousIndex;

@property (nonatomic, strong) NSArray *tabTitleArr;

@property (nonatomic, strong) NSArray *imageArr;

@property (nonatomic, strong) NSArray *selectImageArr;

@property (nonatomic, strong) NSArray *animationImages;

@property (nonatomic, assign) BOOL ultraGroupEnable;
@end

@implementation RCDMainTabBarViewController

+ (id)mainTabBarViewController {
   bool ret = [[[NSUserDefaults standardUserDefaults] valueForKey:RCDDebugMessageEnableUserInfoEntrust] boolValue];
    if (ret) {
        [RCIM sharedRCIM].currentDataSourceType = RCDataSourceTypeInfoManagement;
        return [[RCUMainTabBarViewController alloc] init];
    } else {
        [RCIM sharedRCIM].currentDataSourceType = RCDataSourceTypeInfoProvider;
        return [[[self class] alloc] init];
    }
}

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
    [self rcdinitTabImages];
    [self setControllers];
    [self setTabBarItems];
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeSelectedIndex:)
                                                 name:@"ChangeTabBarIndex"
                                               object:nil];
    [self configureTranslationLanguange];
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
    [self setTabBarItems];
}
- (RCDNavigationViewController *)navigationControllerWithRootView:(UIViewController *)vc {
    RCDNavigationViewController *navi = [[RCDNavigationViewController alloc] initWithRootViewController:vc];
    return navi;
}

- (void)setControllers {
    RCDChatListViewController *chatVC = [[RCDChatListViewController alloc] init];
    RCDNavigationViewController *naviChatVC = [self navigationControllerWithRootView:chatVC];
    
    RCDContactViewController *contactVC = [[RCDContactViewController alloc] init];
    RCDNavigationViewController *naviContactVC = [self navigationControllerWithRootView:contactVC];
    
    RCDSquareTableViewController *discoveryVC = [[RCDSquareTableViewController alloc] init];
    RCDNavigationViewController *naviDiscoveryVC = [self navigationControllerWithRootView:discoveryVC];

    RCDMeTableViewController *meVC = [[RCDMeTableViewController alloc] init];
    RCDNavigationViewController *naviMeVC = [self navigationControllerWithRootView:meVC];

    
    if (self.ultraGroupEnable) {
        RCDUltraGroupController *ultraGroupVC = [[RCDUltraGroupController alloc] init];
        RCDNavigationViewController *naviUltraGroupVC = [self navigationControllerWithRootView:ultraGroupVC];

        self.viewControllers = @[naviChatVC, naviUltraGroupVC, naviContactVC, naviDiscoveryVC, naviMeVC ];
    } else {
        self.viewControllers = @[naviChatVC, naviContactVC, naviDiscoveryVC, naviMeVC ];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewControllers
        enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[RCDChatListViewController class]]) {
                RCDChatListViewController *chatListVC = (RCDChatListViewController *)obj;
                [chatListVC updateBadgeValueForTabBarItem];
            }
        }];
}

- (void)setTabBarItems {
    
    [self.viewControllers
        enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull objNavi, NSUInteger idx, BOOL *_Nonnull stop) {
        UIViewController *obj = nil;
        if([objNavi isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = (UINavigationController *)objNavi;
            obj = [navi.childViewControllers firstObject];
        }
            if ([obj isKindOfClass:[RCDChatListViewController class]] || [obj isKindOfClass:[RCDContactViewController class]] || [obj isKindOfClass:[RCDSquareTableViewController class]] || [obj isKindOfClass:[RCDMeTableViewController class]] || [obj isKindOfClass:[RCDUltraGroupController class]]) {
                objNavi.tabBarItem.title = self.tabTitleArr[idx];
                objNavi.tabBarItem.image =
                    [[UIImage imageNamed:self.imageArr[idx]]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                objNavi.tabBarItem.selectedImage =
                    [[UIImage imageNamed:self.selectImageArr[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else {
                NSLog(@"Unknown TabBarController");
            }
            [obj.tabBarController.tabBar bringBadgeToFrontOnItemIndex:(int)idx];
        }];
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

- (void)rcdinitTabImages{
    if(self.ultraGroupEnable) {
        self.tabTitleArr = @[RCDLocalizedString(@"Messages"),RCDLocalizedString(@"UltraGroup"), RCDLocalizedString(@"contacts"), RCDLocalizedString(@"chatroom"), RCDLocalizedString(@"me")];
        self.imageArr = @[@"chat_0",@"ultragroup_0",@"contact_0",@"square_0",@"me_0"];
        self.selectImageArr = @[@"chat_29",@"ultragroup_29",@"contact_29",@"square_29",@"me_29"];
    } else {
        self.tabTitleArr = @[RCDLocalizedString(@"Messages"), RCDLocalizedString(@"contacts"), RCDLocalizedString(@"chatroom"), RCDLocalizedString(@"me")];
        self.imageArr = @[@"chat_0",@"contact_0",@"square_0",@"me_0"];
        self.selectImageArr = @[@"chat_29",@"contact_29",@"square_29",@"me_29"];
    }
    NSMutableArray *ulTraGroupAnimationImages = @[].mutableCopy;
    NSMutableArray *chatAnimationImages = @[].mutableCopy;
    NSMutableArray *contactAnimationImages = @[].mutableCopy;
    NSMutableArray *squareAnimationImages = @[].mutableCopy;
    NSMutableArray *meAnimationImages = @[].mutableCopy;
    for (int i = 0; i < 30; i++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"ultragroup_%d",i]];
        if (img) {
            [ulTraGroupAnimationImages addObject:img];
        }
        img = [UIImage imageNamed:[NSString stringWithFormat:@"chat_%d",i]];
        if (img) {
            [chatAnimationImages addObject:img];
        }
        img = [UIImage imageNamed:[NSString stringWithFormat:@"contact_%d",i]];
        if (img) {
            [contactAnimationImages addObject:img];
        }
        img = [UIImage imageNamed:[NSString stringWithFormat:@"square_%d",i]];
        if (img) {
            [squareAnimationImages addObject:img];
        }
        img = [UIImage imageNamed:[NSString stringWithFormat:@"me_%d",i]];
        if (img) {
            [meAnimationImages addObject:img];
        }
        
    }
    if(self.ultraGroupEnable) {
        self.animationImages = @[chatAnimationImages.copy,ulTraGroupAnimationImages,contactAnimationImages,squareAnimationImages,meAnimationImages];
    } else {
        self.animationImages = @[chatAnimationImages.copy,contactAnimationImages,squareAnimationImages,meAnimationImages];
    }
}
@end
