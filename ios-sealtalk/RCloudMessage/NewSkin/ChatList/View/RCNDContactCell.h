//
//  RCNDContactCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDImageCell.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString  * const RCNDContactCellIdentifier;
@interface RCNDContactCell : RCNDImageCell
@property (nonatomic, strong) UIImageView *imageCheckBox;
-  (void)refreshState:(RCNDBaseCellViewModel *)vm;
@end

NS_ASSUME_NONNULL_END
