//
//  RCNDBaseTableViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewController.h"
#import "RCNDBaseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface RCNDBaseTableViewController : RCNDBaseViewController<UITableViewDelegate, UITableViewDataSource,RCNDBaseListViewModelDelegate>
@property (nonatomic, strong) RCSearchBarListView *listView;
@property (nonatomic, strong) RCNDBaseListViewModel *viewModel;
- (instancetype)initWithViewModel:(RCNDBaseListViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
