//
//  RCNDAboutViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDAboutViewController.h"
#import "RCNDAboutView.h"

@interface RCNDAboutViewController()
@property (nonatomic, strong) RCNDAboutView *aboutView;
@end

@implementation RCNDAboutViewController

- (instancetype)initWithViewModel:(RCNDBaseListViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.listView = self.aboutView;
    }
    return self;
}

- (RCNDAboutViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDAboutViewModel class]]) {
        RCNDAboutViewModel *vm = (RCNDAboutViewModel *)self.viewModel;
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
    self.title = RCDLocalizedString(@"about_st");
}

- (RCNDAboutView *)aboutView {
    if (!_aboutView) {
        _aboutView = [RCNDAboutView new];
        _aboutView.tableView.dataSource = self;
        _aboutView.tableView.delegate = self;
    }
    return _aboutView;
}
@end
