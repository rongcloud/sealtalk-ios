//
//  RCDUGChannelSettingCell.h
//  SealTalk
//
//  Created by RobinCui on 2022/6/21.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString * const RCDUGChannelSettingCellIdentifier;
@interface RCDUGChannelSettingCell : UITableViewCell
- (void)updateCellWith:(NSString *)title subtitle:(NSString *)subtitle;

@end

NS_ASSUME_NONNULL_END
