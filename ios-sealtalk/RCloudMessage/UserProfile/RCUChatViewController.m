//
//  RCUChatViewController.m
//  SealTalk
//
//  Created by RobinCui on 2024/8/31.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUChatViewController.h"
#import "RCUGroupNotificationMessage.h"
#import "RCUTipMessageCell.h"


@interface RCDChatViewController ()
- (void)setRightNavigationItem:(UIImage *)image;
@end

@interface RCUChatViewController ()<RCGroupEventDelegate>
- (void)rightBarButtonItemClicked:(id)sender;
@end

@implementation RCUChatViewController

- (id)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId {
    self = [super initWithConversationType:conversationType
                                  targetId:targetId];
    if (self) {
        [[RCCoreClient sharedCoreClient] addGroupEventDelegate:self];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[RCCoreClient sharedCoreClient] addGroupEventDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUserInfoOrGroupInfo];
}

- (void)dealloc {
    [[RCCoreClient sharedCoreClient] removeGroupEventDelegate:self];
}

- (void)registerCustomCellsAndMessages {
    [super registerCustomCellsAndMessages];
    [self registerClass:RCUTipMessageCell.class forMessageClass:RCUGroupNotificationMessage.class];
}


- (void)refreshUserInfoOrGroupInfo {
    if (self.conversationType == ConversationType_GROUP) {
        [[RCCoreClient sharedCoreClient] getGroupsInfo:@[self.targetId ? : @""] success:^(NSArray<RCGroupInfo *> * _Nonnull groupInfos) {
            RCLogI(@"zgh refresh groupInfo, groupId: %@, memberCount:%@", self.targetId, @(groupInfos.firstObject.membersCount));
            if (groupInfos.firstObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *title = groupInfos.firstObject.remark.length > 0 ? groupInfos.firstObject.remark : groupInfos.firstObject.groupName;
                    self.title = [NSString stringWithFormat:@"%@(%@)", title, @(groupInfos.firstObject.membersCount)];
                });
            }
        } error:^(RCErrorCode errorCode) {
        }];
    } else if (self.conversationType == ConversationType_PRIVATE) {
        [[RCCoreClient sharedCoreClient] getFriendsInfo:@[self.targetId?:@""] success:^(NSArray<RCFriendInfo *> * _Nonnull friendInfos) {
            if (friendInfos.firstObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = friendInfos.firstObject.remark.length > 0 ? friendInfos.firstObject.remark : friendInfos.firstObject.name;
                });
            } else {
                [[RCCoreClient sharedCoreClient] getUserProfiles:@[self.targetId?:@""] success:^(NSArray<RCUserProfile *> * _Nonnull userProfiles) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.title = userProfiles.firstObject.name;
                    });
                } error:^(RCErrorCode errorCode) {
                    
                }];
            }
        } error:^(RCErrorCode errorCode) {
            
        }];
    }
}

- (void)setRightNavigationItems {
    self.navigationItem.rightBarButtonItem = nil;
    if (self.conversationType == ConversationType_GROUP) {
        [[RCCoreClient sharedCoreClient] getGroupMembers:self.targetId userIds:@[[RCCoreClient sharedCoreClient].currentUserInfo.userId ? : @""] success:^(NSArray<RCGroupMemberInfo *> * _Nonnull groupMembers) {
            if (groupMembers.firstObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setRightNavigationItem:[UIImage imageNamed:@"Setting"]];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setRightNavigationItem:nil];
                });
            }
        } error:^(RCErrorCode errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setRightNavigationItem:nil];

            });
        }];
    } else if (self.conversationType == ConversationType_CHATROOM) {
        [self setRightNavigationItem:nil];
    } else {
        [self setRightNavigationItem:[UIImage imageNamed:@"Setting"]];
    }
}
/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
    if (self.conversationType == ConversationType_GROUP) {
        RCGroupProfileViewModel *viewModel = [RCGroupProfileViewModel viewModelWithGroupId:self.targetId];
        RCProfileViewController *vc = [[RCProfileViewController alloc] initWithViewModel:viewModel];
        [self.navigationController pushViewController:vc
                                             animated:YES];
    } else if (self.conversationType == ConversationType_PRIVATE){
        RCProfileViewModel *viewModel = [RCUserProfileViewModel viewModelWithUserId:self.targetId];
        RCProfileViewController *vc = [[RCProfileViewController alloc] initWithViewModel:viewModel];
        [self.navigationController pushViewController:vc
                                             animated:YES];
    } 
}

- (void)didTapCellPortrait:(NSString *)userId {
    RCProfileViewModel *viewModel = [RCUserProfileViewModel viewModelWithUserId:userId];
    if (self.conversationType == ConversationType_GROUP && [viewModel isKindOfClass:RCUserProfileViewModel.class]) {
        [(RCUserProfileViewModel *)viewModel showGroupMemberInfo:self.targetId];
    }
    RCProfileViewController *vc = [[RCProfileViewController alloc] initWithViewModel:viewModel];
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

#pragma mark -- RCGroupEventDelegate

- (void)onGroupInfoChanged:(RCGroupMemberInfo *)operatorInfo groupInfo:(RCGroupInfo *)groupInfo updateKeys:(NSArray<RCGroupInfoKeys> *)updateKeys operationTime:(long long)operationTime {
    if (self.conversationType != ConversationType_GROUP || ![groupInfo.groupId isEqualToString:self.targetId]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshUserInfoOrGroupInfo];
    });
}

- (void)onGroupOperation:(NSString *)groupId operatorInfo:(RCGroupMemberInfo *)operatorInfo groupInfo:(RCGroupInfo *)groupInfo operation:(RCGroupOperation)operation memberInfos:(NSArray<RCGroupMemberInfo *> *)memberInfos operationTime:(long long)operationTime {
    RCLogI(@"zgh group operation, groupId: %@, operation:%@", groupId, @(operation));
    if (self.conversationType != ConversationType_GROUP || ![groupId isEqualToString:self.targetId]) {
        return;
    }
    if (operation == RCGroupOperationJoin || operation == RCGroupOperationKick || operation == RCGroupOperationQuit  || operation == RCGroupOperationDismiss) {
        RCLogI(@"zgh group operation action , refresh groupInfo, groupId: %@, operation:%@", groupId, @(operation));
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setRightNavigationItems];
            [self refreshUserInfoOrGroupInfo];
        });
    }
}

@end
