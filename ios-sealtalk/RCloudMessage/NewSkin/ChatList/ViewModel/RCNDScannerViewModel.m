//
//  RCNDScannerViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDScannerViewModel.h"

@implementation RCNDScannerViewModel

#pragma mark - Result
- (void)identifyQRCode:(NSString *)info {
    if (info) {
        if ([info containsString:@"key=sealtalk://group/join?"]) {
            NSArray *array = [info componentsSeparatedByString:@"key=sealtalk://group/join?"];
            if (array.count >= 2) {
                NSArray *arr = [array[1] componentsSeparatedByString:@"&"];
                if (arr.count >= 2) {
                    NSString *gIdStr = arr[0];
                    NSString *uIdStr = arr[1];
                    if ([gIdStr hasPrefix:@"g="] && gIdStr.length > 2) {
                        gIdStr = [gIdStr substringWithRange:NSMakeRange(2, gIdStr.length - 2)];
                    }
                    if ([uIdStr hasPrefix:@"u="] && uIdStr.length > 2) {
                        uIdStr = [uIdStr substringWithRange:NSMakeRange(2, uIdStr.length - 2)];
                    }
                    if (gIdStr.length > 0) {
                        [self handleGroupInfo:gIdStr];
                    }
                }
            }
        } else if ([info containsString:@"key=sealtalk://user/info?"]) {
            NSArray *array = [info componentsSeparatedByString:@"key=sealtalk://user/info?"];
            if (array.count >= 2) {
                NSString *uIdStr = array[1];
                if ([uIdStr hasPrefix:@"u="] && uIdStr.length > 2) {
                    uIdStr = [uIdStr substringWithRange:NSMakeRange(2, uIdStr.length - 2)];
                }
                if (uIdStr.length > 0) {
                    [self showUserProfileInQRCode:uIdStr];
                }
            }
        } else if ([info hasPrefix:@"http"]) {
            [self openURLInQRCode:info];
        } else {
            [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
        }
    } else {
    }
}

#pragma mark - helper

- (void)showGroupJoinViewInQRCode:(RCGroupInfo *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self leftBarButtonBackAction];
        if ([self.delegate respondsToSelector:@selector(showGroupJoinViewInQRCode:)]) {
            [self.delegate showGroupJoinViewInQRCode:info];
        }
    });
  
}

- (void)showGroupConversationInQRCode:(NSString *)groupId title:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self leftBarButtonBackAction];
        if ([self.delegate respondsToSelector:@selector(showGroupConversationInQRCode:title:)]) {
            [self.delegate showGroupConversationInQRCode:groupId title:title];
        }
    });
   
}

- (void)showUserProfileInQRCode:(NSString *)userID  {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self leftBarButtonBackAction];

        if ([self.delegate respondsToSelector:@selector(showUserProfileInQRCode:)]) {
            [self.delegate showUserProfileInQRCode:userID];
        }
    });
   
}

- (void)openURLInQRCode:(NSString *)urlString {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self leftBarButtonBackAction];
        if ([self.delegate respondsToSelector:@selector(openURLInQRCode:)]) {
            [self.delegate openURLInQRCode:urlString];
        }
    });
 
}

- (void)handleGroupInfo:(NSString *)groupId {
    NSString *userID= [[RCCoreClient sharedCoreClient] currentUserInfo].userId;
    if (userID) {
        [[RCCoreClient sharedCoreClient] getGroupsInfo:@[groupId] success:^(NSArray<RCGroupInfo *> * _Nonnull groupInfos) {
            if (groupInfos.count) {
                RCGroupInfo *info = [groupInfos firstObject];
                [[RCCoreClient sharedCoreClient] getGroupMembers:groupId userIds:@[userID] success:^(NSArray<RCGroupMemberInfo *> * _Nonnull groupMembers) {
                    [self showGroupConversationInQRCode:groupId title:info.groupName];
                } error:^(RCErrorCode errorCode) {
                    if(errorCode == RC_GROUP_USER_NOT_IN_GROUP) {
                        [self showGroupJoinViewInQRCode:info];
                        
                    } else {
                        [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
                    }
                }];
            } else {
                [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
            }
            
        } error:^(RCErrorCode errorCode) {
            [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
        }];
        
    } else {
        [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
        
    }
    
}

- (void)showAlert:(NSString *)alertContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCAlertView showAlertController:nil
                                 message:alertContent
                             cancelTitle:RCDLocalizedString(@"confirm")
                        inViewController:self];
    });
    
}
@end
