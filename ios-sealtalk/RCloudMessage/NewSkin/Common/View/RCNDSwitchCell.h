//
//  RCNDSwitchCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCell.h"
extern NSString  * _Nonnull const RCNDSwitchCellIdentifier;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDSwitchCell : RCNDBaseCell
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UILabel *labelTitle;
@end

NS_ASSUME_NONNULL_END
