//
//  RCDOpenClawBotListCell.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/9.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotListCell.h"
#import <RongIMKit/RongIMKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

NSString *const RCDOpenClawBotListCellIdentifier = @"RCDOpenClawBotListCellIdentifier";
CGFloat const RCDOpenClawBotListCellHeight = 56.f;
static CGFloat const RCDOpenClawBotListCellPadding = 16.f;
static CGFloat const RCDOpenClawBotListCellAvatarWidth = 32.f;
static CGFloat const RCDOpenClawBotListCellLineLeading = 60.f;
static CGFloat const RCDOpenClawBotListCellLineTrailing = 10.f;

@interface RCDOpenClawBotListCell ()

@property (nonatomic, strong) UIView *paddingContainerView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation RCDOpenClawBotListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;

    [self.contentView addSubview:self.paddingContainerView];
    [self.paddingContainerView addSubview:self.avatarView];
    [self.paddingContainerView addSubview:self.nameLabel];
    [self.paddingContainerView addSubview:self.lineView];

    [NSLayoutConstraint activateConstraints:@[
        [self.paddingContainerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:RCDOpenClawBotListCellPadding],
        [self.paddingContainerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-RCDOpenClawBotListCellPadding],
        [self.paddingContainerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.paddingContainerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],

        [self.avatarView.leadingAnchor constraintEqualToAnchor:self.paddingContainerView.leadingAnchor constant:RCDOpenClawBotListCellPadding],
        [self.avatarView.centerYAnchor constraintEqualToAnchor:self.paddingContainerView.centerYAnchor],
        [self.avatarView.widthAnchor constraintEqualToConstant:RCDOpenClawBotListCellAvatarWidth],
        [self.avatarView.heightAnchor constraintEqualToConstant:RCDOpenClawBotListCellAvatarWidth],

        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:8.f],
        [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.paddingContainerView.trailingAnchor constant:-RCDOpenClawBotListCellPadding],
        [self.nameLabel.centerYAnchor constraintEqualToAnchor:self.paddingContainerView.centerYAnchor],

        [self.lineView.leadingAnchor constraintEqualToAnchor:self.paddingContainerView.leadingAnchor constant:RCDOpenClawBotListCellLineLeading],
        [self.lineView.trailingAnchor constraintEqualToAnchor:self.paddingContainerView.trailingAnchor constant:-RCDOpenClawBotListCellLineTrailing],
        [self.lineView.heightAnchor constraintEqualToConstant:1.f],
        [self.lineView.bottomAnchor constraintEqualToAnchor:self.paddingContainerView.bottomAnchor]
    ]];
}

- (void)configureWithName:(NSString *)name portraitUri:(NSString *)portraitUri {
    self.nameLabel.text = name;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                       placeholderImage:[UIImage imageNamed:@"openclaw_assistant_logo"]];
}

- (UIView *)paddingContainerView {
    if (!_paddingContainerView) {
        _paddingContainerView = [UIView new];
        _paddingContainerView.backgroundColor = RCDynamicColor(@"common_background_color", @"0xffffff", @"0x1c1c1e");
        _paddingContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _paddingContainerView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [UIImageView new];
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _avatarView.layer.cornerRadius = RCDOpenClawBotListCellAvatarWidth / 2;
        } else {
            _avatarView.layer.cornerRadius = 5.f;
        }
        _avatarView.layer.masksToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:17.f];
        _nameLabel.textColor = RCDynamicColor(@"text_primary_color", @"0x020814", @"0xFFFFFF");
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nameLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = RCDynamicColor(@"line_background_color", @"0xE3E5E6", @"0x272727");
        _lineView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _lineView;
}

@end
