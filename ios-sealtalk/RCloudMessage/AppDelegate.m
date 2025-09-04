//
//  AppDelegate.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "AppDelegate.h"
#import "RCDCommonDefine.h"
#import "RCDLoginViewController.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "RCDProxySettingControllerViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDTestMessage.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "RCDBuglyManager.h"
#import "RCDLoginManager.h"
#import "RCDCountry.h"
#import "RCDCommonString.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupManager.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDGroupNoticeUpdateMessage.h"
#import "RCDContactNotificationMessage.h"
#import "RCDChatNotificationMessage.h"
#import "RCDChatManager.h"
#import "RCDIMService.h"
#import "RCDPokeMessage.h"
#import "RCDPokeManager.h"
#import "RCDClearMessage.h"
#import "RCDLanguageManager.h"
#import <UMCommon/UMCommon.h>
#import <UMAPM/UMAPMConfig.h>
#import "RCDHTTPUtility.h"
#import "RCDUltraGroupNotificationMessage.h"
#import "RCUGroupNotificationMessage.h"
//#import <RongiFlyKit/RongiFlyKit.h>
#ifdef DEBUG
#import <DoraemonKit/DoraemonManager.h>
#endif
#define DORAEMON_APPID @""
#define BUGLY_APPID @""
#define LOG_EXPIRE_TIME -7 * 24 * 60 * 60

#define UMENG_APPKEY @""
#define IFLY_APPKEY @""

#import "RCDTranslationManager.h"

#if RCDTranslationEnable
#import <RongTranslation/Rongtranslation.h>
#endif

#import "RCTransationPersistModel.h"
#import "RCDEnvironmentContext.h"

#import "RCDFraudPreventionManager.h"
#import "RCDAlertBuilder.h"
#import "RCDSemanticContext.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCUViewModelManager.h"

extern NSString *const RCDDebugMessageEnableUserInfoEntrust;

#if RCDTranslationEnable
@interface AppDelegate () <RCTranslationClientDelegate, RCUltraGroupConversationDelegate>
#else
@interface AppDelegate () <RCUltraGroupConversationDelegate>
#endif

@property (nonatomic, assign) BOOL allowAutorotate;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self configUMCommon];
   
    [self configSealTalkWithApp:application andOptions:launchOptions];
    [self configDoraemon];
    [self configureIMAndEnterHomeIfNeed];
    return YES;
}

- (void)configureIMAndEnterHomeIfNeed {
    NSString *userId = [DEFAULTS objectForKey:RCDUserIdKey];
    NSString *token = [DEFAULTS objectForKey:RCDIMTokenKey];
    
    if (userId && token) {
        [self configRongIM];
        [self loginAndEnterMainPage];
    } else {
        [self loginAndEnterMainPage];
    }
}

- (void)resetKitDataSourceType {
    bool ret = [[[NSUserDefaults standardUserDefaults] valueForKey:RCDDebugMessageEnableUserInfoEntrust] boolValue];
    if (ret) {
        [RCIM sharedRCIM].currentDataSourceType = RCDataSourceTypeInfoManagement;
    } else {
        [RCIM sharedRCIM].currentDataSourceType = RCDataSourceTypeInfoProvider;
    }
}

