//
//  RCNDLanguageViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDLanguageViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "RCNDMainTabBarViewController.h"
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCNDLanguageViewController()

@end

@implementation RCNDLanguageViewController

- (RCNDLanguageViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDLanguageViewModel class]]) {
        RCNDLanguageViewModel *vm = (RCNDLanguageViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupView {
    [super setupView];
    [self configureLeftBackButton];
    self.title = RCDLocalizedString(@"language");
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:RCDLocalizedString(@"save") forState:UIControlStateNormal];
    [btn setTitleColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x007acc")
              forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(saveLanguage)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)saveLanguage {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[self currentViewModel] saveLanguage:^(RCPushLanguage language, BOOL ret) {
            if (ret) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIWindow *keyWindow;
                    for (UIWindow *window in [UIApplication sharedApplication].windows) {
                        if ([window isKeyWindow]) {
                            keyWindow = window;
                        }
                    }
                    //重置vc堆栈
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    if (language == RCPushLanguage_AR_SA) {
                        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
                        keyWindow.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
                        app.window.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
                    } else {
                        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
                        keyWindow.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
                        app.window.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
                    }
                    RCNDMainTabBarViewController *mainTabBarVC = [[RCNDMainTabBarViewController alloc] init];
                    mainTabBarVC.selectedIndex = 3;
                    app.window.rootViewController = mainTabBarVC;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.view showHUDMessage:[NSString stringWithFormat:@"%@ ", RCDLocalizedString(@"Failed")]];
                });
            }
    }];
}

@end
