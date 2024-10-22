//
//  RCUChatViewController.m
//  SealTalk
//
//  Created by RobinCui on 2024/8/31.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUChatViewController.h"
@interface RCDChatViewController ()
- (void)setRightNavigationItem:(UIImage *)image;
- (void)rightBarButtonItemClicked:(id)sender;
@end
@interface RCUChatViewController ()<RCGroupEventDelegate>
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
    if (self.needPopToRootView) {
        if (self.navigationController.viewControllers.count > 2) {
            self.navigationController.viewControllers = @[self.navigationController.viewControllers.firstObject, self.navigationController.viewControllers.lastObject];
        }
    }
}


- (void)refreshUserInfoOrGroupInfo {
    if (self.conversationType == ConversationType_GROUP) {
        [[RCCoreClient sharedCoreClient] getGroupsInfo:@[self.targetId ? : @""] success:^(NSArray<RCGroupInfo *> * _Nonnull groupInfos) {
            RCLogI(@"zgh refresh groupInfo, groupId: %@, memberCount:%@", self.targetId, @(groupInfos.firstObject.membersCount));
            if (groupInfos.firstObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = [NSString stringWithFormat:@"%@(%@)", groupInfos.firstObject.groupName, @(groupInfos.firstObject.membersCount)];
                });
            }
        } error:^(RCErrorCode errorCode) {
            RCLogI(@"zgh refresh groupInfo, groupId: %@, error:%@", self.targetId, @(errorCode));
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
        [self checkUserInGroup:3 complete:^(BOOL isIn) {
            if (isIn) {
                [self setRightNavigationItem:[UIImage imageNamed:@"Setting"]];
            } else {
                [self setRightNavigationItem:nil];
            }
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
        return;
    }
    [super rightBarButtonItemClicked:sender];
}

- (void)didTapCellPortrait:(NSString *)userId {
    RCProfileViewModel *viewModel = [RCUserProfileViewModel viewModelWithUserId:userId];
    RCProfileViewController *vc = [[RCProfileViewController alloc] initWithViewModel:viewModel];
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (void)checkUserInGroup:(NSUInteger)tryCount complete:(void (^)(BOOL isIn))complete {
    if (tryCount <= 0) {
        return complete(NO);
    }
    [[RCCoreClient sharedCoreClient] getGroupMembers:self.targetId userIds:@[[RCCoreClient sharedCoreClient].currentUserInfo.userId ? : @""] success:^(NSArray<RCGroupMemberInfo *> * _Nonnull groupMembers) {
        if (groupMembers.firstObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(YES);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(NO);
            });
        }
    } error:^(RCErrorCode errorCode) {
        if (errorCode == NET_DATA_IS_SYNCHRONIZING) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self checkUserInGroup:tryCount-1 complete:complete];
            });
        } else {
            complete(NO);
        }
    }];
}

#pragma mark -- RCGroupEventDelegate

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
