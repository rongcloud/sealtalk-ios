//
//  RCNDMyQRViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMyQRViewController.h"
#import "RCDCommonString.h"
#import "RCDQRCodeManager.h"
#import "RCDForwardManager.h"
#import "RCDUtilities.h"
#import "RCNDMeViewModel.h"

@interface RCNDMyQRViewController()
@end

@implementation RCNDMyQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"My_QR");
}

- (void)setupView {
    [super setupView];
    self.qrView.tipsLabel.text = RCDLocalizedString(@"MyScanQRCodeInfo");
    [RCNDMeViewModel fetchMyProfile:^(RCUserProfile * _Nullable userProfile) {
        if (userProfile) {
            NSString *portraitUrl = userProfile.portraitUri;            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.qrView.headerView.nameLabel.text = userProfile.name;
                [self.qrView.headerView showPortrait:portraitUrl];
            });
        }
    }];
}

- (void)showQRInfo {
    [super showQRInfo];
    NSString *qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://user/info?u=%@", RCDQRCodeContentInfoUrl,
                                        [RCCoreClient sharedCoreClient].currentUserInfo.userId];
    self.qrView.qrImageView.image = [RCDQRCodeManager getQRCodeImage:qrInfo];
    
}

@end