- (void)configRongIM {
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"layoutDirection"];
    RCKitConfigCenter.ui.layoutDirection = [value integerValue];
    
    // 每次启动都检测本地是否有代理配置缓存
    RCIMProxy *improxy = [RCDProxySettingControllerViewController currentAPPSettingIMProxy];
    // improxy 为nil，取消代理
    BOOL success = [[RCCoreClient sharedCoreClient] setProxy:improxy];
    if (success) {
        RCRTCConfig *config = [[RCRTCConfig alloc] init];
        RCRTCProxy *rtcproxy = [RCDProxySettingControllerViewController currentAPPSettingRTCProxy];
        config.proxy = rtcproxy;
        [[RCRTCEngine sharedInstance] initWithConfig:config];
        
        // setProxy 的地方，也要及时更新全局配置 SDWebImage， 允许使用代理模式加载图片
        [RCDHTTPUtility configProxySDWebImage];
    }

    RCInitOption *initOption = [[RCInitOption alloc] init];
    BOOL disable_crash_monitor = [[[NSUserDefaults standardUserDefaults] valueForKey:RCDDebugDISABLE_CRASH_MONITOR] boolValue];
    if (disable_crash_monitor) {
        initOption.crashMonitorEnable = NO;
    }
    initOption.naviServer = [RCDEnvironmentContext navServer];
    initOption.fileServer = [RCDEnvironmentContext fileServer];
    initOption.statisticServer = [RCDEnvironmentContext statsServer];
    NSString *appKey = [RCDEnvironmentContext appKey];
    [[RCIM sharedRCIM] initWithAppKey:appKey option:initOption];
    
    // 设置appVersion
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [[RCCoreClient sharedCoreClient] setAppVer:app_Version];
    //[RCiFlyKit setiFlyAppkey:IFLY_APPKEY];
    
    //关闭消息排重
    [self disableCheckDupMessageIfNeed];
    
    //开启 enableMessageAttachUserInfo
    [self enableMessageAttachUserInfoIfNeed];
    
    [DEFAULTS setObject:appKey forKey:RCDAppKeyKey];
    
    [self resetKitDataSourceType];

    // 注册自定义测试消息
    [[RCIM sharedRCIM] registerMessageType:[RCDTestMessage class]];
    if ([RCIM sharedRCIM].currentDataSourceType == RCDataSourceTypeInfoManagement) {
        [[RCIM sharedRCIM] registerMessageType:[RCUGroupNotificationMessage class]];
    } else {
        [[RCIM sharedRCIM] registerMessageType:[RCDGroupNotificationMessage class]];
    }
    [[RCIM sharedRCIM] registerMessageType:[RCDGroupNoticeUpdateMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDContactNotificationMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDChatNotificationMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDPokeMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDClearMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDUltraGroupNotificationMessage class]];

    // 默认为高清语音
    BOOL enableNormalVoiceMessage = [[DEFAULTS valueForKey:RCDDebugEnableNormalVoiceMessage] boolValue];
    [RCIMClient sharedRCIMClient].voiceMsgType = enableNormalVoiceMessage ? RCVoiceMessageTypeOrdinary : RCVoiceMessageTypeHighQuality;
    
    [RCCoreClient sharedCoreClient].logLevel = RC_Log_Level_Info;
    // 超级群会话同步状态监听代理 要在初始化之后, 连接之前设置
    [[RCChannelClient sharedChannelManager] setUltraGroupConversationDelegate:self];
    //设置会话列表头像和会话页面头像
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;
    [RCIM sharedRCIM].groupUserInfoDataSource = RCDDataSource;
    [RCIM sharedRCIM].groupInfoDataSource = RCDDataSource;
    [RCIM sharedRCIM].groupMemberDataSource = RCDDataSource;
    [RCContactCardKit shareInstance].contactsDataSource = RCDDataSource;
    [RCContactCardKit shareInstance].groupDataSource = RCDDataSource;
    RCKitConfigCenter.message.enableTypingStatus = YES;
    RCKitConfigCenter.message.enableSyncReadStatus = YES;
    RCKitConfigCenter.message.showUnkownMessage = YES;
    RCKitConfigCenter.message.showUnkownMessageNotificaiton = YES;
    RCKitConfigCenter.message.enableMessageMentioned = YES;
    RCKitConfigCenter.message.enableMessageRecall = YES;
    RCKitConfigCenter.message.isMediaSelectorContainVideo = YES;
    RCKitConfigCenter.message.enableSendCombineMessage = YES;
    RCKitConfigCenter.message.reeditDuration = 60;
    RCKitConfigCenter.message.enableEditMessage = ![DEFAULTS boolForKey:RCDDebugDisableEditMessageKey];
    // 配置已编辑文字的颜色
    // RCKitConfigCenter.message.editedTextColor = RCDYCOLOR(0x4679FF, 0x4679FF);

    RCKitConfigCenter.ui.enableDarkMode = YES;
    RCKitConfigCenter.ui.globalConversationPortraitSize = CGSizeMake(48, 48);
    RCKitConfigCenter.ui.globalNavigationBarTintColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0x111f2c) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]];
    //  设置头像为圆形
    RCKitConfigCenter.ui.globalMessageAvatarStyle = RC_USER_AVATAR_CYCLE;
    RCKitConfigCenter.ui.globalConversationAvatarStyle = RC_USER_AVATAR_CYCLE;
    
    [RCUViewModelManager registerViewModel];
    
    //   设置优先使用WebView打开URL
    //  [RCIM sharedRCIM].embeddedWebViewPreferred = YES;
    [[RCCoreClient sharedCoreClient] configApplicationGroupIdentifier:RCDNotificationServiceGroup isMainApp:YES];
    
    [RCIM sharedRCIM].messageInterceptor = self;
}

#pragma mark - RCUltraGroupConversationDelegate

- (BOOL)isUltraGroupObserved {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *val = [userDefaults valueForKey:@"RCDDebugUtralGroupSyncKey"];
    return [val boolValue];
}

