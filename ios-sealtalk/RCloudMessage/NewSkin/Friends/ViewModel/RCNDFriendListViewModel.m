//
//  RCNDFriendListViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDFriendListViewModel.h"
#import "RCNDSearchFriendsViewController.h"

@interface  RCFriendListViewModel()
- (void)showSearchFriends;
@property (nonatomic, weak) UIViewController <RCListViewModelResponder> *responder;

@end

@implementation RCNDFriendListViewModel
- (void)showSearchFriends {
    RCSearchFriendsViewModel *viewModel = [[RCSearchFriendsViewModel alloc] init];
    RCNDSearchFriendsViewController *vc = [[RCNDSearchFriendsViewController alloc] initWithViewModel:viewModel];
    [self.responder.navigationController pushViewController:vc animated:YES];
}
@end
