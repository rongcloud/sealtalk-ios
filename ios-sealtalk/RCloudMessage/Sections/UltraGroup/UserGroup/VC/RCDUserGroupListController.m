//
//  RCDUserGroupTableViewController.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupListController.h"
#import "RCDUserGroupCreateViewController.h"
#import "RCDUserGroupListView.h"
#import "RCDUserGroupInfo.h"
#import "RCDUserGroupDetailViewController.h"
#import "RCDUltraGroupManager.h"
#import "UIView+MBProgressHUD.h"
#import <RongIMLibCore/RongIMLibCore.h>

NSString *const RCDUserGroupListViewIdentifier = @"RCDUserGroupListViewIdentifier";
@interface RCDUserGroupListController ()<UITableViewDelegate, UITableViewDataSource,RCUserGroupStatusDelegate>
@property(nonatomic, strong) RCDUserGroupListView *listView;
@property(nonatomic, strong) NSMutableArray<RCDUserGroupInfo *> *dataSource;
@end

@implementation RCDUserGroupListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchDatas];
    BOOL ret = self.dataSource.count>0;
    [self.listView userGrouListEnable:ret];
    [[RCChannelClient sharedChannelManager] setUserGroupStatusDelegate:self];
}

- (void)loadView {
    self.view = self.listView;
}

- (void)ready {
    self.title = @"用户组列表";
    if (self.isOwner) {
        [self createAddBtn];
    }

}


- (void)createAddBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [btn addTarget:self
            action:@selector(createUserGroup)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)createUserGroup {
    RCDUserGroupCreateViewController *vc = [RCDUserGroupCreateViewController new];
    vc.groupID = self.groupID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fetchDatas {
    [self.view showLoading];
    [RCDUltraGroupManager queryUserGroups:self.groupID complete:^(NSArray *array, RCDUltraGroupCode ret) {
            if (ret != RCDUltraGroupCodeSuccess) {
                [self showTipsBy:@"请求用户组失败"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view hideLoading];
                    
                });
                return;
            }
            NSMutableArray *userGroups = [NSMutableArray array];

            if ([array isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dic in array) {
                    RCDUserGroupInfo *info = [RCDUserGroupInfo new];
                    info.userGroupID = dic[@"userGroupId"];
                    info.name = dic[@"userGroupName"];
                    info.count = [dic[@"memberCount"] integerValue];
                    info.groupID = self.groupID;
                    [userGroups addObject:info];
                }
            }
            
              [self.dataSource removeAllObjects];
              [self.dataSource addObjectsFromArray:userGroups];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listView.tableView reloadData];
            BOOL ret = self.dataSource.count>0;
            [self.listView userGrouListEnable:ret];
            [self.view hideLoading];

        });
    }];

}

- (void)removeItemAt:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.listView.tableView deleteRowsAtIndexPaths:@[indexPath]
                                       withRowAnimation:UITableViewRowAnimationLeft];
    });
}

- (void)showTipsBy:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}


- (void)showAlertWith:(NSIndexPath *)indexPath {
    RCDUserGroupInfo *info = self.dataSource[indexPath.row];
    NSString *message = [NSString stringWithFormat:@"确定删除用户组 -> %@ ?", info.name];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示"
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction * _Nonnull action) {
        [RCDUltraGroupManager deleteUserGroup:info.groupID userGroupID:info.userGroupID complete:^(RCDUltraGroupCode ret) {
            if (ret == RCDUltraGroupCodeSuccess) {
                [self removeItemAt:indexPath];
                [self showTipsBy:@"删除成功"];
            } else {
                [self showTipsBy:@"删除失败"];
            }
        }];
    }];
    [vc addAction:ok];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCDUserGroupInfo *info = self.dataSource[indexPath.row];
    RCDUserGroupDetailViewController *vc = [[RCDUserGroupDetailViewController alloc] initWithUserGroup:info];
    vc.isOwner = self.isOwner;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
       
        [self showAlertWith:indexPath];
    }
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserGroupInfo *info = self.dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDUserGroupListViewIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RCDUserGroupListViewIdentifier];
    }
    // ☃
    cell.detailTextLabel.text = [NSString stringWithFormat:@"👪 %ld 位成员", info.count];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ -> %@", info.name, info.userGroupID];;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}


#pragma mark - RCUserGroupStatusDelegate

- (void)showAlert:(NSString *)title message:(NSString *)msg completion:(void(^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
   
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title
                                                                message:msg
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }];
    
    [vc addAction:ok];
    [self presentViewController:vc animated:YES completion:nil];
        
    });
}

- (void)userGroupDisbandFrom:(RCConversationIdentifier *)identifier
                userGroupIds:(NSArray<NSString *> *)userGroupIds {
    if ([identifier.targetId isEqualToString:self.groupID]) {
        NSString *msg = [userGroupIds componentsJoinedByString:@","];
        [self showAlert:@"用户组解散" message:msg completion:^{
            [self fetchDatas];
        }];
        return;
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"解散用户组: %@ -> %@", identifier.targetId, msg];
    [self showTipsBy:msg];
}

- (void)userAddedTo:(RCConversationIdentifier *)identifier
       userGroupIds:(NSArray<NSString *> *)userGroupIds {
    if ([identifier.targetId isEqualToString:self.groupID]) {
        NSString *msg = [userGroupIds componentsJoinedByString:@","];
        [self showAlert:@"新增成员" message:msg completion:^{
            [self fetchDatas];
        }];
        return;
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"新增成员: %@ -> %@", identifier.targetId, msg];
    [self showTipsBy:msg];
}


- (void)userRemovedFrom:(RCConversationIdentifier *)identifier
           userGroupIds:(NSArray<NSString *> *)userGroupIds {
    if ([identifier.targetId isEqualToString:self.groupID]) {
        NSString *msg = [userGroupIds componentsJoinedByString:@","];
        [self showAlert:@"移除成员" message:msg completion:^{
            [self fetchDatas];
        }];
        return;
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"移除成员: %@ -> %@", identifier.targetId, msg];
    [self showTipsBy:msg];
}


- (void)userGroupBindTo:(RCChannelIdentifier *)identifier
            channelType:(RCUltraGroupChannelType)channelType
           userGroupIds:(NSArray<NSString *> *)userGroupIds {
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"绑定用户组: %@(%@) -> %@", identifier.targetId, identifier.channelId, msg];
    [self showTipsBy:msg];
}


- (void)userGroupUnbindFrom:(RCChannelIdentifier *)identifier
                channelType:(RCUltraGroupChannelType)channelType
               userGroupIds:(NSArray<NSString *> *)userGroupIds {
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"解绑用户组: %@(%@) -> %@", identifier.targetId, identifier.channelId, msg];
    [self showTipsBy:msg];
}

#pragma mark - Property
- (RCDUserGroupListView *)listView {
    if (!_listView) {
        _listView = [RCDUserGroupListView new];
        _listView.tableView.dataSource = self;
        _listView.tableView.delegate = self;
    }
    return _listView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource= [NSMutableArray array];
    }
    return _dataSource;
}
@end
