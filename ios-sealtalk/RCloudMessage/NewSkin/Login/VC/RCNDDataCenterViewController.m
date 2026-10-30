//
//  RCNDDataCenterViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDDataCenterViewController.h"

@interface RCNDDataCenterViewController ()

@end

@implementation RCNDDataCenterViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self restoreDefaultNavigationBarAppearance];
}

- (RCNDDataCenterViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDDataCenterViewModel class]]) {
        RCNDDataCenterViewModel *vm = (RCNDDataCenterViewModel *)self.viewModel;
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
    self.title = RCDLocalizedString(@"DataCenter");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
