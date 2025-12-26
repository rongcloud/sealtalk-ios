//
//  RCNDCommonCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCell.h"

extern NSString  * _Nonnull const RCNDCommonCellIdentifier;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDCommonCell : RCNDBaseCell
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelSubtitle;
@property (nonatomic, strong) UIImageView *imageViewArrow;
@end

NS_ASSUME_NONNULL_END
