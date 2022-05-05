//
//  RCDDebugUltraGroupUnreadMessageViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/4/1.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDDebugUltraGroupUnreadMessageViewController.h"
#import <Masonry/Masonry.h>
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCDDebugUltraGroupUnreadMessageViewController()
// 获取指定超级群下所有频道的未读消息总数接口
@property (nonatomic, strong) UIButton *allChannelBtn;
// 超级群会话类型的所有未读消息数
@property (nonatomic, strong) UIButton *allGroupBtn;
// 获取超级群会话类型的@消息未读数接口
@property (nonatomic, strong) UIButton *specialBtn;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UITextField *targetIDTxt;
@end

@implementation RCDDebugUltraGroupUnreadMessageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.targetIDTxt.text = self.targetID;
}

- (void)loadView {
    self.view = [self contentView];
}

- (void)dealloc {
    
}

- (UIView *)contentView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:self.allChannelBtn];
    [view addSubview:self.allGroupBtn];
    [view addSubview:self.specialBtn];
    [view addSubview:self.msgLabel];
    [view addSubview:self.targetIDTxt];
    
    [self.allGroupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
        make.height.mas_equalTo(40);
    }];
    
    [self.allChannelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.allGroupBtn);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.allGroupBtn.mas_top).mas_equalTo(-20);
    }];
    
    [self.specialBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.allGroupBtn);
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(self.allGroupBtn.mas_bottom).mas_equalTo(20);
    }];
    
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.allGroupBtn);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.allChannelBtn.mas_top).mas_equalTo(-20);
    }];
    [self.targetIDTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.allGroupBtn);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(200);
        make.bottom.mas_equalTo(self.msgLabel.mas_top).mas_equalTo(-20);
    }];
    return view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.targetIDTxt resignFirstResponder];
}

- (void)showCounts:(NSInteger)count pre:(NSString *)pre {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.msgLabel.textColor = [UIColor greenColor];
        self.msgLabel.text = [NSString stringWithFormat:@"%@: %ld(条)", pre, count];
    });
}

- (void)showError:(NSInteger)code pre:(NSString *)pre {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.msgLabel.textColor = [UIColor redColor];
        self.msgLabel.text = [NSString stringWithFormat:@"%@: %ld(错误码)", pre, code];
    });
}

- (void)allChannelBtnClick:(UIButton *)btn {
    __weak __typeof(self)weakSelf = self;
    NSString *title = btn.titleLabel.text;
    [[RCChannelClient sharedChannelManager] getUltraGroupUnreadCount:self.targetIDTxt.text
                                                             success:^(NSInteger count) {
        [weakSelf showCounts:count pre:title];
    } error:^(RCErrorCode status) {
        [weakSelf showError:status pre:title];
    }];
}

- (void)allGroupBtnClick:(UIButton *)btn {
    __weak __typeof(self)weakSelf = self;
    NSString *title = btn.titleLabel.text;
    [[RCChannelClient sharedChannelManager] getUltraGroupAllUnreadCount:^(NSInteger count) {
        [weakSelf showCounts:count pre:title];
    } error:^(RCErrorCode status) {
        [weakSelf showError:status pre:title];
    }];
}

- (void)specialBtnlBtnClick:(UIButton *)btn {
    __weak __typeof(self)weakSelf = self;
    NSString *title = btn.titleLabel.text;
    [[RCChannelClient sharedChannelManager] getUltraGroupAllUnreadMentionedCount:^(NSInteger count) {
        [weakSelf showCounts:count pre:title];
    } error:^(RCErrorCode status) {
        [weakSelf showError:status pre:title];
    }];
}

- (UIButton *)buttonWith:(NSString *)title selector:(SEL)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor darkGrayColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self
            action:selector
  forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    return btn;
}


- (UIButton *)allChannelBtn {
    if (!_allChannelBtn) {
        _allChannelBtn = [self buttonWith:@"2.2.2 超级群下所有频道的未读消息总数"
                                 selector:@selector(allChannelBtnClick:)];
    }
    return _allChannelBtn;
}

- (UIButton *)allGroupBtn {
    if (!_allGroupBtn) {
        _allGroupBtn = [self buttonWith:@"2.2.3 超级群会话类型的所有未读消息数"
                               selector:@selector(allGroupBtnClick:)];
    }
    return _allGroupBtn;
}

- (UIButton *)specialBtn {
    if (!_specialBtn) {
        _specialBtn = [self buttonWith:@"2.2.4 超级群会话类型的@消息未读数接口"
                              selector:@selector(specialBtnlBtnClick:)];
    }
    return _specialBtn;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [UILabel new];
        _msgLabel.text = @"请求数据显示";
    }
    return _msgLabel;
}

- (UITextField *)targetIDTxt {
    if (!_targetIDTxt) {
        _targetIDTxt = [UITextField new];
        _targetIDTxt.backgroundColor = [UIColor darkGrayColor];
        _targetIDTxt.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _targetIDTxt;
}
@end
