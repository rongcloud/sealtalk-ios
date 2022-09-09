//
//  RCDUnreadCountView.m
//  SealTalk
//
//  Created by RobinCui on 2022/8/2.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUnreadCountView.h"
#import <Masonry/Masonry.h>

@interface RCDUnreadCountView()
@property (nonatomic, strong) UILabel *labCount;
@property (nonatomic, strong) UILabel *labType;
@property (nonatomic, strong) UILabel *labLevels;
@property (nonatomic, strong, readwrite) UIButton *btnQuery;
@end

@implementation RCDUnreadCountView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)showCount:(NSInteger)count {
    self.labCount.text = [NSString stringWithFormat:@"查询结果: %ld 条", count];
    [self.labCount sizeToFit];
}

- (void)showTypes:(NSString *)text {
    self.labType.text = [NSString stringWithFormat:@"已选择会话类型: \n -> %@", text];
    [self.labType sizeToFit];
}

- (void)showLevels:(NSString *)text {
    self.labLevels.text = [NSString stringWithFormat:@"已选择 Level 类型: \n -> %@", text];
    [self.labLevels sizeToFit];
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];

    self.labCount = [UILabel new];
    [self addSubview:self.labCount];
    [self.labCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(40);
        make.centerX.mas_equalTo(self);
    }];
    
    self.labType = [UILabel new];
    self.labType.text = @"请选择类别";
    self.labType.numberOfLines = 0;
    [self addSubview:self.labType];
    [self.labType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.labCount).mas_offset(40);
        make.centerX.mas_equalTo(self);
        make.left.mas_equalTo(self).mas_offset(12);
    }];
    
    self.labLevels = [UILabel new];
    self.labLevels.text = @"请选择 Level";
    self.labLevels.numberOfLines = 0;
    [self addSubview:self.labLevels];
    [self.labLevels mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.labType.mas_bottom).mas_offset(40);
        make.centerX.mas_equalTo(self);
        make.left.mas_equalTo(self).mas_offset(12);
    }];
    
    [self addSubview:self.btnQuery];
    [self.btnQuery mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).mas_offset(-40);
        make.left.mas_equalTo(self).mas_offset(16);
        make.right.mas_equalTo(self).mas_offset(-16);
        make.height.mas_equalTo(44);

    }];
}

- (UILabel *)labCount {
    if (!_labCount) {
        _labCount = [UILabel new];
        _labCount.font = [UIFont boldSystemFontOfSize:48];
    }
    return _labCount;
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
