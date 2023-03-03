//
//  RCDUserGroupDetailViewController.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupDetailViewController.h"
#import "RCDUserGroupDetailView.h"
#import "RCDUserGroupUserSelectorViewController.h"
#import "RCDUserGroupMemberCell.h"
#import "UIView+MBProgressHUD.h"
#import "RCDUltraGroupManager.h"
#import "RCDUtilities.h"
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCDUserGroupDetailViewController ()<UITableViewDelegate,UITableViewDataSource,
RCUserGroupStatusDelegate,
RCDUserGroupUserSelectorDelegate>
@property(nonatomic, strong) RCDUserGroupDetailView *detailView;
@property(nonatomic, strong) NSArray<RCDUserGroupMemberInfo *> *dataSource;
@property(nonatomic, strong) NSArray<RCDUserGroupMemberInfo *> *originalMembers;
@property(nonatomic, strong) RCDUserGroupInfo *userGroup;
@end

@implementation RCDUserGroupDetailViewController

- (instancetype)initWithUserGroup:(RCDUserGroupInfo *)userGroup
{
    self = [super init];
    if (self) {
        self.userGroup = userGroup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isOwner) {
        [self createSubmitBtn];
    }
    [self fetchData];
}

- (void)loadView {
    self.view = self.detailView;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[RCChannelClient sharedChannelManager] setUserGroupStatusDelegate:self];
}


- (void)fetchData {
    [self.view showLoading];
    [RCDUltraGroupManager queryUserGroupMembers:self.userGroup.groupID userGroupID:self.userGroup.userGroupID
                                       complete:^(NSArray *array, RCDUltraGroupCode ret) {
        if (ret != RCDUltraGroupCodeSuccess) {
            [self showTipsBy:@"请求频道用户组失败"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view hideLoading];
                
            });
            return;
        }
        NSMutableArray *members = [NSMutableArray array];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in array) {
                RCDUserGroupMemberInfo *info = [RCDUserGroupMemberInfo new];
                info.userID = dic[@"id"];
                info.name = dic[@"nickname"];
                info.groupID = self.userGroup.groupID;
                [members addObject:info];
            }
        }
        [self fillMemberInfoWith:members];
    }];
    
}

- (void)fillMemberInfoWith:(NSArray *)memberIdList {
    NSMutableArray *array = [NSMutableArray array];
    for (RCDUserGroupMemberInfo *info in memberIdList) {
        [RCDUtilities getGroupUserDisplayInfo:info.userID
                                      groupId:info.groupID
                                       result:^(RCUserInfo *user) {
            info.portrait = user.portraitUri;
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataSource = memberIdList;
        self.originalMembers = memberIdList;
        [self.detailView.tableView reloadData];
        [self.view hideLoading];
    });
}

#pragma mark - RCDUserGroupUserSelectorDelegate

- (void)userDidSelectMembers:(NSArray<RCDUserGroupMemberInfo *> *)members
                    original:(nonnull NSArray<NSString *> *)userIDs {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataSource = members;
        [self.detailView.tableView reloadData];
    });
}


#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.detailView.txtName resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    info.isSelected = NO;
    [cell updateCell:info];
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
    if ([identifier.targetId isEqualToString:self.userGroup.groupID]) {
        if ([userGroupIds containsObject:self.userGroup.userGroupID]) {
            NSString *msg = [userGroupIds componentsJoinedByString:@","];
            [self showAlert:@"用户组解散" message:msg completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            return;
        }
    }
    NSString *msg = [userGroupIds componentsJoinedByString:@","];
    msg = [NSString stringWithFormat:@"解散用户组: %@ -> %@", identifier.targetId, msg];
    [self showTipsBy:msg];
}

- (void)userAddedTo:(RCConversationIdentifier *)identifier
       userGroupIds:(NSArray<NSString *> *)userGroupIds {
    if ([identifier.targetId isEqualToString:self.userGroup.groupID]) {
        if ([userGroupIds containsObject:self.userGroup.userGroupID]) {
            NSString *msg = [userGroupIds componentsJoinedByString:@","];
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
    if ([identifier.targetId isEqualToString:self.userGroup.groupID]) {
        if ([userGroupIds containsObject:self.userGroup.userGroupID]) {
            NSString *msg = [userGroupIds componentsJoinedByString:@","];
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

#pragma mark - Private

- (void)showTipsBy:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}

- (void)btnSubmitClick {
    [self.detailView.txtName resignFirstResponder];
    if (self.detailView.txtName.text.length == 0) {
        [self showTipsBy:@"名称不能为空"];
        return;
    }
    [self updateMembers];
}

- (void)updateMembers {
    NSArray *original = [self.originalMembers valueForKeyPath:@"userID"];
    NSArray *current = [self.dataSource valueForKeyPath:@"userID"];
    NSMutableSet *originalSet = [NSMutableSet setWithArray:original];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:current];
    
    NSMutableSet *remain = [originalSet mutableCopy];
    // 没有变化的UserID
    [remain intersectSet:currentSet];
    // 删除的数据
    [originalSet minusSet:remain];
    // 新增的数据
    [currentSet minusSet:remain];
    
    [self removeUsers:[originalSet allObjects] add:[currentSet allObjects]];
}

- (void)removeUsers:(NSArray *)removedList add:(NSArray *)addList {
//    NSString *tips = [NSString stringWithFormat:@"移除: %@, 新增: %@",
//                      [removedList componentsJoinedByString:@","],
//                      [addList componentsJoinedByString:@","]];
//    [self showTipsBy:tips];
    if (removedList.count) {
        [RCDUltraGroupManager removeFromUserGroup:self.userGroup.groupID
                                      userGroupID:self.userGroup.userGroupID
                                          members:removedList complete:^(RCDUltraGroupCode ret) {
            [self fetchData];
            if (ret == RCDUltraGroupCodeSuccess) {
                [self showTipsBy:@"删除成员成功"];
            } else {
                [self showTipsBy:@"删除成员失败, 请重试"];
                return;
            }
            [self addMembers:addList];
        }];
    } else {
        [self addMembers:addList];
    }
}

- (void)addMembers:(NSArray *)members {
    if (members.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [RCDUltraGroupManager addToUserGroup:self.userGroup.groupID
                             userGroupID:self.userGroup.userGroupID
                                 members:members
                                complete:^(RCDUltraGroupCode ret) {
        [self fetchData];
        if (ret == RCDUltraGroupCodeSuccess) {
            [self showTipsBy:@"添加成员成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showTipsBy:@"添加成员失败, 请重试"];
        }
    }];
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

- (void)editMembers {
    [self.detailView.txtName resignFirstResponder];
    RCDUserGroupUserSelectorViewController *vc = [RCDUserGroupUserSelectorViewController new];
    vc.delegate = self;
    vc.groupID = self.userGroup.groupID;
    vc.userIDs = [self.dataSource valueForKeyPath:@"self.userID"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Property
- (RCDUserGroupDetailView *)detailView {
    if (!_detailView) {
        _detailView = [RCDUserGroupDetailView new];
        _detailView.tableView.dataSource = self;
        _detailView.tableView.delegate = self;
        [_detailView.btnSelect addTarget:self
                                  action:@selector(editMembers)
                        forControlEvents:UIControlEventTouchUpInside];
        _detailView.txtName.text = self.userGroup.name;
        if (!self.isOwner) {
            _detailView.btnSelect.hidden = YES;
        }
    }
    return _detailView;
}

@end
