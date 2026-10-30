//
//  RCCombineV2MessageCell.m
//  RongIMKit
//
//  Created by liyan on 2019/8/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDCombineV2MessageCell.h"
#import "RCDCombineV2Utility.h"

#define RCCOMBINECELLWIDTH 230.0f
#define RCCOMBINEBACKVIEWLEFT 12.0f
#define RCCOMBINETITLELABLETOP 6.0f
#define RCCOMBINETITLELABLEHEIGHT 24.0f
#define RCCOMBINECONTENTLABELTOPSPACE 4.0f
#define RCCOMBINECONTENTLABELSINGLEHEIGHT 18.5f
#define RCCOMBINELINEVIEWTOPSPACE 10.0f
#define RCCOMBINELINEVIEWHEIGHT 0.5f
#define RCCOMBINEHISTORYLABELTOPSPACE 4.0f
#define RCCOMBINEHISTORYLABELHEIGHT 16.5f
#define RCCOMBINEHISTORYLABELBOTTOMSPACE 6.0f
#define RCCOMBINECELLHEIGHTOVERCONTENTLABEL (RCCOMBINETITLELABLETOP + RCCOMBINETITLELABLEHEIGHT + RCCOMBINECONTENTLABELTOPSPACE + RCCOMBINELINEVIEWTOPSPACE + RCCOMBINELINEVIEWHEIGHT + RCCOMBINEHISTORYLABELTOPSPACE + RCCOMBINEHISTORYLABELHEIGHT + RCCOMBINEHISTORYLABELBOTTOMSPACE)
#define CONTENTLINESPACE 5
#define RCCOMBINEREACTIONCARDVERTICALINSET 12.0f
#define RCCOMBINEREACTIONCARDHORIZONTALINSET 8.0f

@interface RCDCombineV2MessageCell ()

@property (nonatomic, strong) UILabel *lineLable;

- (BOOL)rcd_hasVisibleReactions;
+ (BOOL)rcd_hasVisibleReactionsForModel:(RCMessageModel *)model;

@end

@implementation RCDCombineV2MessageCell

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Super Methods

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height;
    RCCombineV2Message *combineMessage = (RCCombineV2Message *)model.content;
    __messagecontentview_height = [RCDCombineV2MessageCell calculateCellHeight:combineMessage];
    if ([RCDCombineV2MessageCell rcd_hasVisibleReactionsForModel:model]) {
        __messagecontentview_height += RCCOMBINEREACTIONCARDVERTICALINSET * 2;
    }
    if (__messagecontentview_height < RCKitConfigCenter.ui.globalMessagePortraitSize.height) {
        __messagecontentview_height = RCKitConfigCenter.ui.globalMessagePortraitSize.height;
    }
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (void)setDataModel:(RCMessageModel *)model {
    if (!model) {
        return;
    }
    [super setDataModel:model];
    [self resetSubViews];
    RCCombineV2Message *combineMessage = (RCCombineV2Message *)model.content;
    [self calculateContenViewSize:combineMessage];
    NSString *title = [RCDCombineV2Utility getCombineMessageTitle:combineMessage];
    self.titleLabel.text = title;
    NSString *summaryContent = [RCDCombineV2Utility getCombineMessageSummaryContent:combineMessage];
    NSMutableAttributedString *attriString =
    [[NSMutableAttributedString alloc] initWithString:summaryContent];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:CONTENTLINESPACE];//设置行间距
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    if([RCKitUtility isRTL]){
        paragraphStyle.alignment = NSTextAlignmentRight;
    }else{
        paragraphStyle.alignment = NSTextAlignmentLeft;
    }
    [attriString addAttribute:NSParagraphStyleAttributeName
                        value:paragraphStyle
                        range:NSMakeRange(0, [summaryContent length])];
    self.contentLabel.attributedText = attriString;
    [self updateStatusContentView:self.model];
    [self setDestructViewLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateCombineCardLayoutIfNeeded];
}

- (UIImage *)getDefaultMessageCellBackgroundImage {
    if (self.model.messageDirection == MessageDirection_SEND && [self rcd_hasVisibleReactions]) {
        UIImage *bubbleImage = RCDynamicImage(@"conversation_msg_cell_bg_to_img", @"chat_to_bg_normal");
        if (bubbleImage.imageAsset) {
            bubbleImage = [bubbleImage.imageAsset imageWithTraitCollection:self.traitCollection];
        }
        if ([RCKitUtility isRTL]) {
            bubbleImage = [bubbleImage imageFlippedForRightToLeftLayoutDirection];
        }
        return [RCDCombineV2MessageCell resizableBubbleImage:bubbleImage];
    }
    return [super getDefaultMessageCellBackgroundImage];
}

