//
//  RCDUserGroupListView.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupListView : RCDUserGroupBaseView
@property(nonatomic, strong, readonly) UITableView *tableView;
- (void)userGrouListEnable:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
