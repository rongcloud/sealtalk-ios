//
//  RCDUGChannelSettingViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/6/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"
#import "RCDUGChannelSettingViewModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface RCDUGChannelSettingViewController : RCDTableViewController
- (instancetype)initWithViewModel:(RCDUGChannelSettingViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
