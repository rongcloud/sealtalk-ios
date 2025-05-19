//
//  RCDAgentUnavailableView.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentUnavailableView.h"


@interface RCDAgentUnavailableView()
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UIView *containerView;

@end
@implementation RCDAgentUnavailableView

- (void)setupView {
    [super setupView];
    self.containerView = [UIView new];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.buttonEnable];
    [self.containerView addSubview:self.labTitle];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.buttonEnable.frame.size.height + 12 + self.labTitle.frame.size.height;
    self.containerView.bounds = CGRectMake(0, 0, self.labTitle.bounds.size.width, height);
    self.containerView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.buttonEnable.center = CGPointMake(self.containerView.bounds.size.width/2, self.buttonEnable.frame.size.height/2);
    self.labTitle.center = CGPointMake(self.containerView.bounds.size.width/2, height - self.labTitle.frame.size.height/2);

}

- (RCButton *)buttonEnable {
    if (!_buttonEnable) {
        _buttonEnable = [[RCButton alloc] initWithFrame:CGRectMake(0, 0, 100, 42)];
        [_buttonEnable setTitle:RCDLocalizedString(@"agent_enable_btn_title")
                       forState:UIControlStateNormal];
        UIColor *color = RCMASKCOLOR(0xFFFFFF,0.52);
        [_buttonEnable setBackgroundColor:color];
        [_buttonEnable setTitleColor:HEXCOLOR(0x007AFF) forState:UIControlStateNormal];
        [_buttonEnable setExclusiveTouch:YES];
        _buttonEnable.layer.cornerRadius = 12;
        _buttonEnable.titleLabel.font = [UIFont systemFontOfSize:14 weight:200];
    }
    return _buttonEnable;
}

- (UILabel *)labTitle {
    if (!_labTitle) {
        UILabel *lab = [UILabel new];
        lab.textColor = HEXCOLOR(0x41464F);
        lab.text = RCDLocalizedString(@"agent_unavailable_title");
        lab.font = [UIFont systemFontOfSize:12];
        [lab sizeToFit];
        _labTitle = lab;
    }
    return _labTitle;
}

@end

