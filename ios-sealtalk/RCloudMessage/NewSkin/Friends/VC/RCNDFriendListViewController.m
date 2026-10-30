//
//  RCNDFriendListViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/28.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDFriendListViewController.h"
#import "UIViewController+RCN.h"

@interface RCNDFriendListViewController ()

@end

@implementation RCNDFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeLeft | UIRectEdgeRight;
    [self configureBackground];
}

- (void)configureBackground {
    if ([self.view isKindOfClass:[RCSearchBarListView class]]) {
        RCSearchBarListView *view = (RCSearchBarListView *)self.view;
        view.tableView.backgroundColor = [UIColor clearColor];
        
        UIImage *img = [UIImage imageNamed:@"sealtalk_background"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [view insertSubview:imageView belowSubview:view.contentStackView];
        [NSLayoutConstraint activateConstraints:@[
            [imageView.topAnchor constraintEqualToAnchor:view.topAnchor constant:0],
            [imageView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
            [imageView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
            [imageView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor]
        ]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self rcn_configureTransparentNavigationBar];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self rcn_restoreDefaultNavigationBarAppearance];
}
@end
