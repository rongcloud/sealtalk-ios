//
//  RCNDTranslationViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDTranslationViewController.h"

@implementation RCNDTranslationViewController

- (RCNDTranslationViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDTranslationViewModel class]]) {
        RCNDTranslationViewModel *vm = (RCNDTranslationViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)setupView {
    [super setupView];
    [self configureLeftBackButton];
    self.title = RCDLocalizedString(@"translationSetting");
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
