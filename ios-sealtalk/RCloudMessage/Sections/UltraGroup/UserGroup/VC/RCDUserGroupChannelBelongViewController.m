//
//  RCUserGroupChannelBelongViewController.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/12.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupChannelBelongViewController.h"
#import "RCDUserGroupChannelBelongView.h"
#import "RCDUserGroupSelectorViewController.h"
#import "RCDUserGroupDetailViewController.h"
#import "UIView+MBProgressHUD.h"
#import "RCDUltraGroupManager.h"
#import <RongIMLibCore/RongIMLibCore.h>

NSString *const RCDUserGroupChannelBelongViewIdentifier = @"RCDUserGroupChannelBelongViewIdentifier";

@interface RCDUserGroupChannelBelongViewController ()<UITableViewDelegate, UITableViewDataSource, RCDUserGroupUserSelectorDelegate, RCUserGroupStatusDelegate>
@property(nonatomic, strong) RCDUserGroupChannelBelongView *userGroupView;
@property(nonatomic, strong) NSArray *userGroups;
@property(nonatomic, strong) NSArray *originalUserGroups;
@end

@implementation RCDUserGroupChannelBelongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

- (void)loadView {
    self.view = self.userGroupView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[RCChannelClient sharedChannelManager] setUserGroupStatusDelegate:self];
}

- (void)ready {
    if (self.isOwner) {
        [self createSubmitBtn];
    }
    [self fetchData];
}

- (void)showTipsBy:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}

- (void)createSubmitBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(btnSubmitClick)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)btnSubmitClick {
    [self updateUserGroups];
}

- (void)fetchData {
    [self.view showLoading];
    [RCDUltraGroupManager queryChannelUserGroups:self.groupID channelID:self.channelID complete:^(NSArray *array, RCDUltraGroupCode ret) {
        if (ret != RCDUltraGroupCodeSuccess) {
            [self showTipsBy:@"请求频道用户组失败"];
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
        self.userGroups = userGroups;
        self.originalUserGroups = userGroups;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userGroupView.tableView reloadData];
            [self.view hideLoading];
        });
    }];
}

