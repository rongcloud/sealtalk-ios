//
//  RCDChannelUserInfoCell.h
//  SealTalk
//
//  Created by RobinCui on 2022/6/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDChannelUserInfoCellViewModel.h"
NS_ASSUME_NONNULL_BEGIN

extern NSString * const RCDChannelUserInfoCellIdentifier;

@interface RCDChannelUserInfoCell : UICollectionViewCell
- (void)updateCellWith:(RCDChannelUserInfoCellViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
