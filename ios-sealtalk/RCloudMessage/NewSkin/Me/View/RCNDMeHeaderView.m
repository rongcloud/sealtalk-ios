//
//  RCNDMeHeaderView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMeHeaderView.h"
#import <SDWebImage/SDWebImage.h>
NSInteger const RCNDMeHeaderViewPortraitSize = 60;

@implementation RCNDMeHeaderView

- (void)setupView {
    [super setupView];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentStackView];
    [self.contentStackView addArrangedSubview:self.portraitImageView];
    [self.contentStackView addArrangedSubview:self.rightStackView];
    [self.rightStackView addArrangedSubview:self.nameLabel];
    [self.rightStackView addArrangedSubview:self.remarkLabel];
//    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupConstraints {
    [super setupConstraints];
    // 创建水平约束并降低优先级，避免在 tableFooterView 中宽度为 0 时冲突
    NSLayoutConstraint *leadingConstraint = [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:RCUserManagementPadding];
    leadingConstraint.priority = UILayoutPriorityDefaultHigh; // 750
    
    NSLayoutConstraint *trailingConstraint = [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-RCUserManagementPadding];
    trailingConstraint.priority = UILayoutPriorityDefaultHigh; // 750
    
    [NSLayoutConstraint activateConstraints:@[
        leadingConstraint,
        trailingConstraint,
          [self.contentStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:20],
          [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-20],
          [self.portraitImageView.widthAnchor constraintEqualToConstant:RCNDMeHeaderViewPortraitSize],
          [self.portraitImageView.heightAnchor constraintEqualToConstant:RCNDMeHeaderViewPortraitSize],

      ]];

}

- (void)showPortrait:(NSString *)imageURL isGroup:(BOOL)isGroup {
    UIImage *image = RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg");
    if (isGroup) {
        image = RCDynamicImage(@"conversation-list_cell_group_portrait_img",@"default_group_portrait");
    }
    NSURL *url = [NSURL URLWithString:imageURL];
    
    [self.portraitImageView sd_setImageWithURL:url
                              placeholderImage:image];
}

- (void)showPortrait:(NSString *)imageURL {
    [self showPortrait:imageURL isGroup:NO];
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.translatesAutoresizingMaskIntoConstraints = NO;
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = RCNDMeHeaderViewPortraitSize/2;
            _portraitImageView.layer.borderWidth = 2;
            _portraitImageView.layer.borderColor = RCDynamicColor(@"common_background_color", @"0xffffff", @"0x141414").CGColor;
        }else{
            _portraitImageView.layer.cornerRadius = 5.f;
        }
        _portraitImageView.layer.masksToBounds = YES;
        [_portraitImageView setImage:RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg")];
    }
    return _portraitImageView;
}

- (UIStackView *)rightStackView {
    if (!_rightStackView) {
        _rightStackView = [[UIStackView alloc] init];
        _rightStackView.axis = UILayoutConstraintAxisVertical;
        _rightStackView.alignment = UIStackViewAlignmentLeading;
        _rightStackView.distribution = UIStackViewDistributionFill;
        _rightStackView.spacing = 5;
        _rightStackView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _rightStackView;
}

- (UIStackView *)contentStackView {
    if (!_contentStackView) {
        _contentStackView = [[UIStackView alloc] init];
        _contentStackView.axis = UILayoutConstraintAxisHorizontal;
        _contentStackView.alignment = UIStackViewAlignmentCenter;
        _contentStackView.distribution = UIStackViewDistributionFill;
        _contentStackView.spacing = 20;
        _contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentStackView;
}


- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = RCDynamicColor(@"text_primary_color", @"0x020814", @"0xffffff");
        _nameLabel.font = [UIFont boldSystemFontOfSize:20];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nameLabel;
}

- (UILabel *)remarkLabel {
    if (!_remarkLabel) {
        _remarkLabel = [[UILabel alloc] init];
        _remarkLabel.textColor =  RCDynamicColor(@"text_primary_color", @"0x020814", @"0xffffff");
        _remarkLabel.font = [UIFont systemFontOfSize:14];
        _remarkLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _remarkLabel;
}


@end
