//
//  RCNDGroupQRViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDGroupQRViewController.h"
#import "RCDQRCodeManager.h"
@interface RCNDGroupQRViewController ()
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) RCGroupInfo *info;

@end

@implementation RCNDGroupQRViewController

- (instancetype)initWithGroupID:(NSString *)groupId
{
    self = [super init];
    if (self) {
        self.groupId = groupId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"GroupQR");
    if (!self.groupId) {
        return;
    }
    [[RCCoreClient sharedCoreClient] getGroupsInfo:@[self.groupId] success:^(NSArray<RCGroupInfo *> * _Nonnull groupInfos) {
            if (groupInfos.count) {
                self.info = groupInfos[0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshView];
                });
            }
        } error:^(RCErrorCode errorCode) {
            
        }];
}

- (void)refreshView {
    self.qrView.tipsLabel.text = RCDLocalizedString(@"GroupScanQRCodeInfo");
    self.qrView.headerView.nameLabel.text = [NSString stringWithFormat:@"%@(%ld)", self.info.groupName, self.info.membersCount];
    [self.qrView.headerView showPortrait:self.info.portraitUri isGroup:YES];
    NSString *qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://group/join?g=%@&u=%@", RCDQRCodeContentInfoUrl,
                                        self.info.groupId, [RCCoreClient sharedCoreClient].currentUserInfo.userId];
    self.qrView.qrImageView.image = [RCDQRCodeManager getQRCodeImage:qrInfo];
}

@end
