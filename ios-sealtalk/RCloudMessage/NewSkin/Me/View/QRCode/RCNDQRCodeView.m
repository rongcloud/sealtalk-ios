//
//  RCNDMyQRView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRCodeView.h"

@implementation RCNDQRCodeView

- (void)setupView {
    [super setupView];
    self.backgroundColor = RCDynamicColor(@"auxiliary_background_1_color", @"0xf5f6f9", @"0x111111");
    [self addSubview:self.infoContainerView];
    [self.infoContainerView addSubview:self.headerView];
    [self.infoContainerView addSubview:self.qrImageView];
    [self.infoContainerView addSubview:self.tipsLabel];
    [self addSubview:self.bottomStackView];

    [self.bottomStackView addArrangedSubview:self.buttonSave];
    UIView *line = [self createLineView];
    [self.bottomStackView addArrangedSubview:line];
    [self.bottomStackView addArrangedSubview:self.buttonRongCloud];
//    line = [self createLineView];
//    [self.bottomStackView addArrangedSubview:line];
//    [self.bottomStackView addArrangedSubview:self.buttonWeChat];
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
        [self.infoContainerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.infoContainerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [self.infoContainerView.topAnchor constraintEqualToAnchor:self.topAnchor constant:80],
        
          [self.headerView.leadingAnchor constraintEqualToAnchor:self.infoContainerView.leadingAnchor constant:20],
          [self.headerView.trailingAnchor constraintEqualToAnchor:self.infoContainerView.trailingAnchor constant:-20],
          [self.headerView.topAnchor constraintEqualToAnchor:self.infoContainerView.topAnchor constant:20],
          [self.headerView.heightAnchor constraintEqualToConstant:100],
          
          [self.qrImageView.widthAnchor constraintEqualToAnchor:self.qrImageView.heightAnchor],
          [self.qrImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
          [self.qrImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
          [self.qrImageView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:4],

          [self.tipsLabel.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
          [self.tipsLabel.topAnchor constraintEqualToAnchor:self.qrImageView.bottomAnchor constant:20],
          [self.tipsLabel.bottomAnchor constraintEqualToAnchor:self.infoContainerView.bottomAnchor constant:-20],
          [self.bottomStackView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
          [self.bottomStackView.topAnchor constraintEqualToAnchor:self.infoContainerView.bottomAnchor constant:20],

      ]];
}

- (UIView *)createLineView {
    UIView *line = [UIView new];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    line.backgroundColor = RCDynamicColor(@"text_secondary_color", @"0x7C838E", @"0x7C838E");
    [NSLayoutConstraint activateConstraints:@[
        [line.widthAnchor constraintEqualToConstant:1],
        [line.heightAnchor constraintEqualToConstant:16]
    ]];
    return line;
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:RCDynamicColor(@"primary_color", @"0x0099ff", @"0x0099ff")
              forState:UIControlStateNormal];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    return btn;
}

- (RCNDMeHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [RCNDMeHeaderView new];
        _headerView.translatesAutoresizingMaskIntoConstraints = NO;
        _headerView.remarkLabel.hidden = YES;
    }
    return _headerView;
}

- (UIImageView *)qrImageView {
    if (!_qrImageView) {
        _qrImageView = [[UIImageView alloc] init];
        _qrImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _qrImageView.layer.cornerRadius = 10;
        _qrImageView.layer.masksToBounds = YES;
        _qrImageView.backgroundColor = RCDynamicColor(@"common_background_color", @"0xFFFFFF", @"0x2d2d2d");
    }
    return _qrImageView;
}

- (UIStackView *)bottomStackView {
    if (!_bottomStackView) {
        _bottomStackView = [[UIStackView alloc] init];
        _bottomStackView.axis = UILayoutConstraintAxisHorizontal;
        _bottomStackView.alignment = UIStackViewAlignmentCenter;
        _bottomStackView.distribution = UIStackViewDistributionFill;
        _bottomStackView.spacing = 17;
        _bottomStackView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bottomStackView;
}


- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor =  RCDynamicColor(@"text_secondary_color", @"0x7c838e", @"0x7c838e");
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tipsLabel;
}

- (UIButton *)buttonSave {
    if (!_buttonSave) {
        UIButton *btn = [self buttonWithTitle:RCDLocalizedString(@"SaveImage")];
        _buttonSave = btn;
    }
    
    return _buttonSave;
}

- (UIButton *)buttonRongCloud {
    if (!_buttonRongCloud) {
        UIButton *btn = [self buttonWithTitle:RCDLocalizedString(@"ShareToST")];
        _buttonRongCloud = btn;
    }
    
    return _buttonRongCloud;
}

- (UIButton *)buttonWeChat {
    if (!_buttonWeChat) {
        UIButton *btn = [self buttonWithTitle:RCDLocalizedString(@"ShareToWeChat")];
        _buttonWeChat = btn;
    }
    
    return _buttonWeChat;
}

- (UIView *)infoContainerView {
    if (!_infoContainerView) {
        _infoContainerView = [UIView new];
        _infoContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        _infoContainerView.backgroundColor = RCDynamicColor(@"auxiliary_background_1_color", @"0xf5f6f9", @"0x111111");
    }
    return _infoContainerView;
}

@end
