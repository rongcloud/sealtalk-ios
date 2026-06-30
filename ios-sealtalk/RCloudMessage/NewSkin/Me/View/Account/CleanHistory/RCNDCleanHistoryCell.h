//
//  RCNDCleanHistoryCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDImageCell.h"
extern NSString  * _Nonnull const RCNDCleanHistoryCellIdentifier;
NS_ASSUME_NONNULL_BEGIN
@interface RCNDCleanHistoryCell : RCNDImageCell
@property (nonatomic, strong) UIImageView *imageCheckBox;
-  (void)refreshState:(RCNDBaseCellViewModel *)vm;
@end

NS_ASSUME_NONNULL_END