- (void)ultraGroupConversationListDidSync {
    if (![self isUltraGroupObserved]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       NSLog(@"%@", @" (2s前)收到 -> 2.2.1 拉取超级群列表后回调");
        [self showAlert:RCDLocalizedString(@"alert")
                   message:@"UltraGroup ConversationList Did Sync"
            cancelBtnTitle:RCDLocalizedString(@"i_know")];
    });
   
}
- (void)configDoraemon {
    #ifdef DEBUG
    [[DoraemonManager shareInstance] installWithPid:DORAEMON_APPID];
    #endif
}

- (void)configUMCommon {
    [UMAPMConfig defaultConfig].crashAndBlockMonitorEnable = NO;
    [UMConfigure initWithAppkey:UMENG_APPKEY channel:nil];
}

- (void)configSealTalkWithApp:(UIApplication *)application andOptions:(NSDictionary *)launchOptions {
    [self saveCountryInfoIfNeed];
#ifndef DEBUG
    [self redirectNSlogToDocumentFolder];
#endif
    application.statusBarHidden = NO;
    if (BUGLY_APPID.length > 0) {
        [RCDBuglyManager startWithAppId:BUGLY_APPID];
    }
    [self setNavigationBarAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:RCKitDispatchMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoginCookieExpiredNotification:)
                                                 name:RCDLoginCookieExpiredNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didViewChangeAutorotate:)
                                                 name:RCKitViewSupportAutorotateNotification
                                               object:nil];

    /**
     * 推送处理 1
     */
    [self registerRemoteNotification:application];

    /**
     * 统计推送，并获取融云推送服务扩展字段
     */
    [self recordLaunchOptions:launchOptions];
}

- (void)didViewChangeAutorotate:(NSNotification *)noti{
    self.allowAutorotate = [noti.object boolValue];
    //强制归正：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)loginAndEnterMainPage {
    NSString *token = [DEFAULTS objectForKey:RCDIMTokenKey];
    NSString *userId = [DEFAULTS objectForKey:RCDUserIdKey];
    NSString *userNickName = [DEFAULTS objectForKey:RCDUserNickNameKey];
    NSString *userPortraitUri = [DEFAULTS objectForKey:RCDUserPortraitUriKey];
    NSString *phone = [DEFAULTS objectForKey:RCDPhoneKey] ;
    RCDCountry *currentCountry = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];
    NSString *regionCode = @"86";
    
#if RCDTranslationEnable
    [[RCTranslationClient sharedInstance] addTranslationDelegate:self];
#endif
    
    if (currentCountry.phoneCode.length > 0) {
        regionCode = currentCountry.phoneCode;
    }
    if (token.length && userId.length) {
        [RCDLoginManager openDB:userId];
        RCDMainTabBarViewController *mainTabBarVC = [RCDMainTabBarViewController mainTabBarViewController];
        self.window.rootViewController = mainTabBarVC;

        RCUserInfo *_currentUserInfo =
            [[RCUserInfo alloc] initWithUserId:userId name:userNickName portrait:userPortraitUri];
        [RCIM sharedRCIM].currentUserInfo = _currentUserInfo;
        // 请求翻译token
        [self requestTranslationTokenBy:userId];
        
        [self insertSharedMessageIfNeed];
        [[RCDIMService sharedService] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
            NSLog(@"RCDBOpened %@", code ? @"failed" : @"success");
        }success:^(NSString *userId) {
            [self requestFraudPreventionRejectWithPhone:phone withRegion:regionCode] ;
            [mainTabBarVC updateBadgeValueForTabBarItem];
        }error:^(RCConnectErrorCode status) {
            NSLog(@"connectWithToken error: %@", @(status));
            if (status == RC_CONN_TOKEN_INCORRECT) {
                [self gotoLoginViewAndDisplayReasonInfo:@"无法连接到服务器"];
                NSLog(@"Token无效");
            } else if (status == RC_CONN_USER_BLOCKED) {
                [self fraudPreventionByUserBlocked] ;
            } else {
                NSString *reason = [NSString stringWithFormat:@"连接失败 %@", @(status)];
                [self gotoLoginViewAndDisplayReasonInfo:reason];
            }
        }];
    } else {
        RCDLoginViewController *vc = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:vc];
        self.window.rootViewController = _navi;
    }
}

/* 验证账号在当前设备上登录的风险等级 */
- (void)requestFraudPreventionRejectWithPhone:(NSString *)phone withRegion:(NSString *)region {
    __weak typeof(self) weakSelf = self;
    [[RCDFraudPreventionManager sharedInstance] reqestFrandPreventionRiskLevelREJECTWithPhone:phone withRegion:region complate:^(BOOL reject) {
        if (reject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf logoutWithFraudPrevention] ;
                [RCDAlertBuilder showFraudPreventionRejectAlert];
            }) ;
        } else {
            [RCDDataSource syncAllData];
        }
    }];
}

