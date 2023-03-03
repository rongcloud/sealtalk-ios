//
//  RCDUserGroupCreateView.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupBaseView.h"
#import "RCDUserGroupMemberCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupCreateView : RCDUserGroupBaseView
@property(nonatomic, strong, readonly) UITextField *txtName;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *btnSelect;

@end

NS_ASSUME_NONNULL_END
