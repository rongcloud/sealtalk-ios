//
//  RCNDQRForwardFriendsViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardFriendsViewController.h"

@interface RCNDQRForwardFriendsViewController ()

@end

@implementation RCNDQRForwardFriendsViewController


- (RCNDQRForwardFriendsViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDQRForwardFriendsViewModel class]]) {
        RCNDQRForwardFriendsViewModel *vm = (RCNDQRForwardFriendsViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self currentViewModel] fetchData];
}

- (void)setupView {
    [super setupView];
    self.navigationItem.title = RCDLocalizedString(@"SelectedFriend");
    [self configureLeftBackButton];
}

@end