// 用户被封禁时处理
- (void)fraudPreventionByUserBlocked {
    [[RCIM sharedRCIM] logout];
    [DEFAULTS removeObjectForKey:RCDIMTokenKey];
    [DEFAULTS synchronize];
    __weak typeof(self) weakSelf = self;
    rcd_dispatch_main_async_safe(^{
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        weakSelf.window.rootViewController = _navi;
        [RCDAlertBuilder showFraudPreventionRejectAlert];
    });
}

//退出登录
- (void)logoutWithFraudPrevention{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [DEFAULTS removeObjectForKey:RCDIMTokenKey];
    [DEFAULTS synchronize];

    [RCDLoginManager logout:^(BOOL success){
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = navi;
    });
    [[RCIM sharedRCIM] logout];

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:MCShareExtensionKey];
    [userDefaults removeObjectForKey:RCDCookieKey];
    [userDefaults synchronize];
}
    
/// 请求翻译 sdk token
/// @param userID 用户ID
- (void)requestTranslationTokenBy:(NSString *)userID {
#if RCDTranslationEnable
    [RCDTranslationManager requestTranslationTokenUserID:userID
                                                 success:^(NSString * _Nonnull token) {
        [[RCTranslationClient sharedInstance] updateAuthToken:token];
        }
                                                 failure:^(NSInteger code) {
            
        }];
#endif
}

- (void)configCurrentLanguage {
    //设置当前语言
    NSString *language = [DEFAULTS valueForKey:@"RCDUserLanguageKey"];

    // App 内切换语言时需要设置布局，不重启有部分视图有问题
    if ([language isEqualToString:@"ar"]) {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    } else {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
}

/**
 * 推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    /*
     设置 deviceToken（已兼容 iOS 13），推荐使用，需升级 SDK 版本至 2.9.25
     不需要开发者对 deviceToken 进行处理，可直接传入。
     */
    [[RCCoreClient sharedCoreClient] setDeviceTokenData:deviceToken];

    [RCDNotificationServiceDefaults setValue:deviceToken forKey:RCDDeviceTokenKey];
}

// 推送处理 3（如不升级 SDK，需要按照下面代码进行处理）
/*
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSString *token = [self getHexStringForData:deviceToken];
    [[RCCoreClient sharedCoreClient] setDeviceToken:token];
}

// Data 转换成 NSString（NSData ——> NSString）
- (NSString *)getHexStringForData:(NSData *)data {
    NSUInteger len = [data length];
    char *chars = (char *)[data bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i ++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    }
    return hexString;
}
*/

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if TARGET_IPHONE_SIMULATOR
// 模拟器不能使用远程推送
#else
    // 请检查App的APNs的权限设置，更多内容可以参考文档
    // http://www.rongcloud.cn/docs/ios_push.html
    NSLog(@"获取DeviceToken失败！！！");
    NSLog(@"ERROR：%@", error);
#endif
}