- (void)showSelector {
    RCDUserGroupSelectorViewController *vc = [RCDUserGroupSelectorViewController new];
    vc.title = @"用户组列表";
    vc.groupID = self.groupID;
    vc.userGroupIDs = [self.userGroups valueForKeyPath:@"self.userGroupID"];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showDetail:(RCDUserGroupInfo *)info {
    RCDUserGroupDetailViewController *vc = [[RCDUserGroupDetailViewController alloc] initWithUserGroup:info];
    vc.isOwner = self.isOwner;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateUserGroups {
    NSArray *original = [self.originalUserGroups valueForKeyPath:@"userGroupID"];
    NSArray *current = [self.userGroups valueForKeyPath:@"userGroupID"];
    NSMutableSet *originalSet = [NSMutableSet setWithArray:original];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:current];
    
    NSMutableSet *remain = [originalSet mutableCopy];
    // 没有变化的UserGroupID
    [remain intersectSet:currentSet];
    // 删除的数据
    [originalSet minusSet:remain];
    // 新增的数据
    [currentSet minusSet:remain];
    
    [self removeUserGroups:[originalSet allObjects] add:[currentSet allObjects]];
}

- (void)removeUserGroups:(NSArray *)removedList add:(NSArray *)addList {
    //    NSString *tips = [NSString stringWithFormat:@"移除: %@, 新增: %@",
    //    [removedList componentsJoinedByString:@","],
    //                      [addList componentsJoinedByString:@","]];
    //    [self showTipsBy:tips];
    if (removedList.count) {
        [RCDUltraGroupManager unbindFromUserGroup:self.groupID
                                        channelID:self.channelID
                                       userGroups:removedList
                                         complete:^(RCDUltraGroupCode ret) {
            if (ret != RCDUltraGroupCodeSuccess) {
                [self showTipsBy:@"解除用户组绑定失败"];
                [self fetchData];
                return;
            }
            [self addNewUserGroups:addList];
        }];
    } else {
        [self addNewUserGroups:addList];
    }
}

- (void)back {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)addNewUserGroups:(NSArray *)array {
    if (!array.count) {
        //        [self showTipsBy:@"用户组绑定成功"];
        [self back];
        return;
    }
    [RCDUltraGroupManager bindToUserGroup:self.groupID channelID:self.channelID userGroups:array complete:^(RCDUltraGroupCode ret) {
        if (ret == RCDUltraGroupCodeSuccess) {
            [self showTipsBy:@"用户组绑定成功"];
            [self back];
        } else {
            [self showTipsBy:@"用户组绑定失败"];
        }
    }];
}
#pragma mark - RCDUserGroupUserSelectorDelegate

- (void)userDidSelectUserGroups:(NSArray<RCDUserGroupInfo *> *)userGroups {
    self.userGroups = userGroups;
    [self.userGroupView.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCDUserGroupInfo *info = self.userGroups[indexPath.row];
    [self showDetail:info];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserGroupInfo *info = self.userGroups[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDUserGroupChannelBelongViewIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RCDUserGroupChannelBelongViewIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    // ☃
    cell.detailTextLabel.text = [NSString stringWithFormat:@"👪 %ld 位成员", info.count];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ -> %@", info.name, info.userGroupID];;
    
    return cell;
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
        NSArray *originalUserGroupIDs = [self.originalUserGroups valueForKeyPath:@"userGroupID"];
        NSMutableSet *original = [NSMutableSet setWithArray:originalUserGroupIDs];
        NSMutableSet *changed = [NSMutableSet setWithArray:userGroupIds];
        [changed intersectSet:original];
        if (changed.count) {
            NSString *msg = [[changed allObjects] componentsJoinedByString:@","];
            [self showAlert:@"用户组解散" message:msg completion:^{
                [self fetchData];
            }];
            return;
        }
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"用户组解散: %@ -> %@", identifier.targetId, msg];
    [self showTipsBy:msg];
}

- (void)userAddedTo:(RCConversationIdentifier *)identifier
       userGroupIds:(NSArray<NSString *> *)userGroupIds {
    if ([identifier.targetId isEqualToString:self.groupID]) {
        NSArray *originalUserGroupIDs = [self.originalUserGroups valueForKeyPath:@"userGroupID"];
        NSMutableSet *original = [NSMutableSet setWithArray:originalUserGroupIDs];
        NSMutableSet *changed = [NSMutableSet setWithArray:userGroupIds];
        [changed intersectSet:original];
        if (changed.count) {
            NSString *msg = [[changed allObjects] componentsJoinedByString:@","];
            [self showAlert:@"新增成员" message:msg completion:^{
                [self fetchData];
            }];
            return;
        }
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"新增成员: %@ -> %@", identifier.targetId, msg];
    [self showTipsBy:msg];
}


- (void)userRemovedFrom:(RCConversationIdentifier *)identifier
           userGroupIds:(NSArray<NSString *> *)userGroupIds {
    if ([identifier.targetId isEqualToString:self.groupID]) {
        NSArray *originalUserGroupIDs = [self.originalUserGroups valueForKeyPath:@"userGroupID"];
        NSMutableSet *original = [NSMutableSet setWithArray:originalUserGroupIDs];
        NSMutableSet *changed = [NSMutableSet setWithArray:userGroupIds];
        [changed intersectSet:original];
        if (changed.count) {
            NSString *msg = [[changed allObjects] componentsJoinedByString:@","];
            [self showAlert:@"移除成员" message:msg completion:^{
                [self fetchData];
            }];
            return;
        }
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"移除成员: %@ -> %@", identifier.targetId, msg];
    [self showTipsBy:msg];
}


- (void)userGroupBindTo:(RCChannelIdentifier *)identifier
            channelType:(RCUltraGroupChannelType)channelType
           userGroupIds:(NSArray<NSString *> *)userGroupIds {
    if ([identifier.targetId isEqualToString:self.groupID]
        && [identifier.channelId isEqualToString:self.channelID]) {
        NSString *msg = [userGroupIds componentsJoinedByString:@","];
        [self showAlert:@"绑定用户组" message:msg completion:^{
            [self fetchData];
        }];
        return;
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"绑定用户组: %@(%@) -> %@", identifier.targetId, identifier.channelId, msg];
    [self showTipsBy:msg];
}


- (void)userGroupUnbindFrom:(RCChannelIdentifier *)identifier
                channelType:(RCUltraGroupChannelType)channelType
               userGroupIds:(NSArray<NSString *> *)userGroupIds {
    if ([identifier.targetId isEqualToString:self.groupID]
        && [identifier.channelId isEqualToString:self.channelID])  {
        
        NSString *msg = [userGroupIds componentsJoinedByString:@","];
        [self showAlert:@"解绑用户组" message:msg completion:^{
            [self fetchData];
        }];
        return;
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"解绑用户组: %@(%@) -> %@", identifier.targetId, identifier.channelId, msg];
    [self showTipsBy:msg];
}

#pragma mark - Property

- (RCDUserGroupChannelBelongView *)userGroupView {
    if (!_userGroupView) {
        _userGroupView = [RCDUserGroupChannelBelongView new];
        _userGroupView.tableView.delegate = self;
        _userGroupView.tableView.dataSource = self;
        [_userGroupView.btnEdit addTarget:self
                                   action:@selector(showSelector)
                         forControlEvents:UIControlEventTouchUpInside];
        if (!self.isOwner) {
            _userGroupView.btnEdit.hidden = YES;
        }
    }
    return _userGroupView;
}
@end
