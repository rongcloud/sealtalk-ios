//
//  RCNDMyQRView.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseView.h"
#import "RCNDMeHeaderView.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDQRCodeView : RCNDBaseView
@property (nonatomic, strong) RCNDMeHeaderView *headerView;

@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIImageView *qrImageView;

@property (nonatomic, strong) UIStackView *bottomStackView;

@property (nonatomic, strong) UIButton *buttonSave;
@property (nonatomic, strong) UIButton *buttonRongCloud;
@property (nonatomic, strong) UIButton *buttonWeChat;
@property (nonatomic, strong) UIView *infoContainerView;
@end

NS_ASSUME_NONNULL_END
