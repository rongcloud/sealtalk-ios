//
//  RCDContactCardMessageCellReferenceContentView.m
//  RCloudMessage
//
//  Created by RongCloud on 2026/6/15.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDContactCardMessageCellReferenceContentView.h"
#import "DefaultPortraitView.h"
#import "RCDUtilities.h"
#import <RongContactCard/RongContactCard.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface RCDContactCardMessageCellReferenceContentView ()
@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@end

@interface RCDContactCardInputReferenceView ()
@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation RCDContactCardInputReferenceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setContactCardMessage:(RCContactCardMessage *)message {
    NSString *name = message.name.length > 0 ? message.name : @"个人名片";
    NSString *userId = message.userId ?: @"";
    self.titleLabel.text = @"引用名片";
    self.nameLabel.text = name;
    self.userIdLabel.text = userId.length > 0 ? [NSString stringWithFormat:@"ID: %@", userId] : @"";

    UIImage *placeholder = [DefaultPortraitView portraitView:userId name:name];
    if (message.portraitUri.length > 0) {
        [self.portraitView sd_setImageWithURL:[NSURL URLWithString:message.portraitUri] placeholderImage:placeholder];
    } else {
        self.portraitView.image = placeholder ?: [RCDUtilities imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"];
    }
}

- (void)setReferencedMessageModel:(RCMessageModel *)messageModel {
    [super setReferencedMessageModel:messageModel];
    if ([messageModel.content isKindOfClass:[RCContactCardMessage class]]) {
        [self setContactCardMessage:(RCContactCardMessage *)messageModel.content];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat portraitSize = 40;
    CGFloat portraitX = 12;
    CGFloat portraitY = (CGRectGetHeight(self.bounds) - portraitSize) / 2.0;
    self.portraitView.frame = CGRectMake(portraitX, portraitY, portraitSize, portraitSize);

    CGFloat closeWidth = 40;
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - closeWidth - 4,
                                        (CGRectGetHeight(self.bounds) - closeWidth) / 2.0,
                                        closeWidth,
                                        closeWidth);

    CGFloat textX = CGRectGetMaxX(self.portraitView.frame) + 10;
    CGFloat textWidth = MAX(CGRectGetMinX(self.closeButton.frame) - textX - 8, 0);
    self.titleLabel.frame = CGRectMake(textX, MAX(5, portraitY - 3), textWidth, 16);
    self.nameLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame), textWidth, 19);
    self.userIdLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.nameLabel.frame), textWidth, 16);
}

- (void)setupSubviews {
    [self addSubview:self.portraitView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.userIdLabel];
    [self addSubview:self.closeButton];
}

- (void)closeButtonClicked {
    if (self.cancelHandler) {
        self.cancelHandler();
    }
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _portraitView.contentMode = UIViewContentModeScaleAspectFill;
        _portraitView.clipsToBounds = YES;
        _portraitView.layer.cornerRadius = 5;
    }
    return _portraitView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.textColor = [RCDUtilities generateDynamicColor:[UIColor colorWithRed:0.45 green:0.48 blue:0.52 alpha:1]
                                                        darkColor:[UIColor colorWithWhite:1 alpha:0.55]];
    }
    return _titleLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _nameLabel.textColor = [RCDUtilities generateDynamicColor:[UIColor colorWithRed:0.08 green:0.12 blue:0.16 alpha:1]
                                                        darkColor:[UIColor colorWithWhite:1 alpha:0.9]];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _nameLabel;
}

- (UILabel *)userIdLabel {
    if (!_userIdLabel) {
        _userIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userIdLabel.font = [UIFont systemFontOfSize:11];
        _userIdLabel.textColor = [RCDUtilities generateDynamicColor:[UIColor colorWithRed:0.45 green:0.48 blue:0.52 alpha:1]
                                                         darkColor:[UIColor colorWithWhite:1 alpha:0.55]];
        _userIdLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _userIdLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"×" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[RCDUtilities generateDynamicColor:[UIColor colorWithRed:0.45 green:0.48 blue:0.52 alpha:1]
                                                              darkColor:[UIColor colorWithWhite:1 alpha:0.55]]
                            forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightRegular];
        [_closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end

@implementation RCDContactCardMessageCellReferenceContentView

+ (CGSize)sizeForReferencedContent:(RCMessageContent *)referencedContent
                       messageModel:(RCMessageModel *)messageModel
                           maxWidth:(CGFloat)maxWidth {
    return CGSizeMake(MIN(MAX(maxWidth, 0), 220), 48);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setReferencedContent:(RCMessageContent *)referencedContent
                messageModel:(RCMessageModel *)messageModel {
    [super setReferencedContent:referencedContent messageModel:messageModel];
    if (![referencedContent isKindOfClass:[RCContactCardMessage class]]) {
        return;
    }
    RCContactCardMessage *cardMessage = (RCContactCardMessage *)referencedContent;
    NSString *name = cardMessage.name.length > 0 ? cardMessage.name : @"个人名片";
    NSString *userId = cardMessage.userId ?: @"";
    self.titleLabel.text = @"名片";
    self.nameLabel.text = name;
    self.userIdLabel.text = userId.length > 0 ? [NSString stringWithFormat:@"ID: %@", userId] : @"";

    UIImage *placeholder = [DefaultPortraitView portraitView:userId name:name];
    if (cardMessage.portraitUri.length > 0) {
        [self.portraitView sd_setImageWithURL:[NSURL URLWithString:cardMessage.portraitUri] placeholderImage:placeholder];
    } else {
        self.portraitView.image = placeholder ?: [RCDUtilities imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat portraitSize = MIN(36, MAX(CGRectGetHeight(self.bounds) - 12, 28));
    CGFloat portraitX = 0;
    CGFloat portraitY = (CGRectGetHeight(self.bounds) - portraitSize) / 2.0;
    self.portraitView.frame = CGRectMake(portraitX, portraitY, portraitSize, portraitSize);

    CGFloat textX = CGRectGetMaxX(self.portraitView.frame) + 8;
    CGFloat textWidth = MAX(CGRectGetWidth(self.bounds) - textX, 0);
    self.titleLabel.frame = CGRectMake(textX, MAX(2, portraitY - 2), textWidth, 16);
    self.nameLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame), textWidth, 18);
    self.userIdLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.nameLabel.frame), textWidth, 16);
}

- (void)setupSubviews {
    [self addSubview:self.portraitView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.userIdLabel];
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _portraitView.contentMode = UIViewContentModeScaleAspectFill;
        _portraitView.clipsToBounds = YES;
        _portraitView.layer.cornerRadius = 4;
    }
    return _portraitView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.textColor = [RCDUtilities generateDynamicColor:[UIColor colorWithRed:0.45 green:0.48 blue:0.52 alpha:1]
                                                        darkColor:[UIColor colorWithWhite:1 alpha:0.55]];
    }
    return _titleLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _nameLabel.textColor = [RCDUtilities generateDynamicColor:[UIColor colorWithRed:0.08 green:0.12 blue:0.16 alpha:1]
                                                        darkColor:[UIColor colorWithWhite:1 alpha:0.9]];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _nameLabel;
}

- (UILabel *)userIdLabel {
    if (!_userIdLabel) {
        _userIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userIdLabel.font = [UIFont systemFontOfSize:11];
        _userIdLabel.textColor = [RCDUtilities generateDynamicColor:[UIColor colorWithRed:0.45 green:0.48 blue:0.52 alpha:1]
                                                         darkColor:[UIColor colorWithWhite:1 alpha:0.55]];
        _userIdLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _userIdLabel;
}

@end
