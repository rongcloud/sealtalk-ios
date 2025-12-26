//
//  RCUTipMessageCell.m
//  SealTalk
//
//  Created by zgh on 2024/9/14.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUTipMessageCell.h"
#import "RCUGroupNotificationMessage.h"

@implementation RCUTipMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    NSString *localizedMessage = nil;

    localizedMessage = [RCUTipMessageCell generateTipsStringForModel:model];
    if (localizedMessage.length <= 0) {
        model.isDisplayMessageTime = NO;
        return CGSizeMake(collectionViewWidth, 0);
    }

    CGFloat maxMessageLabelWidth = collectionViewWidth - 30 * 2;
    CGSize __textSize = [RCKitUtility getTextDrawingSize:localizedMessage
                                                    font:[UIFont systemFontOfSize:14.f]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 8, __textSize.height + 6);

    CGFloat __height = __labelSize.height;

    __height += extraHeight;

    return CGSizeMake(collectionViewWidth, __height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tipMessageLabel = [RCTipLabel greyTipLabel];
        self.tipMessageLabel.backgroundColor =
        [RCKitUtility generateDynamicColor:HEXCOLOR(0xc9c9c9) darkColor:HEXCOLOR(0x232323)];
        self.tipMessageLabel.textColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xffffff) darkColor:HEXCOLOR(0x707070)];
        self.tipMessageLabel.userInteractionEnabled = NO;
        self.tipMessageLabel.attributeDictionary = @{};
        [self.baseContentView addSubview:self.tipMessageLabel];
        self.tipMessageLabel.marginInsets = UIEdgeInsetsMake(0.5f, 0.5f, 0.5f, 0.5f);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onUserInfoUpdate:)
                                                     name:@"RCKitDispatchUserInfoUpdateNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onGroupUserInfoUpdate:)
                                                     name:@"RCKitDispatchGroupUserInfoUpdateNotification"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RCKitDispatchUserInfoUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RCKitDispatchGroupUserInfoUpdateNotification" object:nil];
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    self.tipMessageLabel.text = [RCUTipMessageCell generateTipsStringForModel:model];
    CGFloat maxMessageLabelWidth = self.baseContentView.bounds.size.width - 30 * 2;
    NSString *__text = self.tipMessageLabel.text;
    if (__text.length <= 0) {
        self.tipMessageLabel.frame = CGRectZero;
    } else {
        CGSize __textSize = [RCKitUtility getTextDrawingSize:__text
                                                        font:[UIFont systemFontOfSize:14.0f]
                                             constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
        __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
        CGSize __labelSize = CGSizeMake(__textSize.width + 8, __textSize.height + 6);
        CGFloat width = __labelSize.width;
        self.tipMessageLabel.frame =
            CGRectMake((self.baseContentView.bounds.size.width - width) / 2.0f, 0, width, __labelSize.height);
        
    }
}

- (void)updateDisplayContent {
    self.tipMessageLabel.text = [RCUTipMessageCell generateTipsStringForModel:self.model];
    CGFloat maxMessageLabelWidth = self.baseContentView.bounds.size.width - 30 * 2;
    NSString *__text = self.tipMessageLabel.text;
    if (__text.length <= 0) {
        self.tipMessageLabel.frame = CGRectZero;
    } else {
        CGSize __textSize = [RCKitUtility getTextDrawingSize:__text
                                                        font:[UIFont systemFontOfSize:14.0f]
                                             constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
        __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
        CGSize __labelSize = CGSizeMake(__textSize.width + 8, __textSize.height + 6);
        CGFloat width = __labelSize.width;
        self.tipMessageLabel.frame =
            CGRectMake((self.baseContentView.bounds.size.width - width) / 2.0f, 0, width, __labelSize.height);
        
    }
}

+ (NSString *)generateTipsStringForModel:(RCMessageModel *)model {
    RCUGroupNotificationMessage *message = (RCUGroupNotificationMessage *)model.content;
    return [message getDigest:model.targetId];
}

- (void)onGroupUserInfoUpdate:(NSNotification *)notification {
    if (![self.model.content isKindOfClass:RCUGroupNotificationMessage.class]) {
        return;
    }
    RCUGroupNotificationMessage *message = (RCUGroupNotificationMessage *)self.model.content;
    NSDictionary *groupUserInfoDic = (NSDictionary *)notification.object;
    NSString *userId = groupUserInfoDic[@"userId"];
    if ([userId isEqualToString:message.operatorUserId] || [message.targetUserIds containsObject:userId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDisplayContent];
        });
    }
}

- (void)onUserInfoUpdate:(NSNotification *)notification {
    if (![self.model.content isKindOfClass:RCUGroupNotificationMessage.class]) {
        return;
    }
    RCUGroupNotificationMessage *message = (RCUGroupNotificationMessage *)self.model.content;
    NSDictionary *userInfoDic = notification.object;
    RCUserInfo *updateUserInfo = userInfoDic[@"userInfo"];
    if ([updateUserInfo.userId isEqualToString:message.operatorUserId] || [message.targetUserIds containsObject:updateUserInfo.userId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDisplayContent];
        });
    }
}

@end
