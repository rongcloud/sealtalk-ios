//
//  RCDLocalMessagesQueryView.m
//  SealTalk
//
//  Created by RobinCui on 2022/9/23.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDLocalMessagesQueryView.h"

#import <Masonry/Masonry.h>

@interface RCDLocalMessagesQueryView()
@property (nonatomic, strong, readwrite) UIButton *btnQuery;
@property (nonatomic, strong, readwrite) UITextField *txtTargetID;
@property (nonatomic, strong, readwrite) UITextField *txtChannelID;
@property (nonatomic, strong, readwrite) UITextField *txtTime;
@property (nonatomic, strong, readwrite) UITextField *txtCount;
@property (nonatomic, strong, readwrite) UITextField *txtMessageUID;

@property (nonatomic, strong, readwrite) UILabel *labTips;

@end
@implementation RCDLocalMessagesQueryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    UILabel *labTargetID = [self labelWithText:@"Target ID: "];
    [self addSubview:labTargetID];
    [labTargetID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(12);
        make.top.mas_equalTo(self).mas_offset(30);
    }];
    
    UITextField *txtTargetID = [self textFiledWith:@"会话ID"];
    self.txtTargetID = txtTargetID;
    [self addSubview:txtTargetID];
    [txtTargetID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(labTargetID);
        make.left.mas_equalTo(labTargetID.mas_right).mas_offset(10);
        make.right.mas_equalTo(self).mas_offset(-12);
    }];
    
    UILabel *labChannelID = [self labelWithText:@"Channel ID: "];
    [self addSubview:labChannelID];
    [labChannelID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(labTargetID);
        make.top.mas_equalTo(txtTargetID.mas_bottom).mas_offset(20);
    }];
    
    UITextField *txtChannelID = [self textFiledWith:@"频道ID"];
    self.txtChannelID = txtChannelID;
    [self addSubview:txtChannelID];
    [txtChannelID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(labChannelID);
        make.left.width.mas_equalTo(txtTargetID);
    }];
    
    UILabel *labTime = [self labelWithText:@"Send Time: "];
    [self addSubview:labTime];
    [labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(labTargetID);
        make.top.mas_equalTo(txtChannelID.mas_bottom).mas_offset(20);
    }];
    
    UITextField *txtTime = [self textFiledWith:@"发送时间, 0 表示从第一条查起"];
    self.txtTime = txtTime;
    [self addSubview:txtTime];
    [txtTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(labTime);
        make.left.width.mas_equalTo(txtTargetID);
    }];
    
    UILabel *labCount = [self labelWithText:@"Count: "];
    [self addSubview:labCount];
    [labCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(labTargetID);
        make.top.mas_equalTo(txtTime.mas_bottom).mas_offset(20);
    }];
    
    UITextField *txtCount = [self textFiledWith:@"查询数量 1 -- 50"];
    txtCount.keyboardType = UIKeyboardTypePhonePad;
    self.txtCount = txtCount;
    [self addSubview:txtCount];
    [txtCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(labCount);
        make.left.width.mas_equalTo(txtTargetID);
    }];
    UILabel *labUID = [self labelWithText:@"UID: "];
    [self addSubview:labUID];
    [labUID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(labTargetID);
        make.top.mas_equalTo(labCount.mas_bottom).mas_offset(20);
    }];
    
    UITextField *txtMessageUID = [self textFiledWith:@"冗余UID, 逗号分割"];
    self.txtMessageUID = txtMessageUID;
    [self addSubview:txtMessageUID];
    [txtMessageUID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(labUID);
        make.left.width.mas_equalTo(txtTargetID);
    }];
    
    [self addSubview:self.btnQuery];
    [self.btnQuery mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(txtMessageUID.mas_bottom).mas_offset(40);
        make.left.mas_equalTo(self).mas_offset(12);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *labTips = [self labelWithText:@""];
    labTips.numberOfLines = 0;
    self.labTips = labTips;
    [self addSubview:labTips];
    [labTips mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.btnQuery.mas_bottom).mas_offset(10);
            make.width.centerX.mas_equalTo(self.btnQuery);
    }];
}

- (void)hideKeyboardIfNeed {
    [self.txtTargetID resignFirstResponder];
    [self.txtChannelID resignFirstResponder];
    [self.txtTime resignFirstResponder];
    [self.txtCount resignFirstResponder];
    [self.txtMessageUID resignFirstResponder];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self hideKeyboardIfNeed];
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *lab = [UILabel new];
    lab.text = text;
    return lab;
}

- (UITextField *)textFiledWith:(NSString *)placeholder {
    UITextField *txt = [UITextField new];
    txt.placeholder = placeholder;
    txt.borderStyle = UITextBorderStyleLine;
    return txt;
}

- (UIButton *)btnQuery {
    if (!_btnQuery) {
        _btnQuery = [[UIButton alloc] init];
        _btnQuery.clipsToBounds = YES;
        _btnQuery.layer.cornerRadius = 8;
        _btnQuery.backgroundColor = HEXCOLOR(0x0099ff);
        [_btnQuery setTitleColor:HEXCOLOR(0xffffff) forState:(UIControlStateNormal)];
        _btnQuery.titleLabel.font = [UIFont systemFontOfSize:17];
        [_btnQuery setTitle:@"查询" forState:UIControlStateNormal];
    }
    return _btnQuery;
}

@end
