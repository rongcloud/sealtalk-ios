//
//  RCNDSwitchCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCellViewModel.h"
#import "RCNDSwitchCell.h"

// 1. 定义内部 block 类型（接收 bool 参数）
typedef void (^RCNDSwitchCellViewModelInnerBoolBlock)(BOOL isSuccess);

// 2. 定义外层 block 类型（参数为内部 block）
typedef void (^RCNDSwitchCellViewModelOuterBlock)(BOOL switchOn,
                                                  RCNDSwitchCellViewModelInnerBoolBlock _Nullable innerBlock);
NS_ASSUME_NONNULL_BEGIN

@interface RCNDSwitchCellViewModel : RCNDBaseCellViewModel
@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithSwitchOn:(BOOL)switchOn
                     switchBlock:(RCNDSwitchCellViewModelOuterBlock)block;

- (void)switchValueChanged:(UISwitch *)switchView
completion:(RCNDSwitchCellViewModelInnerBoolBlock)completion;
@end

NS_ASSUME_NONNULL_END