#pragma mark - Private Methods

+ (UIImage *)resizableBubbleImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    CGFloat halfWidth = image.size.width * 0.5;
    CGFloat halfHeight = image.size.height * 0.5;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(halfHeight, halfWidth, halfHeight, halfWidth)];
}

+ (CGFloat)calculateCellHeight:(RCCombineV2Message *)combineMessage {
    CGFloat height = RCCOMBINECELLHEIGHTOVERCONTENTLABEL;
    NSString *summary = [RCDCombineV2Utility getCombineMessageSummaryContent:combineMessage];
    CGSize size = [self getTextDrawingSize:summary
                                      font:[[RCKitConfig defaultConfig].font fontOfAnnotationLevel]
                           constrainedSize:CGSizeMake(RCCOMBINECELLWIDTH - 25, 9999) lineSpace:CONTENTLINESPACE];
    height += ceilf(size.height);
    if (height > RCCOMBINECELLHEIGHTOVERCONTENTLABEL + RCCOMBINECONTENTLABELSINGLEHEIGHT * 4) {
        height = RCCOMBINECELLHEIGHTOVERCONTENTLABEL + RCCOMBINECONTENTLABELSINGLEHEIGHT * 4;
    }
    return height;
}

+ (CGSize)getTextDrawingSize:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize lineSpace:(NSInteger)lineSpace{
    if (text.length <= 0) {
        return CGSizeZero;
    }

    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyle.lineSpacing = lineSpace;
        NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle};

        return [text boundingRectWithSize:constrainedSize
                                  options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                               attributes:attributes
                                  context:nil].size;
    }
    return CGSizeZero;
}

- (void)initialize {
    [self showBubbleBackgroundView:YES];
    [self.messageContentView addSubview:self.backView];
    [self.backView addSubview:self.titleLabel];
    [self.backView addSubview:self.contentLabel];
    [self.backView addSubview:self.lineLable];
    [self.backView addSubview:self.historyLabel];
}

- (void)resetSubViews {
    self.titleLabel.text = nil;
    self.contentLabel.text = nil;
}

- (void)calculateContenViewSize:(RCCombineV2Message *)combineMessage {
    CGFloat messageContentViewHeight = [RCDCombineV2MessageCell calculateCellHeight:combineMessage];
    if ([self rcd_hasVisibleReactions]) {
        messageContentViewHeight += RCCOMBINEREACTIONCARDVERTICALINSET * 2;
    }
    self.messageContentView.contentSize = CGSizeMake(RCCOMBINECELLWIDTH, messageContentViewHeight);
    [self autoLayoutSubViews];
}

- (void)autoLayoutSubViews {
    BOOL usesReactionCard = [self rcd_hasVisibleReactions];
    if(self.model.messageDirection == MessageDirection_RECEIVE || usesReactionCard){
        [self.titleLabel setTextColor:[RCKitUtility generateDynamicColor:HEXCOLOR(0x111f2c) darkColor:RCMASKCOLOR(0xffffff, 0.8)]];
        self.lineLable.backgroundColor = RCDYCOLOR(0xe3e5e6,0x383838);
        self.contentLabel.textColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xa0a5ab) darkColor:RCMASKCOLOR(0xffffff, 0.4)];
        self.historyLabel.textColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xa0a5ab) darkColor:RCMASKCOLOR(0xffffff, 0.7)];
    }else{
        [self.titleLabel setTextColor:RCDYCOLOR(0x111f2c, 0x040A0F)];
        self.lineLable.backgroundColor = RCDYCOLOR(0xe3e5e6,0x8EC4E9);
        self.contentLabel.textColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xa0a5ab) darkColor:RCMASKCOLOR(0x040a0f, 0.5)];
        self.historyLabel.textColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xa0a5ab) darkColor:RCMASKCOLOR(0x040a0f, 0.7)];
    }
    [self updateCombineCardStyle:usesReactionCard];
    [self updateCombineCardLayoutIfNeeded];
}

- (void)updateCombineCardStyle:(BOOL)usesReactionCard {
    if (usesReactionCard) {
        self.backView.backgroundColor = RCDynamicColor(@"file_quote_card_background", @"0xffffff", @"0x1f1f1f");
        self.backView.layer.cornerRadius = 6;
        self.backView.layer.borderWidth = 0.5;
        self.backView.layer.borderColor = RCDynamicColor(@"line_background_color", @"0xE2E4E5", @"0x3a3a3a").CGColor;
        self.backView.layer.masksToBounds = YES;
    } else {
        self.backView.backgroundColor = UIColor.clearColor;
        self.backView.layer.cornerRadius = 0;
        self.backView.layer.borderWidth = 0;
        self.backView.layer.borderColor = UIColor.clearColor.CGColor;
        self.backView.layer.masksToBounds = NO;
    }
}

