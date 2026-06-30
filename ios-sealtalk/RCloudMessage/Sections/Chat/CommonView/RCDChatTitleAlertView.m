//
//  RCDTitleAlertView.m
//  SealTalk
//
//  Created by lizhipeng on 2022/4/18.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDChatTitleAlertView.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>

static int padding = 12 ;

@implementation RCDChatTitleAlertView

- (instancetype)initWithFrame:(CGRect)frame titleAlertMessage:(NSString *)message {
    self = [super initWithFrame:frame] ;
    if (self) {
        // 创建提示Label
        [self setupTitleTipLabel:message] ;
    }
    return self;
}

- (instancetype)initWithTitleAlertMessage:(NSString *)message {
    self = [super init] ;
    if (self) {
        // 创建提示Label
        [self setupTitleTipLabel:message] ;
    }
    return self;
}

- (void)setupTitleTipLabel:(NSString *)message {
    if (message) {
        UILabel *titleAlertLabel = [UILabel new];
        titleAlertLabel.text = message ;
        titleAlertLabel.textColor =  RCDynamicColor(@"text_primary_color", @"0x020814", @"0xFFFFFF");
        titleAlertLabel.font = [UIFont systemFontOfSize:16] ;
        titleAlertLabel.numberOfLines = 0 ;
        [self addSubview:titleAlertLabel] ;
        [titleAlertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(padding);
            make.right.bottom.equalTo(self).inset(padding) ;
        }];
    }

    self.backgroundColor = RCDynamicColor(@"network_Indicator_view_bg_color", @"0xffdfdf", @"0x7D2C2C");
    
}

@end
