//
//  RCDUserGroupDetailView.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupDetailView : RCDUserGroupBaseView
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *btnSelect;
@property(nonatomic, strong) UITextField *txtName;

@end

NS_ASSUME_NONNULL_END
