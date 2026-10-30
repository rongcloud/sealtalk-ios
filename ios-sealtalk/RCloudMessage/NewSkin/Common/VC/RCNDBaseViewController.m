//
//  RCNDBaseViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewController.h"
#import "RCDUIBarButtonItem.h"
#import "UIViewController+RCN.h"

@implementation RCNDBaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)pushViewController:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setupView {
    
}

- (void)configureLeftBackButton {
    [self.navigationItem setLeftBarButtonItems:[RCDUIBarButtonItem getLeftBarButton:nil target:self action:@selector(leftBarButtonBackAction)]];
}

- (void)leftBarButtonBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showTips:(NSString *)tips {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:tips];
    });
}


- (void)showLoading {
    [self.view showLoading];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showLoading];
    });
}

- (void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view hideLoading];
    });
}


- (void)configureTransparentNavigationBar {
    [self rcn_configureTransparentNavigationBar];
}

- (void)restoreDefaultNavigationBarAppearance {
    [self rcn_restoreDefaultNavigationBarAppearance];
}

@end
