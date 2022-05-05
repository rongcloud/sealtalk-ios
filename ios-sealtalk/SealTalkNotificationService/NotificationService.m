//
//  NotificationService.m
//  SealTalkNotificationService
//
//  Created by 张改红 on 2021/5/25.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "NotificationService.h"
#import "RCDCommonDefine.h"
#import "RCDEnvironmentContext.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *userInfo = self.bestAttemptContent.userInfo;
    
    NSString *appKey = [RCDEnvironmentContext appKey];
    NSString *statsServer = [RCDEnvironmentContext statsServer];
    if (statsServer.length > 0) {
    }
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *category = [aps objectForKey:@"category"];
    if (category && [category isEqualToString:@"RC:VCHangup"]) {
        NSString *identifier = [aps objectForKey:@"thread-id"];
        if (identifier) {
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[identifier]];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.bestAttemptContent = [request.content mutableCopy];
            self.contentHandler(self.bestAttemptContent);
        });
    } else {
        self.contentHandler(self.bestAttemptContent);
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
