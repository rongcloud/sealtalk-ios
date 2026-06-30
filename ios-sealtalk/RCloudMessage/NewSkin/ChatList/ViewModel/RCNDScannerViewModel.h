//
//  RCNDScannerViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewModel.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol RCNDScannerViewModelDelegate<NSObject>
- (void)openURLInQRCode:(NSString *_Nonnull)urlString;
- (void)showUserProfileInQRCode:(NSString *_Nonnull)userID;
- (void)showGroupConversationInQRCode:(NSString *_Nonnull)groupId title:(NSString *_Nonnull)title;
- (void)showGroupJoinViewInQRCode:(RCGroupInfo *_Nonnull)info;
@end


@interface RCNDScannerViewModel : RCNDBaseViewModel
@property (nonatomic, weak) id<RCNDScannerViewModelDelegate> delegate;
@property (nonatomic, weak) UIViewController *viewController;
- (void)identifyQRCode:(NSString *)info;
@end

NS_ASSUME_NONNULL_END