- (void)updateCombineCardLayoutIfNeeded {
    BOOL usesReactionCard = [self rcd_hasVisibleReactions];
    RCCombineV2Message *combineMessage = [self.model.content isKindOfClass:[RCCombineV2Message class]] ? (RCCombineV2Message *)self.model.content : nil;
    if (!combineMessage) {
        return;
    }
    CGFloat contentWidth = CGRectGetWidth(self.messageContentView.bounds);
    if (contentWidth <= 0) {
        contentWidth = self.messageContentView.contentSize.width;
    }
    CGFloat verticalInset = usesReactionCard ? RCCOMBINEREACTIONCARDVERTICALINSET : 0;
    CGFloat cardHeight = [RCDCombineV2MessageCell calculateCellHeight:combineMessage];
    self.backView.frame = CGRectMake(RCCOMBINEBACKVIEWLEFT, 0,
                                     MAX(contentWidth - RCCOMBINEBACKVIEWLEFT * 2, 0),
                                     cardHeight);
    if (usesReactionCard) {
        CGRect frame = self.backView.frame;
        frame.origin.y = verticalInset;
        self.backView.frame = frame;
    }
    CGFloat contentInset = usesReactionCard ? RCCOMBINEREACTIONCARDHORIZONTALINSET : 0;
    CGFloat contentAreaWidth = MAX(self.backView.frame.size.width - contentInset * 2, 0);
    self.titleLabel.frame = CGRectMake(contentInset, RCCOMBINETITLELABLETOP, contentAreaWidth, RCCOMBINETITLELABLEHEIGHT);
    self.contentLabel.frame = CGRectMake(contentInset, CGRectGetMaxY(self.titleLabel.frame)+RCCOMBINECONTENTLABELTOPSPACE, contentAreaWidth, cardHeight - RCCOMBINECELLHEIGHTOVERCONTENTLABEL);
    self.lineLable.frame = CGRectMake(contentInset, CGRectGetMaxY(self.contentLabel.frame) + RCCOMBINELINEVIEWTOPSPACE, contentAreaWidth, RCCOMBINELINEVIEWHEIGHT);
    self.historyLabel.frame = CGRectMake(contentInset, CGRectGetMaxY(self.lineLable.frame) + RCCOMBINEHISTORYLABELTOPSPACE, contentAreaWidth, RCCOMBINEHISTORYLABELHEIGHT);
}

- (BOOL)rcd_hasVisibleReactions {
    return [RCDCombineV2MessageCell rcd_hasVisibleReactionsForModel:self.model];
}

+ (BOOL)rcd_hasVisibleReactionsForModel:(RCMessageModel *)model {
    if (!RCKitConfigCenter.message.enableMessageReaction) {
        return NO;
    }
    for (RCMessageReaction *reaction in model.messageReactions) {
        if (reaction.reactionId.length > 0 && reaction.totalCount > 0) {
            return YES;
        }
    }
    return NO;
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        DebugLog(@"long press end");
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(didLongTouchMessageCell:inView:)]) {
            [self.delegate didLongTouchMessageCell:self.model inView:self.backView];
        }
    }
}

#pragma mark - Getters and Setters
- (RCBaseView *)backView {
    if (!_backView) {
        _backView = [[RCBaseView alloc] initWithFrame:CGRectZero];
        _backView.userInteractionEnabled = NO;
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}

- (RCBaseLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[RCBaseLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [[RCKitConfig defaultConfig].font fontOfSecondLevel];
        _titleLabel.numberOfLines = 1;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (RCBaseLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[RCBaseLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [[RCKitConfig defaultConfig].font fontOfAnnotationLevel];
        _contentLabel.numberOfLines = 0;
        [_contentLabel sizeToFit];
        _contentLabel.backgroundColor = [UIColor clearColor];
    }
    return _contentLabel;
}

- (UILabel *)lineLable {
    if (!_lineLable) {
        _lineLable = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _lineLable;
}

- (RCBaseLabel *)historyLabel {
    if (!_historyLabel) {
        _historyLabel = [[RCBaseLabel alloc] initWithFrame:CGRectZero];
        _historyLabel.font = [[RCKitConfig defaultConfig].font fontOfAnnotationLevel];
        _historyLabel.numberOfLines = 1;
        _historyLabel.backgroundColor = [UIColor clearColor];
        _historyLabel.text = RCLocalizedString(@"ChatHistory");
    }
    return _historyLabel;
}
@end
