//
//  RCNDConversationSelectViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardConversationViewModel.h"
#import "RCNDQRForwardConversationCellViewModel.h"
#import "RCNDQRForwardCell.h"
#import "RCNDCommonCellViewModel.h"
#import "RCNDQRForwardFriendsViewController.h"
#import "RCNDQRForwardGroupsViewController.h"


@interface RCNDQRForwardConversationViewModel()<RCNDQRForwardConversationViewModelDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSArray *conversations;
@end


@implementation RCNDQRForwardConversationViewModel

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDQRForwardCell class]
      forCellReuseIdentifier:RCNDQRForwardCellIdentifier];
    [tableView registerClass:[RCNDCommonCell class]
      forCellReuseIdentifier:RCNDCommonCellIdentifier];
}

- (void)ready {
    self.dataSource = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    RCNDCommonCellViewModel *friends = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        RCNDQRForwardFriendsViewModel *vm = [RCNDQRForwardFriendsViewModel new];
        vm.forwardDelegate = self;
        RCNDQRForwardFriendsViewController *controller = [[RCNDQRForwardFriendsViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    friends.title = RCDLocalizedString(@"SelectedFriend");
    RCNDCommonCellViewModel *groups = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        RCNDQRForwardGroupsViewModel *vm = [RCNDQRForwardGroupsViewModel new];
        vm.forwardDelegate = self;
        RCNDQRForwardGroupsViewController *controller = [[RCNDQRForwardGroupsViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    groups.title = RCDLocalizedString(@"SelectGroupConversation");
    
    [self.dataSource addObject:@[friends, groups]];
}

- (void)fetchData {
    NSMutableArray *array = [NSMutableArray array];
    [[RCCoreClient sharedCoreClient] getConversationList:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP)]
                                                   count:10
                                               startTime:0
                                              completion:^(NSArray<RCConversation *> * _Nullable conversationList) {
        for (RCConversation *conversation in conversationList) {
            RCNDQRForwardConversationCellViewModel *vm = [[RCNDQRForwardConversationCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
                
            }];
            vm.info = conversation;
            [array addObject:vm];
        }
        [self.dataSource addObject:array];
        [self reloadData];
    }];
}

- (void)reloadData {
    [self removeSeparatorLineIfNeed:self.dataSource];
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
   viewController:(UIViewController *)controller {
    [super tableView:tableView
didSelectRowAtIndexPath:indexPath
      viewController:controller];
    if (indexPath.section != 0) {
        RCNDBaseCellViewModel *vm = [self  cellViewModelAtIndexPath:indexPath];
        if ([vm isKindOfClass:[RCNDQRForwardSelectCellViewModel class]]) {
            [self userDidSelectedForwardViewModel:(RCNDQRForwardSelectCellViewModel *)vm
                             parentViewController:controller];
        }
    }
}

#pragma mark - RCNDQRForwardConversationViewModelDelegate
- (void)userDidSelectedForwardViewModel:(RCNDQRForwardSelectCellViewModel *)viewModel
                   parentViewController:(nonnull UIViewController *)parentViewController {
    if ([self.forwardDelegate respondsToSelector:@selector(userDidSelectedForwardViewModel:parentViewController:)]) {
        [self.forwardDelegate userDidSelectedForwardViewModel:viewModel
                                         parentViewController:parentViewController];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
     NSArray *array = self.dataSource[section];
    return array.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataSource[indexPath.section];
   return array[indexPath.row];
}
@end
