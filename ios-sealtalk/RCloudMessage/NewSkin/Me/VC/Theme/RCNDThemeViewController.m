//
//  RCNDThemeViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDThemeViewController.h"

@implementation RCNDThemeViewController

- (RCNDThemeViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDThemeViewModel class]]) {
        RCNDThemeViewModel *vm = (RCNDThemeViewModel *)self.viewModel;
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
    self.title = RCDLocalizedString(@"Themes");
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:RCDLocalizedString(@"save") forState:UIControlStateNormal];
    [btn setTitleColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x007acc")
              forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(saveTheme)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)saveTheme {
    [[self currentViewModel] save];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
