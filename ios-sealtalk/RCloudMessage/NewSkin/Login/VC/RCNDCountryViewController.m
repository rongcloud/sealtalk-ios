//
//  RCNDCountryViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCountryViewController.h"
@interface RCNDCountryViewController ()

@end

@implementation RCNDCountryViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self restoreDefaultNavigationBarAppearance];
}

- (RCNDCountryViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDCountryViewModel class]]) {
        RCNDCountryViewModel *vm = (RCNDCountryViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self currentViewModel] fetchAllData];
}

- (void)setupView {
    [super setupView];
    [self configureLeftBackButton];
    [self.listView configureSearchBar:[[self currentViewModel] searchBar]];
    self.title = RCDLocalizedString(@"select_country");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self currentViewModel] titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self currentViewModel] sectionIndexTitlesForTableView:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self currentViewModel] numberOfSectionsInTableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =  [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[RCPaddingTableViewCell class]]) {
        RCPaddingTableViewCell *paddingCell = (RCPaddingTableViewCell *)cell;
        [paddingCell updatePaddingContainer:RCUserManagementPadding trailing:-1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
