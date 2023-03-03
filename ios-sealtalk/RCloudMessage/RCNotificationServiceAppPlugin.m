//
//  RCNotificationServiceAppPlugin.m
//  SealTalk
//
//  Created by Qi on 2022/3/31.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCNotificationServiceAppPlugin.h"
#import <MMWormhole/MMWormhole.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCCoreClient+DBPath.h"

@interface RCNotificationServiceAppPlugin ()
@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, copy) NSString *appGroupIdentifier;
@end
@implementation RCNotificationServiceAppPlugin
+ (instancetype)sharedInstance {
    static RCNotificationServiceAppPlugin *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addNotifications];
    }
    return self;
}

#pragma mark - public method

- (void)configWithApplicationGroupIdentifier:(NSString *)identifier appkey:(NSString *)appkey userId:(NSString *)userId token:(NSString *)imToken {
    if (identifier.length <= 0 || appkey.length <= 0 || userId.length <= 0 || imToken.length <= 0) {
        NSLog(@"%s Error:(identifier:%@)(appkey:%@)(userId:%@)(imToken:%@)",__func__,identifier,appkey,userId,imToken);
        return;
    }
    
    self.appGroupIdentifier = identifier;
    
    [self configWormholeWithApplicationGroupIdentifier:identifier];
    
    [self moveDBFile:appkey userId:userId];
    
    NSString *appBundleId = [self getAppBundleId];
    [self updateSDKMsgDB:appBundleId];
    
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    [appGroupDefaults setValue:appkey forKey:@"RCAppGroupAppkey"];
    [appGroupDefaults setValue:imToken forKey:@"RCAppGroupIMToken"];
    [appGroupDefaults setValue:appBundleId forKey:@"RCAppBundleId"];
}

- (void)updateDeviceTokenData:(NSData *)deviceToken {
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    [appGroupDefaults setValue:deviceToken forKey:@"RCAppGroupDeviceToken"];
}

- (void)updateAppBadge:(NSUInteger)badge {
    if (badge <= 0) {
        return;
    }
    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.appGroupIdentifier];
    [appGroupDefaults setValue:[NSNumber numberWithUnsignedInteger:badge] forKey:@"RCAppBadgeNumber"];
}

#pragma mark - util method

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}
- (void)configWormholeWithApplicationGroupIdentifier:(NSString *)identifier {
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:identifier
                                                         optionalDirectory:@"RCWormholeDirectory"];
}

- (NSString *)getAppBundleId {
    NSString *identification = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    identification = identification?identification:@"";
    return identification;
}

- (void)updateSDKMsgDB:(NSString *)appBudleId {
    NSString *path = [self pushExtMsgDBPath];
    if (path.length > 0) {
        [[RCCoreClient sharedCoreClient] updateMessageDBPath:path withAppBundleId:appBudleId];
    }
}

- (NSString *)pushExtMsgDBPath {
    NSURL *sharedURL = [[NSFileManager defaultManager]
                        containerURLForSecurityApplicationGroupIdentifier:self.appGroupIdentifier];
    NSString *path = sharedURL.path;
    NSLog(@"RCDPushExtention: im db path is %@",path);
    return path;
}
- (void)moveDBFile:(NSString *)appKey userId:(NSString *)userId {
    if (userId.length == 0 || appKey.length == 0) {
        return;
    }
    NSString *libraryPath =
        NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"RongCloud"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath]) {
        NSArray<NSString *> *subPaths =
            [[NSFileManager defaultManager] contentsOfDirectoryAtPath:libraryPath error:nil];
        [subPaths enumerateObjectsUsingBlock:^(NSString *_Nonnull userPath, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([userPath isEqualToString:appKey]) {
                NSString *path = [self pushExtMsgDBPath];
                NSString *toPath = [[path stringByAppendingPathComponent:userPath] stringByAppendingPathComponent:userId];
                NSString *fromPath = [[libraryPath stringByAppendingPathComponent:userPath] stringByAppendingPathComponent:userId];
                if ([[NSFileManager defaultManager] fileExistsAtPath:fromPath]) {
                    NSArray<NSString *> *currentUserPaths =
                        [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fromPath error:nil];
                    for (NSString *path in currentUserPaths) {
                        if ([path hasPrefix:@"storage"]) {
                            NSString *fromTemp = [fromPath stringByAppendingPathComponent:path];
                            NSString *toTemp = [toPath stringByAppendingPathComponent:path];
                            BOOL success = [self moveItemAtPath:fromTemp toPath:toTemp];
                            NSLog(@"move %@ from %@ to %@: %@",path,fromTemp,toPath,@(success));
                        }
                    }
                }
                return;
            }
        }];
    }
}

- (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath{
    if (!path || !toPath) {
        return NO;
    }
    //获得目标文件的上级目录
    NSString *toDirPath = [toPath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:toDirPath]) {
        // 创建移动路径
        [[NSFileManager defaultManager] createDirectoryAtPath:toDirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:toPath error:nil];
    }
    
    // 移动文件，当要移动到的文件路径文件存在，会移动失败
    BOOL isSuccess = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:nil];
    
    return isSuccess;
}

#pragma mark - private method
- (void)p_notifyPushExtensionToDisconnect {
    NSString *pointer = [NSString stringWithFormat:@"%p",[RCCoreClient sharedCoreClient]];
    if (!pointer) {
        pointer = @"";
    }
    [self.wormhole passMessageObject:@{@"ClientPointer" : pointer}
                          identifier:@"RCNSAppNotifyKey"];
}

- (void)p_registerPushExtensionNotify {
    [self.wormhole listenForMessageWithIdentifier:@"RCNSNotifyKey" listener:^(id messageObject) {
        [self p_notifyPushExtensionToDisconnect];
    }];
}

- (void)handleAppWillEnterForeground {
    [self p_notifyPushExtensionToDisconnect];
}

- (void)handleAppTerminate {
//    [self p_notifyPushExtensionToDisconnect];
}
@end
