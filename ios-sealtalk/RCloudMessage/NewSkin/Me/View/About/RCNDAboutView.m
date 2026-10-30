//
//  RCNDAboutView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDAboutView.h"

@implementation RCNDAboutView

- (void)setupView {
    [super setupView];
    [self.contentStackView addArrangedSubview:self.tipsLabel];
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
        [self.tipsLabel.heightAnchor constraintEqualToConstant:68]
    ]];
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor =  RCDynamicColor(@"text_secondary_color", @"0x7c838e", @"0x7c838e");
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        _tipsLabel.text = @"Powered by RongCloud";
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tipsLabel;
}
@end
