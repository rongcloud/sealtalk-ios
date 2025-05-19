//
//  RCDAgentSettingViewCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RCDAgentSettingSwitchCellViewModel.h"
NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString * _Nullable const RCDAgentSettingViewCellIdentifier;

typedef NS_ENUM(NSInteger, RCDAgentSettingViewCellType) {
    RCDAgentSettingViewCellTypeNone,
    RCDAgentSettingViewCellTypeTop,
    RCDAgentSettingViewCellTypeMiddle,
    RCDAgentSettingViewCellTypeBottom
};
@interface RCDAgentSettingViewCell : RCBaseTableViewCell
- (void)updateCellWithViewModel:(RCDAgentSettingSwitchCellViewModel *)viewModel
                           type:(RCDAgentSettingViewCellType)type;
@end

NS_ASSUME_NONNULL_END
