//
//  RCDUserGroupUserSelectorView.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupUserSelectorView : RCDUserGroupBaseView
@property(nonatomic, strong, readonly) UISearchBar *searchBar;
@property(nonatomic, strong, readonly) UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
