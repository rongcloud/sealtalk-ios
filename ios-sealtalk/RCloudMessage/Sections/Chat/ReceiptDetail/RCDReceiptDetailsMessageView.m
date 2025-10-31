//
//  RCDReceiptDetailsMessageView.m
//  SealTalk
//
//  Created by Lang on 10/16/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDReceiptDetailsMessageView.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import <RongLocation/RongLocation.h>

@interface RCDReceiptDetailsMessageView ()

@property (nonatomic, strong) UIView *contentView;

// UI 子视图
@property (nonatomic, strong) UILabel *senderNameLabel;      // 发送者昵称
@property (nonatomic, strong) UILabel *messageContentLabel;  // 消息内容
@property (nonatomic, strong) UILabel *fileSizeLabel;        // 文件大小（文件消息用）
@property (nonatomic, strong) UIImageView *messageImageView; // 消息图片（如果是图片消息）
@property (nonatomic, strong) UIImageView *fileIconView;     // 文件图标（文件消息用）
@property (nonatomic, strong) UILabel *timeLabel;            // 发送时间

@end

NS_ASSUME_NONNULL_BEGIN

@implementation RCDReceiptDetailsMessageView

- (void)setupView {
    [super setupView];
    
    // 添加固定的子视图到视图层级
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.senderNameLabel];
    [self.contentView addSubview:self.timeLabel];
    
    // 设置固定视图的约束
    [self setupFixedConstraints];
}

/// 设置固定视图的布局约束（只在初始化时调用一次）
- (void)setupFixedConstraints {
    // contentView 左右 16 边距
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.leading.equalTo(self).offset(16);
        make.bottom.equalTo(self).offset(-9);
        make.trailing.equalTo(self).offset(-16);
    }];
    
    // 发送者昵称在顶部，左边距 16，右边距 16，顶部边距 16
    [self.senderNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(16);
        make.leading.equalTo(self.contentView).offset(16);
        make.trailing.lessThanOrEqualTo(self.timeLabel.mas_leading).offset(-8);
        make.height.equalTo(@22);
    }];
    
    // 时间标签在右上角
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.senderNameLabel);
        make.trailing.equalTo(self.contentView).offset(-16);
    }];
}

/// 设置消息内容的布局约束（每次 setMessage 时调用）
- (void)setupMessageContentConstraints {
    // 消息内容或图片在昵称下方
    if (self.fileIconView) {
        // 文件消息布局：图标 + 名称 + 大小
        [self.fileIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.senderNameLabel.mas_bottom).offset(6);
            make.leading.equalTo(self.contentView).offset(16);
            make.width.height.equalTo(@60);
            make.bottom.equalTo(self.contentView).offset(-16);
        }];
        
        // 文件名标签在文件图标右侧
        [self.messageContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fileIconView.mas_top).offset(5);
            make.leading.equalTo(self.fileIconView.mas_trailing).offset(12);
            make.trailing.equalTo(self.contentView).offset(-16);
        }];
        
        // 文件大小标签在文件名下方
        [self.fileSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.greaterThanOrEqualTo(self.messageContentLabel.mas_bottom).offset(6);
            make.leading.equalTo(self.fileIconView.mas_trailing).offset(12);
            make.trailing.equalTo(self.contentView).offset(-16);
            make.bottom.lessThanOrEqualTo(self.fileIconView).offset(-5);
        }];
    } else if (self.messageImageView) {
        // 图片消息：60*60
        [self.messageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.senderNameLabel.mas_bottom).offset(6);
            make.leading.equalTo(self.contentView).offset(16);
            make.width.height.equalTo(@60);
            make.bottom.equalTo(self.contentView).offset(-16);
        }];
    } else if (self.messageContentLabel) {
        // 文本消息：最多两行，左边距 16，右边距 16，底部边距 16
        [self.messageContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.senderNameLabel.mas_bottom).offset(6);
            make.leading.equalTo(self.contentView).offset(16);
            make.trailing.equalTo(self.contentView).offset(-16);
            make.bottom.equalTo(self.contentView).offset(-16);
        }];
    }
}


