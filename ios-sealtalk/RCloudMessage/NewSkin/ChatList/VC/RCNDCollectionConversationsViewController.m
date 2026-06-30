//
//  RCNDCollectionConversationsViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCollectionConversationsViewController.h"
#import "UIViewController+RCN.h"
#import "RCDUIBarButtonItem.h"

@interface RCNDCollectionConversationsViewController ()
@end

@implementation RCNDCollectionConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.displayConversationTypeArray.count) {
        RCConversationType conversationType = [[self.displayConversationTypeArray firstObject] intValue];
        self.title = [RCKitUtility defaultTitleForCollectionConversation:conversationType];
    }
    [self configureLeftBackButton];
    self.view.backgroundColor = RCDynamicColor(@"auxiliary_background_1_color", @"0xf5f6f9", @"0x111111");
}

- (void)configureLeftBackButton {
    [self.navigationItem setLeftBarButtonItems:[RCDUIBarButtonItem getLeftBarButton:nil target:self action:@selector(leftBarButtonBackAction)]];
}

- (void)leftBarButtonBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self rcn_restoreDefaultNavigationBarAppearance];
}



@end
