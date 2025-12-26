//
//  RCNDCommonCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCellViewModel.h"
#import "RCNDCommonCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^RCNDCommonCellViewModelBlock)(UIViewController *vc);

@interface RCNDCommonCellViewModel : RCNDBaseCellViewModel
@property (nonatomic, copy) RCNDCommonCellViewModelBlock tapBlock;
@property (nonatomic, assign) BOOL hideArrow;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
- (instancetype)initWithTapBlock:(RCNDCommonCellViewModelBlock __nullable)tapBlock;
@end

NS_ASSUME_NONNULL_END
