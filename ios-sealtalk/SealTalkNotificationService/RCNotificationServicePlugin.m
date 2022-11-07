//
//  RCNotificationServicePlugin.m
//  SealTalkNotificationService
//
//  Created by Qi on 2022/3/31.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCNotificationServicePlugin.h"
#import <MMWormhole/MMWormhole.h>
#import "RCCoreClient+DBPath.h"

dispatch_queue_t rcd_im_pushext_queue = NULL;

@interface RCNotificationServicePlugin ()<RCIMClientReceiveMessageDelegate,UNUserNotificationCenterDelegate>
@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, copy) NSString *appGroupIdentifier;
@property (nonatomic, strong) UNMutableNotificationContent *firstNotificationContent;
@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);

//远程推送的消息 UID
@property (nonatomic, copy) NSString *pushMsgUid;

@property (nonatomic, assign) NSUInteger currentBadge;
@property (nonatomic, assign) long long pushMessageSentTime;
@end

@implementation RCNotificationServicePlugin
+ (instancetype)sharedInstance {
    static RCNotificationServicePlugin *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        rcd_im_pushext_queue = dispatch_queue_create("com.rcpushext.queue", NULL);
    });
    return instance;
}
- (void)configApplicationGroupIdentifier:(NSString *)identifier {
    self.appGroupIdentifier = identifier;
    self.currentBadge = 0;
    [self addWormholeListener];
}

//NotificationService didReceiveNotificationRequest 方法非线程安全，此处需要做线程保护
- (void)connectIMWithNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler{
    if (!self.appGroupIdentifier) {
        NSLog(@"[RCNotificationServicePlugin Error] call configApplicationGroupIdentifier first");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(rcd_im_pushext_queue, ^{
        
        self.firstNotificationContent = [request.content mutableCopy];
        self.pushMsgUid = [self getMessageUidWithContent:request.content];
        self.contentHandler = contentHandler;
        long long time = [self getPushMessageSentTime:request.content];
        if (![self shouldConnectWith:time]) {
            return;
        }

        //更新数据库路径到 NotificationService 共享路径
        [weakSelf updateSDKMsgDB];
        
        // 更新RCConnectionService 发起connect时  用到的pull_msg_end_time_ 时间(拉取消息的截止时间)
        [weakSelf updateMessageSentTime:time];
        
        //初始化 IM SDK
        [weakSelf initIMSDK];
        
        //更新 DeviceToken
        [weakSelf updateDeviceToken];
        
        //连接 IM
        [weakSelf connectIM];

    });
}

#pragma mark - util
/// 更新消息发送时间
/// @param time   当前收到的消息时间
- (void)updateMessageSentTime:(long long)time {
    NSLog(@"[RCPush] PushMessageSentTime: %lld ", time);
    [[RCCoreClient sharedCoreClient] updatePushMessageSentTime:time];
}

- (void)updateSDKMsgDB {
    NSString *path = [self p_pushExtMsgDBPath];
    if (path.length > 0) {
        [[RCCoreClient sharedCoreClient] updateMessageDBPath:path withAppBundleId:[self p_getAppBundleId]];
        [[RCCoreClient sharedCoreClient] updateRtLogPath:path];
    }
}

- (void)initIMSDK {
    [[RCCoreClient sharedCoreClient] initWithAppKey:[self p_getAppkeyOfAppGroup]];
    [[RCCoreClient sharedCoreClient] addReceiveMessageDelegate:self];
}

- (void)updateDeviceToken {
    NSData *deviceTokenData = [self p_getDeviceTokenOfAppGroup];
    if (deviceTokenData) {
        [[RCCoreClient sharedCoreClient] setDeviceTokenData:deviceTokenData];
    } else {
        NSLog(@"%s Error: deviceTokenData is nil",__func__);
    }
}

- (void)connectIM {
    NSString *token = [self p_getIMTokenOfAppGroup];
    NSLog(@"[PP] token : %@, appGroupIdentifier: %@, p_getAppkeyOfAppGroup:%@", token, self.appGroupIdentifier,[self p_getAppkeyOfAppGroup]);

    if (token.length <= 0) {
        NSLog(@"[RCNotificationServicePlugin error] can't connect im, token is nil");
        return;
    }

    [[RCCoreClient sharedCoreClient] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
        NSLog(@"RCNotificationServicePlugin: open db");
    } success:^(NSString *userId) {
        NSLog(@"RCNotificationServicePlugin: connect success,userId is %@", userId);
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"RCNotificationServicePlugin: connect error %@", @(errorCode));
    }];
}

- (void)serviceExtensionTimeWillExpire {
    [self disconnectAndCallback];
}

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAppBadge];
        //消息接收到之后，断开连接并回调
        if (nLeft == 0) {
            [self disconnectAndCallback];
        }
        RCTextMessage *msg = (RCTextMessage *)message.content;
        NSString *content= msg.content;
        if (message.conversationType == 1) {
            NSLog(@"[RCPush]2-1 time: %lld, conversationType: %ld, uid: %@, nLeft:%d, content: %@", message.sentTime, message.conversationType, message.messageUId, nLeft,content);

        } else {
            NSLog(@"[RCPush]2-3 time: %lld, conversationType: %ld, uid: %@, nLeft:%d, content: %@", message.sentTime, message.conversationType, message.messageUId, nLeft,content);
        }
    });
}

