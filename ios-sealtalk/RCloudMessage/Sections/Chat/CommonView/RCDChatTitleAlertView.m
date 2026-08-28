//
//  RCDTitleAlertView.m
//  SealTalk
//
//  Created by lizhipeng on 2022/4/18.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDChatTitleAlertView.h"
#import <Masonry/Masonry.h>

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
        titleAlertLabel.textColor = [UIColor whiteColor] ;
        titleAlertLabel.font = [UIFont systemFontOfSize:16] ;
        titleAlertLabel.numberOfLines = 0 ;
        [self addSubview:titleAlertLabel] ;
        [titleAlertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(padding);
            make.right.bottom.equalTo(self).inset(padding) ;
        }];
    }

    self.backgroundColor = [UIColor colorWithRed:169/255.0 green:56/255.0 blue:56/255.0 alpha:1] ;
    
}

@end
