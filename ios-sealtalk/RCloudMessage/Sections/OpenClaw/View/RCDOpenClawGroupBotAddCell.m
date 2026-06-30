//
//  RCDOpenClawGroupBotAddCell.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/14.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawGroupBotAddCell.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>

NSString *const RCDOpenClawGroupBotAddCellIdentifier = @"RCDOpenClawGroupBotAddCellIdentifier";
CGFloat const RCDOpenClawGroupBotAddCellHeight = 54.f;

static CGFloat const RCDOpenClawGroupBotCellOuterPadding = 16.f;
static CGFloat const RCDOpenClawGroupBotCellInnerPadding = 16.f;
static CGFloat const RCDOpenClawGroupBotCellAvatarSize = 32.f;
static CGFloat const RCDOpenClawGroupBotCellSpacing = 12.f;

@interface RCDOpenClawGroupBotAddCell ()

@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation RCDOpenClawGroupBotAddCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDOpenClawGroupBotAddCell *cell =
        (RCDOpenClawGroupBotAddCell *)[tableView dequeueReusableCellWithIdentifier:RCDOpenClawGroupBotAddCellIdentifier];
    if (!cell) {
        cell = [[RCDOpenClawGroupBotAddCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:RCDOpenClawGroupBotAddCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title {
    self.nameLabel.text = title;
}

- (void)addSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.portraitImageView];
    [self.containerView addSubview:self.nameLabel];
    [self.containerView addSubview:self.separatorLine];

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(RCDOpenClawGroupBotCellOuterPadding);
        make.right.equalTo(self.contentView).offset(-RCDOpenClawGroupBotCellOuterPadding);
        make.top.bottom.equalTo(self.contentView);
    }];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.left.equalTo(self.containerView).offset(RCDOpenClawGroupBotCellInnerPadding);
        make.height.width.offset(RCDOpenClawGroupBotCellAvatarSize);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.left.equalTo(self.portraitImageView.mas_right).offset(RCDOpenClawGroupBotCellSpacing);
        make.right.lessThanOrEqualTo(self.containerView).offset(-RCDOpenClawGroupBotCellInnerPadding);
    }];

    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(60);
        make.right.equalTo(self.containerView).offset(-10);
        make.bottom.equalTo(self.containerView);
        make.height.offset(1);
    }];
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = RCDOpenClawGroupBotCellAvatarSize / 2.f;
        } else {
            _portraitImageView.layer.cornerRadius = 5.f;
        }
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
        _portraitImageView.image = RCDynamicImage(@"group_manage_add_member_img", @"group_manage_add_member");
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = RCDynamicColor(@"text_primary_color", @"0x020814", @"0xFFFFFF");
        _nameLabel.textAlignment = NSTextAlignmentNatural;
    }
    return _nameLabel;
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
