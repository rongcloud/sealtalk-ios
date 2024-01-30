//
//  NotificationService.m
//  SealTalkNotificationService
//
//  Created by 张改红 on 2021/5/25.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "NotificationService.h"
#import <RongIMLibCore/RongIMLibCore.h>
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
    [[RCCoreClient sharedCoreClient] configApplicationGroupIdentifier:RCDNotificationServiceGroup isMainApp:NO];

    NSDictionary *userInfo = self.bestAttemptContent.userInfo;
    
    NSString *statsServer = [RCDEnvironmentContext statsServer];
    NSString *naviServer = [RCDEnvironmentContext navServer];
    if (naviServer.length > 0) {
        [[RCCoreClient sharedCoreClient] setServerInfo:naviServer fileServer:nil];
    }
    if (statsServer.length > 0) {
        [[RCCoreClient sharedCoreClient] setStatisticServer:statsServer];
    }
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *category = [aps objectForKey:@"category"];
    NSString *richMediaUri = [userInfo objectForKey:@"richMediaUri"];
    if (category && [category isEqualToString:@"RC:VCHangup"]) {
        NSString *identifier = [aps objectForKey:@"thread-id"];
        if (identifier) {
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[identifier]];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.bestAttemptContent = [request.content mutableCopy];
            self.contentHandler(self.bestAttemptContent);
        });
    } else if ((richMediaUri.length > 0) && ([richMediaUri hasPrefix:@"http://"] || [richMediaUri hasPrefix:@"https://"])) {
        //download
        NSURL *imgURL = [NSURL URLWithString:richMediaUri];
        [self downloadAndSave:imgURL handler:^(NSString *localPath) {
            if (localPath) {
                UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"myAttachment" URL:[NSURL fileURLWithPath:localPath] options:nil error:nil];
                self.bestAttemptContent.attachments = @[attachment];
            }
            self.contentHandler(self.bestAttemptContent);
        }];
    } else {
        self.contentHandler(self.bestAttemptContent);
    }
    [[RCCoreClient sharedCoreClient] initWithAppKey:[RCDEnvironmentContext appKey]];
    [[RCCoreClient sharedCoreClient] recordReceivedRemoteNotificationEvent:userInfo];
 
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
}


#pragma mark - Network

- (void)downloadAndSave:(NSURL *)imageURL handler:(void (^)(NSString *))handler {
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:imageURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *localPath = nil;
        if (!error) {
            NSString * localURL = NSTemporaryDirectory();
            if (imageURL.pathExtension && (imageURL.pathExtension.length > 0)) {
                localURL = [localURL stringByAppendingPathComponent:imageURL.lastPathComponent];
            } else {
                NSString *fileName = [NSString stringWithFormat:@"%@",@([[NSDate date] timeIntervalSince1970] * 1000)];
                if ([imageURL.absoluteString containsString:@"png"]) {
                    fileName = [fileName stringByAppendingString:@".png"];
                } else if ([imageURL.absoluteString containsString:@"jpeg"]) {
                    fileName = [fileName stringByAppendingString:@".jpeg"];
                }  else if ([imageURL.absoluteString containsString:@"jpg"]) {
                    fileName = [fileName stringByAppendingString:@".jpg"];
                } else {
                    fileName = [fileName stringByAppendingString:@".png"];
                }
                localURL = [localURL stringByAppendingPathComponent:fileName];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:localURL]) {
                [[NSFileManager defaultManager] removeItemAtPath:localURL error:nil];
            }
            NSError *error;
            if (location.path.length > 0 && localURL.length > 0){
                BOOL success = [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:localURL error:&error];
                if (success) {
                    localPath = localURL;
                }
            }
        }
        handler(localPath);
    }];
    [task resume];
}

@end
