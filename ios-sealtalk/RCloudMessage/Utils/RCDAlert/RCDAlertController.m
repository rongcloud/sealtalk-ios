//
//  RCDViewController.m
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDAlertController.h"
#import "RCDAlertView.h"
#import <Masonry/Masonry.h>
#import "RCDAlertAction+Handler.h"
#import "RCDAlertAction.h"

static const CGFloat RCL_CornerRadius = 8.f; /** 圆角半径 */
static const CGFloat RCL_AlertWidth = 280.f ; /** 提示展示视图宽度 */

@interface RCDAlertController ()<RCDAlertViewDelegate>

@property(nonatomic, strong) RCDAlertView *alertView ;
@property (nonatomic, strong, readwrite) NSArray<RCDAlertAction *> *actions;
@property (nonatomic, copy)void (^sendHandler)(UIButton *sender);

@end

@implementation RCDAlertController

#pragma mark - initialize
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message withSender:(NSString *)sender handler:(void (^)(UIButton *sender))handler{
    RCDAlertController *alert = [[RCDAlertController alloc] init];
    alert.alertTitle = title ;
    alert.alertMessage = message ;
    alert.alertSender = sender ;
    alert.modalPresentationStyle = UIModalPresentationCustom;
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.sendHandler = handler ;
    return alert ;
}

#pragma mark - view load
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView] ;
}

#pragma mark - setupView
- (void)setupView {
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] ;
    [self.view addSubview:self.alertView];
    if (self.actions) [self.alertView addActions:self.actions];
    [self autoLayoutView] ;
}

- (void)autoLayoutView {
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY) ;
        make.width.mas_equalTo(RCL_AlertWidth) ;
    }];
}

#pragma mark - event
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RCDAlertViewDelegate
- (void)RCDAlertView:(RCDAlertView *)alertView selectAlertAction:(RCDAlertAction *)action {
    [self dismiss] ;
    action.handler(action);
}

-(void)RCDAlertView:(RCDAlertView *)alertView selectSenderButton:(UIButton *)action {
    [self dismiss];
    self.sendHandler(action) ;
}

#pragma mark - Interface Method
- (void)addAction:(RCDAlertAction *)action {
    NSMutableArray *mactions = [self.actions mutableCopy];
    [mactions addObject:action];
    self.actions = [mactions copy];
}

#pragma mark - Lazy Loading
- (NSArray<RCDAlertAction *> *)actions {
    if (!_actions) {
        _actions = [NSArray array] ;
    }
    return _actions ;
}

- (RCDAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[RCDAlertView alloc] initWithTitle:_alertTitle withMessage:_alertMessage withSender:_alertSender];
        _alertView.delegate = self ;
        [_alertView.layer setMasksToBounds:YES];
        [_alertView.layer setCornerRadius:RCL_CornerRadius];
        _alertView.backgroundColor = [UIColor whiteColor] ;
    }
    return _alertView ;
}

@end
