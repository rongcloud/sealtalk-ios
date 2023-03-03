//
//  RCDUserGroupSelectorViewController.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/12.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupSelectorViewController.h"
#import "RCDUserGroupSelectorView.h"
#import "RCDUserGroupOptionInfo.h"
#import "RCDUltraGroupManager.h"
#import "UIView+MBProgressHUD.h"

NSString *const RCDUserGroupSelectorViewIdentifier = @"RCDUserGroupSelectorViewIdentifier";

@interface RCDUserGroupSelectorViewController ()<UISearchBarDelegate,
UITableViewDelegate,
UITableViewDataSource>
@property(nonatomic, strong) NSArray<RCDUserGroupOptionInfo *> *originalUserGroups;
@property(nonatomic, strong) NSArray<RCDUserGroupOptionInfo *> *userGroups;
@property(nonatomic, strong) RCDUserGroupSelectorView *selectorView;
@end

@implementation RCDUserGroupSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

- (void)ready {
    [self createSubmitBtn];
    [self createLeftBtn];
}

- (void)createLeftBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(back)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)createSubmitBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(btnSubmitClick)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)btnSubmitClick {
    NSMutableArray *array = [NSMutableArray array];
    for (RCDUserGroupOptionInfo *info in self.userGroups) {
        if (info.isSelected) {
            [array addObject:info.userGroup];
        }
    }
    if ([self.delegate respondsToSelector:@selector(userDidSelectUserGroups:)]) {
        [self.delegate userDidSelectUserGroups:array];
    }
 
    [self back];
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchData {
    [RCDUltraGroupManager queryUserGroups:self.groupID
                                 complete:^(NSArray *array, RCDUltraGroupCode ret) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret == RCDUltraGroupCodeSuccess) {
                [self fillMembersWith:array];
            } else {
                [self showTipsBy:@"获取用户组列表失败"];
            }
        });
    }];
}

- (void)fillMembersWith:(NSArray *)array {
    NSMutableArray *userGroups = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in array) {
            RCDUserGroupInfo *info = [RCDUserGroupInfo new];
            info.userGroupID = dic[@"userGroupId"];
            info.name = dic[@"userGroupName"];
            info.count = [dic[@"memberCount"] integerValue];
            info.groupID = self.groupID;
            
            RCDUserGroupOptionInfo *item = [RCDUserGroupOptionInfo new];
            item.userGroup = info;
            item.isSelected = [self.userGroupIDs containsObject:info.userGroupID];
            [userGroups addObject:item];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.userGroups = userGroups;
        self.originalUserGroups = userGroups;
        [self.selectorView.tableView reloadData];
    });
}
- (void)showTipsBy:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchData];
}

- (void)loadView {
    self.view = self.selectorView;
}

- (NSArray *)filterUserGroupsBy:(NSString *)string {
    if (string.length == 0) {
        return self.originalUserGroups;
    }
    NSString *pre = [NSString stringWithFormat:@"userGroup.name CONTAINS '%@'",string];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pre];
    NSArray *array = [self.originalUserGroups filteredArrayUsingPredicate:predicate];
    return array;
}

#pragma mark - UISearchBarDelegate

// called when text starts editing
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}
// called when text ends editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

// called when text changes (including clear)
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.userGroups = [self filterUserGroupsBy:searchText];
    [self.selectorView.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.userGroups = [self filterUserGroupsBy:@""];
    [self.selectorView.tableView reloadData];
    [searchBar resignFirstResponder];
}


#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.selectorView.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCDUserGroupOptionInfo *info = self.userGroups[indexPath.row];
    info.isSelected = !info.isSelected;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = info.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserGroupOptionInfo *info = self.userGroups[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDUserGroupSelectorViewIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RCDUserGroupSelectorViewIdentifier];
    }
    // ☃
    cell.detailTextLabel.text = [NSString stringWithFormat:@"👪 %ld 位成员", info.userGroup.count];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ -> %@", info.userGroup.name, info.userGroup.userGroupID];;
    cell.accessoryType = info.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Property

- (RCDUserGroupSelectorView *)selectorView {
    if (!_selectorView) {
        _selectorView = [RCDUserGroupSelectorView new];
        _selectorView.searchBar.delegate = self;
        _selectorView.tableView.dataSource = self;
        _selectorView.tableView.delegate = self;
    }
    return _selectorView;
}
@end
