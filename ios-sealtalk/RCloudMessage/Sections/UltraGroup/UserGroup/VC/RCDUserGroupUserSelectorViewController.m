//
//  RCDUserGroupUserSelectorViewController.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupUserSelectorViewController.h"
#import "RCDUserGroupUserSelectorView.h"
#import "RCDUltraGroupManager.h"
#import "RCDUtilities.h"
#import "RCDUserGroupMemberCell.h"
#import "UIView+MBProgressHUD.h"

@interface RCDUserGroupUserSelectorViewController ()<UISearchBarDelegate,
UITableViewDelegate,
UITableViewDataSource>

@property(nonatomic, strong) RCDUserGroupUserSelectorView *selectorView;
@property(nonatomic, strong) NSArray<RCDUserGroupMemberInfo *> *dataSource;
@property(nonatomic, strong) NSArray<RCDUserGroupMemberInfo *> *members;
@end

@implementation RCDUserGroupUserSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchAllMembers];
}

- (void)loadView {
    self.view = self.selectorView;
}

- (void)ready {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"成员列表";
    [self createRightBtn];
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

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createRightBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(btnDoneClick)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)btnDoneClick {
    NSMutableArray *array = [NSMutableArray array];
    for (RCDUserGroupMemberInfo *member in self.members) {
        if (member.isSelected) {
            [array addObject:member];
        }
    }
    if ([self.delegate respondsToSelector:@selector(userDidSelectMembers:original:)]) {
        [self.delegate userDidSelectMembers:array original:self.userIDs];
    }
 
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)fetchAllMembers {
    [self.view showLoading];
    [RCDUltraGroupManager getUltraGroupMemberList:self.groupID
                                            count:100
                                         complete:^(NSArray<NSString *> *memberIdList) {
        [self fillMemberInfoWith:memberIdList];
        
    }];
}

- (void)fillMemberInfoWith:(NSArray<NSString *> *)memberIdList {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *userID in memberIdList) {
        [RCDUtilities getGroupUserDisplayInfo:userID
                                      groupId:self.groupID
                                       result:^(RCUserInfo *user) {
            RCDUserGroupMemberInfo *info = [self memberInfoBy:user];
            if (info) {
                [array addObject:info];
            }
        }];
    }
    self.dataSource = array;
    self.members = array;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.selectorView.tableView reloadData];
        [self.view hideLoading];
    });
}

- (RCDUserGroupMemberInfo *)memberInfoBy:(RCUserInfo *)user {
    if (user) {
        RCDUserGroupMemberInfo *info = [RCDUserGroupMemberInfo new];
        info.groupID = self.groupID;
        info.name = user.name;
        info.userID = user.userId;
        info.portrait = user.portraitUri;
        info.isSelected = [self.userIDs containsObject:info.userID];
        return info;
    }
    return nil;;
}

- (NSArray *)filterMembersBy:(NSString *)string {
    if (string.length == 0) {
        return self.members;
    }
    NSString *pre = [NSString stringWithFormat:@"name CONTAINS '%@'",string];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pre];
    NSArray *array = [self.members filteredArrayUsingPredicate:predicate];
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
    self.dataSource = [self filterMembersBy:searchText];
    [self.selectorView.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.dataSource = [self filterMembersBy:@""];
    [self.selectorView.tableView reloadData];
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.selectorView.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserGroupMemberInfo *info = self.dataSource[indexPath.row];
    info.isSelected = !info.isSelected;
    RCDUserGroupMemberCell *cell = (RCDUserGroupMemberCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell updateCell:info];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserGroupMemberInfo *info = self.dataSource[indexPath.row];
    RCDUserGroupMemberCell *cell = [RCDUserGroupMemberCell memberCell:tableView
                                                         forIndexPath:indexPath];
    [cell updateCell:info];
    return cell;
}



#pragma mark - Property
- (RCDUserGroupUserSelectorView *)selectorView  {
    if (!_selectorView) {
        _selectorView = [RCDUserGroupUserSelectorView new];
        _selectorView.searchBar.delegate = self;
        _selectorView.tableView.dataSource = self;
        _selectorView.tableView.delegate = self;
        [_selectorView.tableView registerClass:[RCDUserGroupMemberCell class]
                        forCellReuseIdentifier:RCDUserGroupMemberCellIdentifier];
    }
    return _selectorView;
}

@end
