//
//  RCNDQRCodeViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewController.h"
#import "RCNDQRCodeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDQRCodeViewController : RCNDBaseViewController
@property (nonatomic, strong) RCNDQRCodeView *qrView;

- (void)showQRInfo;
@end

NS_ASSUME_NONNULL_END
