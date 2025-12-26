//
//  RCNDSearchViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/28.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchViewController.h"
@interface RCNDSearchViewController ()
@end

@implementation RCNDSearchViewController

- (RCNDSearchViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDSearchViewModel class]]) {
        RCNDSearchViewModel *vm = (RCNDSearchViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self restoreDefaultNavigationBarAppearance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self currentViewModel] becomeFirstResponder];
}

- (void)reloadData:(BOOL)empty {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listView.tableView reloadData];
        [self.listView.tableView setNeedsLayout];
        [self.listView.tableView layoutIfNeeded];
        self.listView.labEmpty.hidden = !empty;
    });
}

- (void)setupView {
    [super setupView];
    [self.listView configureSearchBar:[[self currentViewModel] searchBar]];
    self.navigationItem.title = RCDLocalizedString(@"search");
    [self configureLeftBackButton];
}

- (void)leftBarButtonBackAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self currentViewModel] titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [[self currentViewModel] heightForHeaderInSection:section];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    return [[self currentViewModel] endEditingState];
}


@end
