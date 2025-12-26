//
//  RCNDLanguageSupportedViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDLanguageSupportedViewController.h"


@implementation RCNDLanguageSupportedViewController

- (RCNDLanguageSupportedViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDLanguageSupportedViewModel class]]) {
        RCNDLanguageSupportedViewModel *vm = (RCNDLanguageSupportedViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)setupView {
    [super setupView];
    [self configureLeftBackButton];
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)saveLanguage {
    [[self currentViewModel] save];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
@end