/**
 * 推送处理4
 * userInfo内容请参考官网文档
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    /**
     * 统计推送打开率2
     */
    [[RCCoreClient sharedCoreClient] recordRemoteNotificationEvent:userInfo];
    /**
     * 获取融云推送服务扩展字段2
     */
    NSDictionary *pushServiceData = [[RCCoreClient sharedCoreClient] getPushExtraFromRemoteNotification:userInfo];
    if (pushServiceData) {
        NSLog(@"该远程推送包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"key = %@, value = %@", key, pushServiceData[key]);
        }
    } else {
        NSLog(@"该远程推送不包含来自融云的推送服务");
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    /**
     * 统计推送打开率3
     */
    [[RCCoreClient sharedCoreClient] recordLocalNotificationEvent:notification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    RCConnectionStatus status = [[RCCoreClient sharedCoreClient] getConnectionStatus];
    if (status != ConnectionStatus_SignOut) {
        int unreadMsgCount = [RCDUtilities getTotalUnreadCount];
        application.applicationIconBadgeNumber = unreadMsgCount;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 登陆状态下为消息分享保存会话信息
    if ([RCCoreClient sharedCoreClient].getConnectionStatus == ConnectionStatus_Connected) {
        [self saveConversationInfoForMessageShare];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([[RCCoreClient sharedCoreClient] getConnectionStatus] == ConnectionStatus_Connected) {
        // 插入分享消息
        [self insertSharedMessageIfNeed];
    }
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    NSNumber *left = [notification.userInfo objectForKey:@"left"];
    if ([RCCoreClient sharedCoreClient].sdkRunningMode == RCSDKRunningMode_Background && 0 == left.integerValue) {
        int unreadMsgCount = [RCDUtilities getTotalUnreadCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadMsgCount;
        });
    }
}

- (void)didLoginCookieExpiredNotification:(NSNotification *)notification{
    [self gotoLoginViewAndDisplayReasonInfo:@"未登录或登录凭证失效"];
}

#pragma mark - RCIMConnectionStatusDelegate

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        [self showAlert:RCDLocalizedString(@"alert")
                   message:RCDLocalizedString(@"accout_kicked")
            cancelBtnTitle:RCDLocalizedString(@"i_know")];
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = _navi;
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        [RCDLoginManager getToken:^(BOOL success, NSString *_Nonnull token, NSString *_Nonnull userId) {
            if (success) {
                [[RCDIMService sharedService] connectWithToken:token
                    dbOpened:^(RCDBErrorCode code) {
                        NSLog(@"RCDBOpened %@", code ? @"failed" : @"success");
                    }
                    success:^(NSString *userId) {

                    }
                    error:^(RCConnectErrorCode status){

                    }];
            }
        }];
    } else if (status == ConnectionStatus_DISCONN_EXCEPTION) {
        /* 原本处理
        [self showAlert:RCDLocalizedString(@"alert")
                   message:RCDLocalizedString(@"Your_account_has_been_banned")
            cancelBtnTitle:RCDLocalizedString(@"i_know")];
        */
        
        [[RCCoreClient sharedCoreClient] disconnect];
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = _navi;
        // 添加逻辑，退出登录
        [self fraudPreventionByUserBlocked] ;
        // 修改后提示框提示
        [RCDAlertBuilder showFraudPreventionRejectAlert] ;
    } else if (status == ConnectionStatus_USER_ABANDON) {
        [self showAlert:RCDLocalizedString(@"alert")
                   message:RCDLocalizedString(@"Your_account_has_been_logout")
            cancelBtnTitle:RCDLocalizedString(@"i_know")];
        [[RCCoreClient sharedCoreClient] disconnect];
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = _navi;
    }
}

