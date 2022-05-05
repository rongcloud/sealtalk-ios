//
//  RCDebugComBaseViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/4/12.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDebugComBaseViewController.h"

@interface RCDebugComBaseViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, copy) NSString *currentTitle;
@end

@implementation RCDebugComBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.view);
    }];
}

- (void)loadView {
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)showLoading {
    self.currentTitle = self.title;
    self.title = @"请求中....";
    [self.indicatorView startAnimating];
}

- (void)loadingFinished {
    self.title = self.currentTitle;
    [self.indicatorView stopAnimating];
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        if (@available(iOS 13.0, *)) {
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}
@end
