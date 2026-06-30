//
//  RCDOpenClawBotActionCell.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/9.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotActionCell.h"
#import "RCDUtilities.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

NSString *const RCDOpenClawBotActionCellIdentifier = @"RCDOpenClawBotActionCellIdentifier";
CGFloat const RCDOpenClawBotActionCellHeight = 54.f;

static CGFloat const RCDOpenClawBotActionCellOuterPadding = 16.f;
static CGFloat const RCDOpenClawBotActionCellInnerPadding = 16.f;
static CGFloat const RCDOpenClawBotActionCellAvatarWidth = 32.f;
static CGFloat const RCDOpenClawBotActionCellButtonHeight = 24.f;
static CGFloat const RCDOpenClawBotActionCellSpacing = 12.f;

@interface RCDOpenClawBotActionCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong, readwrite) UIButton *actionButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) MASConstraint *actionButtonWidthConstraint;

@end

@implementation RCDOpenClawBotActionCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDOpenClawBotActionCell *cell =
        (RCDOpenClawBotActionCell *)[tableView dequeueReusableCellWithIdentifier:RCDOpenClawBotActionCellIdentifier];
    if (!cell) {
        cell = [[RCDOpenClawBotActionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:RCDOpenClawBotActionCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    self.hideSeparatorLine = NO;
    [self setActionButtonVisible:YES];
    [self configureDeleteActionButton];
}

- (void)configureWithName:(NSString *)name portraitUri:(NSString *)portraitUri {
    [self setActionButtonVisible:NO];
    self.nameLabel.textColor = RCDynamicColor(@"text_primary_color", @"0x111f2c", @"0x9f9f9f");
    self.nameLabel.text = name;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                       placeholderImage:[UIImage imageNamed:@"openclaw_assistant_logo"]];
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.avatarView];
    [self.containerView addSubview:self.nameLabel];
    [self.containerView addSubview:self.actionButton];
    [self.containerView addSubview:self.separatorLine];

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(RCDOpenClawBotActionCellOuterPadding);
        make.right.equalTo(self.contentView).offset(-RCDOpenClawBotActionCellOuterPadding);
        make.top.bottom.equalTo(self.contentView);
    }];

    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.left.equalTo(self.containerView).offset(RCDOpenClawBotActionCellInnerPadding);
        make.height.width.offset(RCDOpenClawBotActionCellAvatarWidth);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.left.equalTo(self.avatarView.mas_right).offset(RCDOpenClawBotActionCellSpacing);
        make.right.lessThanOrEqualTo(self.actionButton.mas_left).offset(-RCDOpenClawBotActionCellSpacing);
    }];

    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView.mas_right).offset(-3);
        make.centerY.equalTo(self.containerView);
        self.actionButtonWidthConstraint = make.width.greaterThanOrEqualTo(@45);
        make.height.offset(RCDOpenClawBotActionCellButtonHeight);
    }];

    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(60);
        make.right.equalTo(self.containerView).offset(-10);
        make.bottom.equalTo(self.containerView);
        make.height.offset(1);
    }];
}

- (void)setActionButtonVisible:(BOOL)visible {
    self.actionButton.hidden = !visible;
    self.actionButton.enabled = visible;
    [self.actionButtonWidthConstraint uninstall];
    [self.actionButton mas_updateConstraints:^(MASConstraintMaker *make) {
        self.actionButtonWidthConstraint = visible ? make.width.greaterThanOrEqualTo(@45) : make.width.offset(0);
    }];
}

- (void)configureDeleteActionButton {
    UIImage *deleteImage = RCDynamicImage(@"group_follow_remove_btn_img", @"group_follow_remove_btn");
    [self.actionButton setImage:deleteImage forState:UIControlStateNormal];
    [self.actionButton setTitle:nil forState:UIControlStateNormal];
    self.actionButton.layer.borderWidth = 0;
    self.actionButton.layer.cornerRadius = 0;
    self.actionButton.backgroundColor = [UIColor clearColor];
    if ([RCKitUtility isRTL]) {
        self.actionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 22);
    } else {
        self.actionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 22, 0, 0);
    }
}

- (void)configureAddActionButtonWithTitle:(NSString *)title enabled:(BOOL)enabled {
    [self setActionButtonVisible:YES];
    [self.actionButton setImage:nil forState:UIControlStateNormal];
    [self.actionButton setTitle:title forState:UIControlStateNormal];
    self.actionButton.enabled = enabled;
    self.actionButton.layer.borderWidth = 0;
    self.actionButton.layer.cornerRadius = 0;
    self.actionButton.backgroundColor = [UIColor clearColor];
    self.actionButton.contentEdgeInsets = UIEdgeInsetsZero;
    UIColor *titleColor = enabled ? RCDDYCOLOR(0x2f73ff, 0x2f73ff) : RCDDYCOLOR(0x939393, 0x666666);
    [self.actionButton setTitleColor:titleColor forState:UIControlStateNormal];
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [UIImageView new];
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _avatarView.layer.cornerRadius = RCDOpenClawBotActionCellAvatarWidth / 2;
        } else {
            _avatarView.layer.cornerRadius = 5.f;
        }
        _avatarView.layer.masksToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:17.f];
        _nameLabel.textColor = RCDynamicColor(@"text_primary_color", @"0x111f2c", @"0x9f9f9f");
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.textAlignment = NSTextAlignmentNatural;
    }
    return _nameLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
    }
    return _actionButton;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = RCDynamicColor(@"common_background_color", @"0xffffff", @"0x1c1c1e");
    }
    return _containerView;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = RCDynamicColor(@"line_background_color", @"0xE3E5E6", @"0x272727");
    }
    return _separatorLine;
}

- (void)setHideSeparatorLine:(BOOL)hideSeparatorLine {
    _hideSeparatorLine = hideSeparatorLine;
    self.separatorLine.hidden = hideSeparatorLine;
}

@end