- (BOOL)onRCIMCustomLocalNotification:(RCMessage *)message withSenderName:(NSString *)senderName {
    //群组通知不弹本地通知
    if ([message.content isKindOfClass:[RCGroupNotificationMessage class]]) {
        return YES;
    }
    return NO;
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    if (![RCDGroupManager isHoldGroupNotificationMessage:message] &&
        ![RCDChatManager isHoldChatNotificationMessage:message] &&
        ![[RCDPokeManager sharedInstance] isHoldReceivePokeManager:message]) {
        if ([message.content isMemberOfClass:[RCInformationNotificationMessage class]]) {
            RCInformationNotificationMessage *msg = (RCInformationNotificationMessage *)message.content;
            // NSString *str = [NSString stringWithFormat:@"%@",msg.message];
            if ([msg.message rangeOfString:@"你已添加了"].location != NSNotFound) {
                [RCDDataSource syncFriendList];
            }
        } else if ([message.content isMemberOfClass:[RCDContactNotificationMessage class]] ||
                   [message.content isMemberOfClass:[RCContactNotificationMessage class]]) {
            [RCDDataSource syncFriendList];
        }
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    if ([[RCIM sharedRCIM] openExtensionModuleUrl:url]) {
        return YES;
    } else if ([url.absoluteString containsString:@"sealtalk:"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RCDOpenQRCodeUrlNotification object:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([[RCIM sharedRCIM] openExtensionModuleUrl:url]) {
        return YES;
    }
    return YES;
}

- (BOOL)onRCIMCustomAlertSound:(RCMessage *)message {
    //设置群组通知消息没有提示音
    //    if ([message.content isMemberOfClass:[RCGroupNotificationMessage class]]) {
    //        return YES;
    //    }
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchMessageNotification object:nil];
}

- (void)gotoLoginViewAndDisplayReasonInfo:(NSString *)reason {
    [[RCIM sharedRCIM] logout];
    [DEFAULTS removeObjectForKey:RCDIMTokenKey];
    [RCDNotificationServiceDefaults removeObjectForKey:RCDIMTokenKey];
    [DEFAULTS synchronize];
    __weak typeof(self) weakSelf = self;
    rcd_dispatch_main_async_safe(^{
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        weakSelf.window.rootViewController = _navi;
        [weakSelf showAlert:nil message:reason cancelBtnTitle:RCDLocalizedString(@"confirm")];
    });
}
#pragma mark - ShareExtension
//插入分享消息
- (void)insertSharedMessageIfNeed {
    NSUserDefaults *shareUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:MCShareExtensionKey];

    NSArray *sharedMessages = [shareUserDefaults valueForKey:@"sharedMessages"];
    if (sharedMessages.count > 0) {
        for (NSDictionary *sharedInfo in sharedMessages) {
            RCRichContentMessage *richMsg = [[RCRichContentMessage alloc] init];
            richMsg.title = [sharedInfo objectForKey:@"title"];
            richMsg.digest = [sharedInfo objectForKey:@"content"];
            richMsg.url = [sharedInfo objectForKey:@"url"];
            richMsg.imageURL = [sharedInfo objectForKey:@"imageURL"];
            richMsg.extra = [sharedInfo objectForKey:@"extra"];
            RCMessage *message = [[RCCoreClient sharedCoreClient]
                insertOutgoingMessage:[[sharedInfo objectForKey:@"conversationType"] intValue]
                             targetId:[sharedInfo objectForKey:@"targetId"]
                           sentStatus:SentStatus_SENT
                              content:richMsg];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCDSharedMessageInsertSuccess" object:message];
        }
        [shareUserDefaults removeObjectForKey:@"sharedMessages"];
        [shareUserDefaults synchronize];
    }
}

//为消息分享保存会话信息
- (void)saveConversationInfoForMessageShare {
    NSArray *conversationList =
        [[RCCoreClient sharedCoreClient] getConversationList:@[ @(ConversationType_PRIVATE), @(ConversationType_GROUP) ]];

    NSMutableArray *conversationInfoList = [[NSMutableArray alloc] init];
    if (conversationList.count > 0) {
        for (RCConversation *conversation in conversationList) {
            NSMutableDictionary *conversationInfo = [NSMutableDictionary dictionary];
            [conversationInfo setValue:conversation.targetId forKey:@"targetId"];
            [conversationInfo setValue:@(conversation.conversationType) forKey:@"conversationType"];
            if (conversation.conversationType == ConversationType_PRIVATE) {
                RCUserInfo *user = [RCDUserInfoManager getUserInfo:conversation.targetId];
                [conversationInfo setValue:user.name forKey:@"name"];
                [conversationInfo setValue:user.portraitUri forKey:@"portraitUri"];
            } else if (conversation.conversationType == ConversationType_GROUP) {
                RCGroup *group = [[RCIM sharedRCIM] getGroupInfoCache:conversation.targetId];
                [conversationInfo setValue:group.groupName forKey:@"name"];
                [conversationInfo setValue:group.portraitUri forKey:@"portraitUri"];
            }
            [conversationInfoList addObject:conversationInfo];
        }
    }
    NSURL *sharedURL = [[NSFileManager defaultManager]
        containerURLForSecurityApplicationGroupIdentifier:MCShareExtensionKey];
    NSURL *fileURL = [sharedURL URLByAppendingPathComponent:@"rongcloudShare.plist"];
    [conversationInfoList writeToURL:fileURL atomically:YES];

    NSUserDefaults *shareUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:MCShareExtensionKey];
    [shareUserDefaults setValue:[RCIM sharedRCIM].currentUserInfo.userId forKey:@"currentUserId"];
    [shareUserDefaults setValue:[DEFAULTS objectForKey:RCDUserCookiesKey] forKey:RCDCookieKey];
    [shareUserDefaults synchronize];
}

#pragma mark - RCWKAppInfoProvider
- (NSString *)getAppName {
    return @"融云";
}

- (NSString *)getAppGroups {
    return @"group.cn.rongcloud.rcim.WKShare";
}

- (NSArray *)getAllGroupInfo {
    return [RCDGroupManager getMyGroupList];
}

- (NSArray *)getAllFriends {
    return [RCDUserInfoManager getAllFriends];
}

- (void)openParentApp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"rongcloud://connect"]];
}

- (BOOL)getNewMessageNotificationSound {
    return !RCKitConfigCenter.message.disableMessageAlertSound;
}

- (void)setNewMessageNotificationSound:(BOOL)on {
    RCKitConfigCenter.message.disableMessageAlertSound = !on;
}

- (BOOL)getLoginStatus {
    NSString *token = [DEFAULTS stringForKey:RCDIMTokenKey];
    if (token.length) {
        return YES;
    } else {
        return NO;
    }
}

- (void)logout {
}

#pragma mark - private method
- (void)registerRemoteNotification:(UIApplication *)application {
    /**
     *  推送说明：
     *
     我们在知识库里还有推送调试页面加了很多说明，当遇到推送问题时可以去知识库里搜索还有查看推送测试页面的说明。
     *
     首先必须设置deviceToken，可以搜索本文件关键字“推送处理”。模拟器是无法获取devicetoken，也就没有推送功能。
     *
     当使用"开发／测试环境"的appkey测试推送时，必须用Development的证书打包，并且在后台上传"开发／测试环境"的推送证书，证书必须是development的。
     当使用"生产／线上环境"的appkey测试推送时，必须用Distribution的证书打包，并且在后台上传"生产／线上环境"的推送证书，证书必须是distribution的。
     */
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
            settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                  categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        //注册推送，用于iOS8之前的系统
        UIRemoteNotificationType myTypes =
            UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
}

