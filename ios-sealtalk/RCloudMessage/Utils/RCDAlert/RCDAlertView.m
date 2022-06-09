//
//  RCDAlertView.m
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDAlertView.h"
#import <Masonry/Masonry.h>
#import "RCDAlertAction+Handler.h"
#import "RCDAlertAction.h"
#import "UIButton+AlertAction.h"

const static CGFloat padding = 24.0f;/** 间隙 */
const static CGFloat topPadding = 13.0f;/** 顶间隙 */
const static CGFloat paragraph = 7.0f; /** 段间隙 */
const static CGFloat buttonHeight = 44.0f; /** 按钮高度 */

@interface RCDAlertView ()

@property(nonatomic, strong) UILabel *titleLabel ;
@property(nonatomic, strong) UIButton *senderBtn ;
@property(nonatomic, strong) UILabel *messageLabel ;
@property(nonatomic, strong) UIView *whiteSpaceView ;
@property(nonatomic, strong) NSMutableArray *buttons, *views;

@end

@implementation RCDAlertView

#pragma mark - initialize
- (instancetype)initWithTitle:(NSString *)title withMessage:(NSString *)message withSender:(NSString *)sender {
    self = [super init];
    if (self) {
        // 判断label 相关字段为nil时，不创建此控件。
        if (title) [self setupTitleLabelWithTitle:title];
        if (sender) [self setupSenderBtnWithSender:sender] ;
        if (message) [self setupMessageLabelWithMessage:message] ;
    }
    return self ;
}

#pragma mark - setup view
// title label
- (void)setupTitleLabelWithTitle:(NSString *)title {
    NSMutableAttributedString *strTitle = [[NSMutableAttributedString alloc] initWithString:title] ;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
    [paragraph setLineSpacing:3];
    [paragraph setParagraphSpacing:8];
    [paragraph setBaseWritingDirection:NSWritingDirectionLeftToRight];
    [paragraph setAlignment:NSTextAlignmentCenter];
    NSDictionary *attributesDic = @{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                    NSForegroundColorAttributeName:[UIColor colorWithRed:17/255.0 green:31/255.0 blue:44/255.0 alpha:1],
                                    NSParagraphStyleAttributeName:paragraph
    } ;
    [strTitle addAttributes:attributesDic range:NSMakeRange(0, strTitle.length)];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.attributedText = strTitle ;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont systemFontOfSize:17.0];
    _titleLabel.textColor = [UIColor colorWithRed:17/255.0 green:31/255.0 blue:44/255.0 alpha:1];
    [self addSubview:_titleLabel] ;
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(topPadding) ;
        make.left.equalTo(self).offset(padding) ;
        make.right.equalTo(self).inset(padding) ;
    }];

    [self.views addObject:_titleLabel];
}

// sender button
- (void)setupSenderBtnWithSender:(NSString *)sender {
    _senderBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect] ;
    [_senderBtn setTitle:sender forState:UIControlStateNormal];
    _senderBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_senderBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
    [_senderBtn addTarget:self action:@selector(senderAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_senderBtn];
    
    UIView *lastView = [self.views lastObject] ;
    [_senderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastView ? lastView.mas_bottom : self ).offset(paragraph);
        make.left.equalTo(self).offset(padding) ;
        make.right.equalTo(self).inset(padding) ;
    }];
    
    [self.views addObject:_senderBtn];
}

// message label
- (void)setupMessageLabelWithMessage:(NSString *)message {
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.text = message;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.numberOfLines = 0;
    _messageLabel.font = [UIFont systemFontOfSize:17.0];
    _messageLabel.textColor = [UIColor colorWithRed:17/255.0 green:31/255.0 blue:44/255.0 alpha:1];
    [self addSubview:_messageLabel] ;
    
    UIView *lastView = [self.views lastObject] ;
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastView ? lastView.mas_bottom : self).offset(padding);
        make.left.equalTo(self).offset(padding) ;
        make.right.equalTo(self).inset(padding) ;
    }];
    
    [self.views addObject:_messageLabel];
}

- (void)setupWhiteSpaceView {
    if(self.whiteSpaceView.hidden) {
        self.whiteSpaceView.hidden = NO ;
        [self addSubview:self.whiteSpaceView];
    }
    
    UIView *lastView = [self.views lastObject] ;
    [self.whiteSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self) ;
        make.top.mas_equalTo(lastView ? lastView.mas_bottom : self).offset(padding) ;
        make.height.mas_equalTo(0.5f) ;
    }];
    [self.views addObject:self.whiteSpaceView];
}

// action buttons
- (void)setupButtonsWithActions:(NSArray<RCDAlertAction *> *)actions {
    [actions enumerateObjectsUsingBlock:^(RCDAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect] ;
            [button setTitle:obj.title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:17];
            [button setTitleColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(actionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.action = obj ;
            [self addSubview:button];
            
            UIView *lastView = [self.views lastObject] ;
            // 仅有两个按钮时，比较特殊，横向排列。
            if (actions.count == 2) {
                if (idx == actions.count - 1) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(self) ;
                        make.top.mas_equalTo(lastView ? lastView.mas_top : self) ;
                        make.height.mas_equalTo(buttonHeight) ;
                        make.width.mas_equalTo(self.mas_width).multipliedBy(0.5) ;
                        make.bottom.equalTo(self) ;
                    }];
                } else {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(self) ;
                        make.top.mas_equalTo(lastView ? lastView.mas_bottom : self) ;
                        make.height.mas_equalTo(buttonHeight) ;
                        make.width.mas_equalTo(self.mas_width).multipliedBy(0.5) ;
                        make.bottom.equalTo(self) ;
                    }];
                }
            }
            // 单个或者多个(除两个外)按钮时，竖向排列。
            else {
                if (idx == actions.count - 1) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(self) ;
                        make.top.mas_equalTo(lastView ? lastView.mas_bottom : self) ;
                        make.height.mas_equalTo(buttonHeight) ;
                        make.bottom.equalTo(self) ;
                    }];
                } else {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.equalTo(self) ;
                        make.top.mas_equalTo(lastView ? lastView.mas_bottom : self) ;
                        make.height.mas_equalTo(buttonHeight) ;
                    }];
                }
            }
            [self.views addObject:button];
            [self.buttons addObject:button];
        }) ;
    }];
}

#pragma mark - interface func
- (void)addActions:(NSArray<RCDAlertAction *> *)actions {
    if (!actions) return;
    if (![actions isKindOfClass:[NSArray class]]) return;
    if (!actions.count) return;

    [self setupWhiteSpaceView] ;
    [self setupButtonsWithActions:actions] ;
    [self.views addObject:self.whiteSpaceView];
}

#pragma mark - button event
- (void)senderAction:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(RCDAlertView:selectSenderButton:)]) {
        [_delegate RCDAlertView:self selectSenderButton:button];
    }
}

- (void)actionButtonAction:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(RCDAlertView:selectAlertAction:)]) {
        [_delegate RCDAlertView:self selectAlertAction:sender.action];
    }
}

#pragma mark - Lazy Loading
- (UIView *)whiteSpaceView {
    if (!_whiteSpaceView) {
        _whiteSpaceView = [[UIView alloc] init];
        _whiteSpaceView.backgroundColor = [UIColor colorWithRed:229/255.0 green:230/255.0 blue:231/255.0 alpha:1] ;
        _whiteSpaceView.hidden = YES ;
    }
    return _whiteSpaceView ;
}

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons ;
}

- (NSMutableArray *)views {
    if (!_views) {
        _views = [NSMutableArray array] ;
    }
    return _views ;
}


@end
