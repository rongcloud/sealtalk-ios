//
//  RCNDImageCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCommonCell.h"

extern NSString  * _Nonnull const RCNDImageCellIdentifier;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDImageCell : RCNDCommonCell
@property (nonatomic, strong) UIImageView *imageViewIcon;
@end

NS_ASSUME_NONNULL_END