#pragma mark - util

- (void)disconnectAndCallback {
    [[RCCoreClient sharedCoreClient] disconnect];
    if (self.currentBadge > 0) {
        self.firstNotificationContent.badge = [NSNumber numberWithUnsignedInteger:self.currentBadge];
    }
    self.contentHandler(self.firstNotificationContent);
}

- (void)updateAppBadge {
    NSUInteger pushBadge = [self.firstNotificationContent.badge unsignedIntegerValue];
    //如果远程推送的角标大于 1 ，那么大概率是推送指定了角标数，那么要使用指定的数字
    if (pushBadge > 1) {
        [self doUpdateCurrentAppBadge:pushBadge];
        return;
    }
    
    //获取 app 传入的角标
    NSUInteger defalutBadge = [self p_getAppBadge];
    if (defalutBadge <= 0) {
        defalutBadge = 0;
    }
    //累加推送的角标
    defalutBadge += 1;
    
    [self doUpdateCurrentAppBadge:defalutBadge];

}

- (void)doUpdateCurrentAppBadge:(NSUInteger)badge {
    if (badge <= 0) {
        return;
    }
    [self p_saveAppBadge:badge];
    self.currentBadge = badge;
}

- (void)addWormholeListener{
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:self.appGroupIdentifier
                                                         optionalDirectory:@"RCWormholeDirectory"];
    [self.wormhole passMessageObject:nil
                          identifier:@"RCNSNotifyKey"];
    
    [self.wormhole listenForMessageWithIdentifier:@"RCNSAppNotifyKey" listener:^(id messageObject) {
        
        NSString *appClientPtr = [messageObject valueForKey:@"ClientPointer"];
        NSString *pushExtClientPtr = [NSString stringWithFormat:@"%p",[RCCoreClient sharedCoreClient]];
//        NSLog(@"qxb addWormholeListener appClientPointer %@ PushExtPointer %@",appClientPtr,pushExtClientPtr);
        if (![pushExtClientPtr isEqualToString:appClientPtr]) {
//            NSLog(@"qxb [RCCoreClient sharedCoreClient] PushExt %@ pid:%u disconnect",[RCCoreClient sharedCoreClient],getpid());
            [self disconnectAndCallback];
        }
    }];
}

- (NSString *)getMessageUidWithContent:(UNNotificationContent *)content{
    NSDictionary *rcDic = content.userInfo[@"rc"];
    if (!rcDic) {
        return nil;
    }
    return rcDic[@"id"];
}

- (long long)getPushMessageSentTime:(UNNotificationContent *)content{
    NSDictionary *rcDic = content.userInfo[@"rc"];
    if (!rcDic) {
        return 0;
    }
    return [rcDic[@"msgTime"] longLongValue];
}

#pragma mark - private
- (NSString *)p_pushExtMsgDBPath {
    NSURL *sharedURL = [[NSFileManager defaultManager]
                        containerURLForSecurityApplicationGroupIdentifier:self.appGroupIdentifier];
    NSString *path = sharedURL.path;
    NSLog(@"RCNotificationServicePlugin: im db path is %@",path);
    return path;
}

- (BOOL)shouldConnectWith:(long long)time {
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    NSNumber *num = [appGroupDefaults valueForKey:@"RCAppGroupAppSendTime"];
    long long current = [num longLongValue];
    if (time <= current) {
        NSLog(@"[RCPush] time error: time: %lld, current: %lld", time, current);

        return NO;
    }

    NSLog(@"[RCPush] time increase: current: %lld to  time: %lld", current, time);
    [appGroupDefaults setObject:@(time) forKey:@"RCAppGroupAppSendTime"];
    return YES;
}

- (NSString *)p_getAppkeyOfAppGroup {
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    return [appGroupDefaults valueForKey:@"RCAppGroupAppkey"];
}

- (NSData *)p_getDeviceTokenOfAppGroup {
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    return [appGroupDefaults valueForKey:@"RCAppGroupDeviceToken"];
}

- (NSString *)p_getIMTokenOfAppGroup {
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    return [appGroupDefaults valueForKey:@"RCAppGroupIMToken"];
}

- (NSString *)p_getAppBundleId {
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    return [appGroupDefaults valueForKey:@"RCAppBundleId"];
}

- (NSUInteger)p_getAppBadge {
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    NSNumber *num = [appGroupDefaults valueForKey:@"RCAppBadgeNumber"];
    return [num unsignedIntegerValue];
}

- (void)p_saveAppBadge:(NSUInteger)badge {
    if (badge <= 0) {
        return;
    }
    NSNumber *num = [NSNumber numberWithUnsignedInteger:badge];
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    [appGroupDefaults setValue:num forKey:@"RCAppBadgeNumber"];
}

@end
