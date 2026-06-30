//
//  RCNDBaseCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RCNDBaseCellViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDBaseCell : RCPaddingTableViewCell
@property (nonatomic, strong) UIStackView *contentStackView;
@property (nonatomic, strong) RCNDBaseCellViewModel *viewModel;
- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
