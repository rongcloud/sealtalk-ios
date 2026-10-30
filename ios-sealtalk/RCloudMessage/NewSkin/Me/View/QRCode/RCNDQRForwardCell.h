//
//  RCNDQRForwardCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCell.h"
NSString  * const RCNDQRForwardCellIdentifier;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDQRForwardCell : RCNDBaseCell
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIImageView *imageViewPortrait;
@end

NS_ASSUME_NONNULL_END
