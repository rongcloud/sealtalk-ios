//
//  RCNDMemberRemoveCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDImageCell.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString  * const RCNDMemberRemoveCellIdentifier;
@interface RCNDMemberRemoveCell : RCNDImageCell
@property (nonatomic, strong) RCButton *actionButton;
@end

NS_ASSUME_NONNULL_END
