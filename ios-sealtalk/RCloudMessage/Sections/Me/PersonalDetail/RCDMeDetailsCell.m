//
//  RCDMeDetailsCell.m
//  RCloudMessage
//
//  Created by Jue on 16/9/9.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMeDetailsCell.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDCommonString.h"
#import "RCDSemanticContext.h"
@implementation RCDMeDetailsCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init {
    self = [super init];
    if (self) {
        NSString *portraitUrl = [DEFAULTS stringForKey:RCDUserPortraitUriKey];
        self = [[RCDMeDetailsCell alloc] initWithLeftImageStr:portraitUrl
                                                leftImageSize:CGSizeMake(48, 48)
                                                 rightImaeStr:nil
                                               rightImageSize:CGSizeZero];
        self.leftLabel.text = [DEFAULTS stringForKey:RCDUserNickNameKey];
        self.leftLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x000000) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]];
        self.leftLabel.font = [UIFont systemFontOfSize:18];
        if ([RCDSemanticContext isRTL]) {
            self.leftLabel.textAlignment = NSTextAlignmentRight;
        }else{
            self.leftLabel.textAlignment = NSTextAlignmentLeft;
        }
        self.rightArrow.hidden = YES;
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            self.leftImageCornerRadius = 24;
        }else{
            self.leftImageCornerRadius = 5.f;
        }
        self.leftImageView.layer.masksToBounds = YES;
    }
    return self;
}

@end
