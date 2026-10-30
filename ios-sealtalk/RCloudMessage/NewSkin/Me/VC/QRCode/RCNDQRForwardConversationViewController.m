//
//  RCNDConversationSelectViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardConversationViewController.h"

@interface RCNDQRForwardConversationViewController ()

@end

@implementation RCNDQRForwardConversationViewController


- (RCNDQRForwardConversationViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDQRForwardConversationViewModel class]]) {
        RCNDQRForwardConversationViewModel *vm = (RCNDQRForwardConversationViewModel *)self.viewModel;
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
    [self configureLeftBackButton];
    self.title = RCDLocalizedString(@"SelectConversationToForward");
    [self restoreDefaultNavigationBarAppearance];
}

- (void)leftBarButtonBackAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

@end
