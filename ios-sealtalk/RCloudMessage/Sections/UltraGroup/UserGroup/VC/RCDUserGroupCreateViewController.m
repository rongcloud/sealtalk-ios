//
//  RCDUserGroupCreateViewController.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupCreateViewController.h"
#import "RCDUserGroupUserSelectorViewController.h"
#import "RCDUserGroupCreateView.h"
#import "UIView+MBProgressHUD.h"
#import "RCDUltraGroupManager.h"

@interface RCDUserGroupCreateViewController ()<RCDUserGroupUserSelectorDelegate,
UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) RCDUserGroupCreateView *createView;
@property(nonatomic, strong) NSArray<RCDUserGroupMemberInfo *> *members;
@property(nonatomic, copy)  NSString *userGroupID;
@end

@implementation RCDUserGroupCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

- (void)loadView {
    self.view = self.createView;
}

#pragma mark - Private

- (void)ready {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"新建用户组(1/2)";
    [self createRightBtn];
}

- (void)showTipsBy:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}

- (void)createRightBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];

    [btn addTarget:self
            action:@selector(createUserGroup)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)addMemebers {
    [self.createView.txtName resignFirstResponder];
    RCDUserGroupUserSelectorViewController *vc = [RCDUserGroupUserSelectorViewController new];
    vc.delegate = self;
    vc.groupID = self.groupID;
    vc.userIDs = [self.members valueForKeyPath:@"self.userID"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)createUserGroup {
    if (!self.userGroupID) {
        NSString *name = self.createView.txtName.text;
        [self.createView.txtName resignFirstResponder];
        if (name.length == 0) {
            [self showTipsBy:@"名称不能为空"];
            return;
        }
        [RCDUltraGroupManager createUserGroup:self.groupID
                                userGroupName:name
                                     complete:^(NSString *userGroupID, RCDUltraGroupCode ret) {
            if (ret == RCDUltraGroupCodeSuccess) {
                self.userGroupID = userGroupID;
                [self addMembersTo:self.userGroupID];
            } else {
                [self showTipsBy:@"创建失败"];
            }
        }];
    } else {
        [self addMembersTo:self.userGroupID];
    }
   
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addMembersTo:(NSString *)userGroupID {
    if (!userGroupID) {
        [self showTipsBy:@"用户组ID 不能为空"];
        return;
    }
    NSArray *memberIDs = [self.members valueForKeyPath:@"userID"];
    if (!memberIDs.count) {
        [self showTipsBy:@"创建成功"];
        [self back];
        return;
    }
    [RCDUltraGroupManager addToUserGroup:self.groupID userGroupID:userGroupID members:memberIDs complete:^(RCDUltraGroupCode ret) {
        if (ret == RCDUltraGroupCodeSuccess) {
            [self showTipsBy:@"创建成功"];
            [self back];
        } else {
            [self showTipsBy:@"创建失败"];
        }
    }];
}
#pragma mark - RCDUserGroupUserSelectorDelegate

- (void)userDidSelectMembers:(NSArray<RCDUserGroupMemberInfo *> *)members
                    original:(NSArray<NSString *> *)userIDs {
    self.members = members;
    [self.createView.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.createView.txtName resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserGroupMemberInfo *info = self.members[indexPath.row];
    RCDUserGroupMemberCell *cell = [RCDUserGroupMemberCell memberCell:tableView
                                                         forIndexPath:indexPath];
    info.isSelected = NO;
    [cell updateCell:info];
    return cell;
}

- (RCDUserGroupCreateView *)createView {
    if (!_createView) {
        _createView = [RCDUserGroupCreateView new];
        _createView.tableView.dataSource = self;
        _createView.tableView.delegate = self;
        [_createView.btnSelect addTarget:self
                                  action:@selector(addMemebers)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    return _createView;
}

@end
