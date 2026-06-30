//
//  RCNDRadioCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCommonCell.h"

extern NSString  * _Nonnull const RCNDRadioCellIdentifier;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDRadioCell : RCNDCommonCell
@property (nonatomic, strong) UIImageView *imageViewRadio;
@end

NS_ASSUME_NONNULL_END