- (void)updateMessageContent {
    // 更新发送者信息
    NSString *userId = self.message.senderUserId;
    RCUserInfo *userInfo = nil;
    if (self.message.conversationType == ConversationType_GROUP) {
        userInfo = [[RCIM sharedRCIM] getGroupUserInfoCache:userId withGroupId:self.message.targetId];
    } else {
        userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
    }
    self.senderNameLabel.text = userInfo.name ?: userId;
    
    // 更新时间
    self.timeLabel.text = self.message.sentTime > 0 ? [RCKitUtility convertMessageTime:self.message.sentTime / 1000] : @"";
    
    // 清理旧的消息内容视图
    [self cleanupMessageContentViews];
    
    // 创建新的消息内容视图
    [self setupMessageContent];
    
    // 设置消息内容的约束
    [self setupMessageContentConstraints];
}

/// 清理旧的消息内容视图
- (void)cleanupMessageContentViews {
    if (self.messageContentLabel) {
        [self.messageContentLabel removeFromSuperview];
        self.messageContentLabel = nil;
    }
    if (self.messageImageView) {
        [self.messageImageView removeFromSuperview];
        self.messageImageView = nil;
    }
    if (self.fileIconView) {
        [self.fileIconView removeFromSuperview];
        self.fileIconView = nil;
    }
    if (self.fileSizeLabel) {
        [self.fileSizeLabel removeFromSuperview];
        self.fileSizeLabel = nil;
    }
}

/// 设置消息内容（文本或图片）
- (void)setupMessageContent {
    // 根据消息类型分别处理
    if ([self.message.content isKindOfClass:[RCTextMessage class]]) {
        [self setupTextMessageContent];
    } else if ([self.message.content isKindOfClass:[RCImageMessage class]]) {
        [self setupImageMessageContent];
    } else if ([self.message.content isKindOfClass:[RCSightMessage class]]) {
        [self setupSightMessageContent];
    } else if ([self.message.content isKindOfClass:[RCGIFMessage class]]) {
        [self setupGIFMessageContent];
    } else if ([self.message.content isKindOfClass:[RCFileMessage class]]) {
        [self setupFileMessageContent];
    } else {
        [self setupOtherMessageContent];
    }
}

/// 设置文本消息内容
- (void)setupTextMessageContent {
    RCTextMessage *textMessage = (RCTextMessage *)self.message.content;
    self.messageContentLabel = [[UILabel alloc] init];
    self.messageContentLabel.font = [UIFont systemFontOfSize:14];
    self.messageContentLabel.textColor = RCDDYCOLOR(0x525A63, 0xb9b9b9);
    self.messageContentLabel.textAlignment = NSTextAlignmentNatural;
    self.messageContentLabel.numberOfLines = 2;
    self.messageContentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.messageContentLabel.text = textMessage.content;
    
    [self.contentView addSubview:self.messageContentLabel];
}

/// 设置图片消息内容
- (void)setupImageMessageContent {
    RCImageMessage *imageMessage = (RCImageMessage *)self.message.content;
    self.messageImageView = [[UIImageView alloc] init];
    [self configureImageViewStyle:self.messageImageView];
    
    if (imageMessage.thumbnailImage) {
        self.messageImageView.image = imageMessage.thumbnailImage;
    }
    
    [self.contentView addSubview:self.messageImageView];
}

/// 设置小视频消息内容
- (void)setupSightMessageContent {
    RCSightMessage *sightMessage = (RCSightMessage *)self.message.content;
    self.messageImageView = [[UIImageView alloc] init];
    [self configureImageViewStyle:self.messageImageView];
    
    if (sightMessage.thumbnailImage) {
        self.messageImageView.image = sightMessage.thumbnailImage;
    }
    
    [self.contentView addSubview:self.messageImageView];
}

/// 设置 GIF 动图消息内容
- (void)setupGIFMessageContent {
    RCGIFMessage *gifMessage = (RCGIFMessage *)self.message.content;
    
    NSString *localPath = gifMessage.localPath;
    NSData *data = [NSData dataWithContentsOfFile:[RCUtilities getCorrectedFilePath:localPath]];
    RCGIFImage *gifImage = [RCGIFImage animatedImageWithGIFData:data];
    RCGIFImageView *gifImageView = [[RCGIFImageView alloc] initWithFrame:CGRectZero];
    gifImageView.animatedImage = gifImage;
    
    self.messageImageView = gifImageView;
    [self configureImageViewStyle:self.messageImageView];
    
    [self.contentView addSubview:self.messageImageView];
}

