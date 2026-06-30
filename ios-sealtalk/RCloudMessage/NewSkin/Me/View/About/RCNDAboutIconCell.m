//
//  RCNDAboutIconCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDAboutIconCell.h"

NSString  * const RCNDAboutIconCellIdentifier = @"RCNDAboutIconCellIdentifier";

@implementation RCNDAboutIconCell
- (void)setupView {
    [super setupView];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.icon];
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
        [self.icon.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:20],
        [self.icon.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.icon.widthAnchor constraintEqualToConstant:96],
        [self.icon.heightAnchor constraintEqualToConstant:96]
       ]];

}
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_sealchat"]];
        _icon.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _icon;
}
@end
