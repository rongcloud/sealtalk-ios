//
//  RCNDJoinGroupView.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDJoinGroupView.h"

@implementation RCNDJoinGroupView
- (void)setupView {
    [super setupView];
    [self addSubview:self.portraitView];
    [self addSubview:self.labelTitle];
    [self addSubview:self.buttonJoin];
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
        
        [self.portraitView.topAnchor constraintEqualToAnchor:self.topAnchor constant:140],
        [self.portraitView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.portraitView.widthAnchor constraintEqualToConstant:60],
        [self.portraitView.heightAnchor constraintEqualToConstant:60],
          [self.labelTitle.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:RCUserManagementPadding],
          [self.labelTitle.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-RCUserManagementPadding],
          [self.labelTitle.topAnchor constraintEqualToAnchor:self.portraitView.bottomAnchor constant:RCUserManagementPadding],
          
          [self.buttonJoin.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:RCUserManagementPadding],
          [self.buttonJoin.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-RCUserManagementPadding],
          [self.buttonJoin.topAnchor constraintEqualToAnchor:self.labelTitle.bottomAnchor constant:40],
      ]];
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] init];
        _portraitView.translatesAutoresizingMaskIntoConstraints = NO;
        _portraitView.contentMode = UIViewContentModeScaleAspectFill;
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitView.layer.cornerRadius = 30.f;
        } else {
            _portraitView.layer.cornerRadius = 5.f;
        }
        _portraitView.layer.masksToBounds = YES;
        _portraitView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _portraitView;
}

- (UILabel *)labelTitle {
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = RCDynamicColor(@"text_primary_color", @"0x020814", @"0xFFFFFF");
        _labelTitle.font = [UIFont systemFontOfSize:20];
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.text = RCDLocalizedString(@"MyScanQRCodeInfo");
        _labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _labelTitle;
}

- (UIButton *)buttonJoin {
    if (!_buttonJoin) {
        
        // 创建按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:RCDLocalizedString(@"JoinThisGroup") forState:UIControlStateNormal];
        [btn setBackgroundColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x007acc")];
        [btn setTitleColor:RCDynamicColor(@"control_title_white_color", @"0xffffff", @"0xffffff")
                  forState:UIControlStateNormal];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 6;
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        // 添加按钮高度约束
        [btn.heightAnchor constraintEqualToConstant:42].active = YES;
        _buttonJoin = btn;
    }
    return _buttonJoin;
}
@end