/// 设置文件消息内容
- (void)setupFileMessageContent {
    RCFileMessage *fileMessage = (RCFileMessage *)self.message.content;
    
    // 创建文件图标
    self.fileIconView = [[UIImageView alloc] init];
    self.fileIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.fileIconView.image = [RCKitUtility imageWithFileSuffix:fileMessage.type];
    [self.contentView addSubview:self.fileIconView];
    
    // 创建文件名标签
    self.messageContentLabel = [[UILabel alloc] init];
    self.messageContentLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.messageContentLabel.textColor = RCDDYCOLOR(0x020814, 0xffffff);
    self.messageContentLabel.textAlignment = NSTextAlignmentNatural;
    self.messageContentLabel.numberOfLines = 2;
    self.messageContentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.messageContentLabel.text = fileMessage.name ?: @"文件";
    [self.contentView addSubview:self.messageContentLabel];
    
    // 创建文件大小标签
    self.fileSizeLabel = [[UILabel alloc] init];
    self.fileSizeLabel.font = [UIFont systemFontOfSize:12];
    self.fileSizeLabel.textColor = RCDDYCOLOR(0x7C838e, 0x7C838e);
    self.fileSizeLabel.textAlignment = NSTextAlignmentNatural;
    self.fileSizeLabel.text = [RCKitUtility getReadableStringForFileSize:fileMessage.size];
    [self.contentView addSubview:self.fileSizeLabel];
}

/// 设置其他消息类型内容
- (void)setupOtherMessageContent {
    self.messageContentLabel = [[UILabel alloc] init];
    self.messageContentLabel.font = [UIFont systemFontOfSize:14];
    self.messageContentLabel.textColor = RCDDYCOLOR(0x525A63, 0xb9b9b9);
    self.messageContentLabel.textAlignment = NSTextAlignmentNatural;
    self.messageContentLabel.numberOfLines = 2;
    self.messageContentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.messageContentLabel.text = [self getMessageContentDescription:self.message];
    
    [self.contentView addSubview:self.messageContentLabel];
}

/// 配置图片视图样式（通用）
- (void)configureImageViewStyle:(UIImageView *)imageView {
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 2;
}


/// 获取消息内容描述（用于非文本、非图片消息）
- (NSString *)getMessageContentDescription:(RCMessageModel *)message {
    if ([message.content isKindOfClass:[RCVoiceMessage class]] || [message.content isKindOfClass:[RCHQVoiceMessage class]]) {
        return RCDLocalizedString(@"voice");
    } else if ([message.content isKindOfClass:[RCLocationMessage class]]) {
        return RCDLocalizedString(@"location");
    } else if ([message.content isKindOfClass:[RCCombineMessage class]]) {
        return RCLocalizedString([RCCombineMessage getObjectName]);
    }
    return [NSString stringWithFormat:@"[%@]",RCDLocalizedString(@"MessageTypeOthers")];
}

#pragma mark - Getter (懒加载)

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = RCDDYCOLOR(0xFFFFFF, 0x141414);
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UILabel *)senderNameLabel {
    if (!_senderNameLabel) {
        _senderNameLabel = [[UILabel alloc] init];
        _senderNameLabel.font = [UIFont systemFontOfSize:14];
        _senderNameLabel.textColor = RCDDYCOLOR(0x252525, 0x9f9f9f);
        _senderNameLabel.textAlignment = NSTextAlignmentNatural;
        _senderNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        // 设置内容压缩和扩展优先级，确保在空间不足时名字被截断而不是时间标签
        [_senderNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_senderNameLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _senderNameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = RCDDYCOLOR(0x7C838e, 0x7C838e);
        _timeLabel.textAlignment = NSTextAlignmentNatural;
        
        // 设置更高的内容压缩抵抗优先级，确保时间标签始终完整显示
        [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _timeLabel;
}

#pragma mark - Setter

- (void)setMessage:(RCMessageModel *)message {
    _message = message;
    
    [self updateMessageContent];
}

@end

NS_ASSUME_NONNULL_END