- (void)recordLaunchOptions:(NSDictionary *)launchOptions {
    /**
     * 统计推送打开率1
     */
    [[RCCoreClient sharedCoreClient] recordLaunchOptionsEvent:launchOptions];
    /**
     * 获取融云推送服务扩展字段1
     */
    NSDictionary *pushServiceData = [[RCCoreClient sharedCoreClient] getPushExtraFromLaunchOptions:launchOptions];
    if (pushServiceData) {
        NSLog(@"该启动事件包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"%@", pushServiceData[key]);
        }
    } else {
        NSLog(@"该启动事件不包含来自融云的推送服务");
    }
    //打印原始的远程推送内容
    NSDictionary *remoteNotificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationUserInfo) {
        NSLog(@"远程推送原始内容为 %@", remoteNotificationUserInfo);
    }
}

- (void)saveCountryInfoIfNeed {
    NSDictionary *dic = [DEFAULTS objectForKey:RCDCurrentCountryKey];
    RCDCountry *currentCountry;
    if (!dic) {
        currentCountry = [[RCDCountry alloc] initWithDict:@{
            @"region" : @"86",
            @"locale" : @{@"en" : @"China", @"zh" : @"中国"}
        }];
        [DEFAULTS setObject:[currentCountry getModelJson] forKey:RCDCurrentCountryKey];
    }
}

- (void)setNavigationBarAppearance {
    //统一导航条样式
    UIFont *font = [UIFont boldSystemFontOfSize:[RCKitConfig defaultConfig].font.firstLevel];
    NSDictionary *textAttributes =
        @{NSFontAttributeName : font, NSForegroundColorAttributeName : RCDDYCOLOR(0x111f2c, 0xffffff)};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x111f2c) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]]];
    [[UINavigationBar appearance] setBarTintColor:RCDDYCOLOR(0xffffff, 0x191919)];
    UIImage *tmpImage = [UIImage imageNamed:@"navigator_btn_back"];
    tmpImage = [RCDSemanticContext imageflippedForRTL:tmpImage];
    [[UINavigationBar appearance] setBackIndicatorImage:tmpImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:tmpImage];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-2, -0.5)  forBarMetrics:UIBarMetricsDefault];
    if (IOS_FSystenVersion >= 8.0) {
        [UINavigationBar appearance].translucent = NO;
    }
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
        barApp.backgroundColor = RCDDYCOLOR(0xffffff, 0x191919);
        barApp.backgroundEffect = nil;// 去掉半透明效果
        barApp.shadowColor = [UIColor clearColor];
        [UINavigationBar appearance].scrollEdgeAppearance = barApp;
        [UINavigationBar appearance].standardAppearance = barApp;
    }
}

