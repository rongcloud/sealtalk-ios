//
//  RCNDLoginView.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDLoginView : RCNDBaseView
@property (nonatomic, strong) UIStackView *contentStackView;
@property (nonatomic, strong) UILabel *labelDataCenter;
@property (nonatomic, strong) UILabel *labelArea;
@property (nonatomic, strong) UILabel *labelCountryCode;
@property (nonatomic, strong) UITextField *txtPhoneNum;
@property (nonatomic, strong) UITextField *txtPhotoVerifyCode;
@property (nonatomic, strong) UITextField *txtVerifyCode;

@property (nonatomic, strong) UIButton *buttonLanguage;
@property (nonatomic, strong) UIButton *buttonPhotoVerify;
@property (nonatomic, strong) UIButton *buttonVerify;
@property (nonatomic, strong) UIButton *buttonLogin;

@property (nonatomic, strong) UITextView *textViewPrivacy;
@end

NS_ASSUME_NONNULL_END
