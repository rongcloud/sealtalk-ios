//
//  RCNDAboutIconCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCellViewModel.h"
#import "RCNDAboutIconCell.h"
#import "RCNDCommonCellViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDAboutIconCellViewModel : RCNDBaseCellViewModel
@property (nonatomic, copy) RCNDCommonCellViewModelBlock tapBlock;
- (instancetype)initWithTapBlock:(RCNDCommonCellViewModelBlock)tapBlock;
@end

NS_ASSUME_NONNULL_END
