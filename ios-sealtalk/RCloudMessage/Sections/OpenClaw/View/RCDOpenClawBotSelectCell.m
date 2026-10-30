//
//  RCDOpenClawBotSelectCell.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/14.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotSelectCell.h"
#import "RCDUtilities.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

NSString *const RCDOpenClawBotSelectCellIdentifier = @"RCDOpenClawBotSelectCellIdentifier";
CGFloat const RCDOpenClawBotSelectCellHeight = 54.f;

static CGFloat const RCDOpenClawBotSelectCellHorizontalPadding = 16.f;
static CGFloat const RCDOpenClawBotSelectCellSelectSize = 20.f;
static CGFloat const RCDOpenClawBotSelectCellAvatarSize = 32.f;
static CGFloat const RCDOpenClawBotSelectCellStackSpacing = 12.f;

@interface RCDOpenClawBotSelectCell ()

@property (nonatomic, strong) UIImageView *selectIcon;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation RCDOpenClawBotSelectCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDOpenClawBotSelectCell *cell =
        (RCDOpenClawBotSelectCell *)[tableView dequeueReusableCellWithIdentifier:RCDOpenClawBotSelectCellIdentifier];
    if (!cell) {
        cell = [[RCDOpenClawBotSelectCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:RCDOpenClawBotSelectCellIdentifier];
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

- (void)configureWithName:(NSString *)name portraitUri:(NSString *)portraitUri {
    [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                              placeholderImage:[UIImage imageNamed:@"openclaw_assistant_logo"]];
    self.nameLabel.text = name;
}

- (void)setCellSelectState:(RCDOpenClawBotSelectCellState)state {
    self.userInteractionEnabled = YES;
    if (state == RCDOpenClawBotSelectCellStateDisable) {
        self.userInteractionEnabled = NO;
        self.selectIcon.image = RCDynamicImage(@"group_member_disable_select_img", @"disable_select");
    } else if (state == RCDOpenClawBotSelectCellStateUnselected) {
        self.selectIcon.image = RCDynamicImage(@"conversation_msg_cell_unselect_img", @"message_cell_unselect");
    } else if (state == RCDOpenClawBotSelectCellStateSelected) {
        self.selectIcon.image = RCDynamicImage(@"conversation_msg_cell_select_img", @"message_cell_select");
    }
}

- (void)addSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.selectIcon];
    [self.containerView addSubview:self.portraitImageView];
    [self.containerView addSubview:self.nameLabel];
    [self.containerView addSubview:self.separatorLine];

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(RCDOpenClawBotSelectCellHorizontalPadding);
        make.right.equalTo(self.contentView).offset(-RCDOpenClawBotSelectCellHorizontalPadding);
        make.top.bottom.equalTo(self.contentView);
    }];

    [self.selectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.left.equalTo(self.containerView).offset(RCDOpenClawBotSelectCellHorizontalPadding);
        make.height.width.offset(RCDOpenClawBotSelectCellSelectSize);
    }];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.left.equalTo(self.selectIcon.mas_right).offset(RCDOpenClawBotSelectCellStackSpacing);
        make.height.width.offset(RCDOpenClawBotSelectCellAvatarSize);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.left.equalTo(self.portraitImageView.mas_right).offset(RCDOpenClawBotSelectCellStackSpacing);
        make.right.lessThanOrEqualTo(self.containerView).offset(-RCDOpenClawBotSelectCellHorizontalPadding);
    }];
    
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(80);
        make.right.equalTo(self.containerView).offset(-10);
        make.bottom.equalTo(self.containerView);
        make.height.offset(1);
    }];
}

- (UIImageView *)selectIcon {
    if (!_selectIcon) {
        _selectIcon = [[UIImageView alloc] init];
        _selectIcon.contentMode = UIViewContentModeCenter;
        [self setCellSelectState:RCDOpenClawBotSelectCellStateUnselected];
    }
    return _selectIcon;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = RCDOpenClawBotSelectCellAvatarSize / 2.f;
        } else {
            _portraitImageView.layer.cornerRadius = 5.f;
        }
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = RCDynamicColor(@"text_primary_color", @"0x111f2c", @"0x9f9f9f");
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