//重定向 log 到本地文件
//在 info.plist 中打开 Application supports iTunes file sharing
- (void)redirectNSlogToDocumentFolder {
    NSLog(@"Log重定向到本地，如果您需要控制台Log，注释掉重定向逻辑即可。");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    [self removeExpireLogFiles:documentDirectory];

    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MMddHHmmss"];
    NSString *formattedDate = [dateformatter stringFromDate:currentDate];

    NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];

    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (void)removeExpireLogFiles:(NSString *)logPath {
    //删除超过时间的log文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:logPath error:nil]];
    NSDate *currentDate = [NSDate date];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSinceNow:LOG_EXPIRE_TIME];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *fileComp = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |
                          NSMinuteCalendarUnit | NSSecondCalendarUnit;
    fileComp = [calendar components:unitFlags fromDate:currentDate];
    for (NSString *fileName in fileList) {
        // rcMMddHHmmss.log length is 16
        if (fileName.length != 16) {
            continue;
        }
        if (![[fileName substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"rc"]) {
            continue;
        }
        int month = [[fileName substringWithRange:NSMakeRange(2, 2)] intValue];
        int date = [[fileName substringWithRange:NSMakeRange(4, 2)] intValue];
        if (month > 0) {
            [fileComp setMonth:month];
        } else {
            continue;
        }
        if (date > 0) {
            [fileComp setDay:date];
        } else {
            continue;
        }
        NSDate *fileDate = [calendar dateFromComponents:fileComp];

        if ([fileDate compare:currentDate] == NSOrderedDescending ||
            [fileDate compare:expireDate] == NSOrderedAscending) {
            [fileManager removeItemAtPath:[logPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

- (void)showAlert:(NSString *)title message:(NSString *)msg cancelBtnTitle:(NSString *)cBtnTitle {
    [RCAlertView showAlertController:title message:msg cancelTitle:cBtnTitle];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if(self.allowAutorotate){
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)disableCheckDupMessageIfNeed {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugDisableCheckDupMessage] boolValue];
    if (enable) {
        [[RCCoreClient sharedCoreClient] setCheckDuplicateMessage:!enable];
    }
    NSLog(@"SealTalk setCheckDuplicateMessage %@", @(!enable));
    
    enable = [[userDefault valueForKey:RCDDebugDisableCheckChatroomDupMessage] boolValue];
    if (enable) {
        [[RCChatRoomClient sharedChatRoomClient] setCheckChatRoomDuplicateMessage:!enable];
    }
    NSLog(@"SealTalk setCheckChatRoomDuplicateMessage %@", @(!enable));
}

- (void)enableMessageAttachUserInfoIfNeed {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugEnableMessageAttachUserInfoKey] boolValue];
    [RCIM sharedRCIM].enableMessageAttachUserInfo = enable;
    NSLog(@"SealTalk enableMessageAttachUserInfoIfNeed %@", @(enable));
}

#pragma mark - RCTranslationClientDelegate
#if RCDTranslationEnable
/// 翻译结束
/// @param translation model
/// @param code 返回码
- (void)onTranslation:(RCTranslation *)translation
         finishedWith:(RCTranslationCode)code {
    if (code == RCTranslationCodeAuthFailed
        || code == RCTranslationCodeServerAuthFailed
        || code == RCTranslationCodeInvalidAuthToken) {
        [self requestTranslationTokenBy:[RCIM sharedRCIM].currentUserInfo.userId];
    }
}
#endif

#pragma mark -- RCIMMessageInterceptor

- (BOOL)interceptWillSendMessage:(RCMessage *)message {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL openIntercept = [[userDefault valueForKey:RCDDebugInterceptWillSendCombineFuntion] boolValue];
    if (!openIntercept) {
        return NO;
    }

    if ([message.content isKindOfClass:[RCCombineMessage class]]) {
        // 只拦截合并转发消息
        [[RCIM sharedRCIM] sendMediaMessage:message pushContent:nil pushData:nil uploadPrepare:^(RCUploadMediaStatusListener *uploadListener) {

            RCCombineMessage *msgContent = (RCCombineMessage *)uploadListener.currentMessage.content;
            msgContent.remoteUrl = @"https://html-aws-or.ronghub.com/VA5SSVUES1xcVVsAXXJheU1hfVtORggOAAQBDQAPCTc3OTg=.html";
            uploadListener.successBlock(msgContent);

        } progress:nil successBlock:nil errorBlock:nil cancel:nil];
        return YES;
    }
    else if ([message.content isKindOfClass:[RCImageMessage class]]) {
        // 只拦截合并转发消息
//        [[RCIM sharedRCIM] sendMediaMessage:message pushContent:nil pushData:nil uploadPrepare:^(RCUploadMediaStatusListener *uploadListener) {
//
//            RCImageMessage *msgContent = (RCImageMessage *)uploadListener.currentMessage.content;
//            msgContent.remoteUrl = @"http://image-aws-or.ronghub.com/VAtfRFUBRlFcUFYNXXdsdE1kcFZOQwUDAAENBwUBAjcyNDU=.jpg";
//            uploadListener.successBlock(msgContent);
//
//        } progress:nil successBlock:nil errorBlock:nil cancel:nil];
//        return YES;
        
        
        // 拦截更换一下内容, 会继续使用SDK进行发送
        RCImageMessage *msgContent = (RCImageMessage *)message.content;
        msgContent.remoteUrl = @"http://image-aws-or.ronghub.com/VAtfRFUBRlFcUFYNXXdsdE1kcFZOQwUDAAENBwUBAjcyNDU=.jpg";
        return NO;
    }
    
    else if ([message.content isKindOfClass:[RCTextMessage class]]) {
        // 不拦截继续使用SDK 方法发送，只更新文本消息内容
        RCTextMessage *msgContent = (RCTextMessage *)message.content;
        msgContent.content = @"拦截并替换了，SDK发送";
        return NO;
    }
    
    
    return NO;
}

- (void)interceptDidSendMessage:(RCMessage *)message {
    NSString *statusStr = (SentStatus_SENT == message.sentStatus ? @"完成" : @"失败");
    DebugLog(@"interceptDidSendMessage 发送%@", statusStr);
}

@end
