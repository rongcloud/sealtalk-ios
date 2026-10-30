//
//  RCNDBaseCollectionViewCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RCNDBaseCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDBaseCollectionViewCell : RCBaseCollectionViewCell
- (void)setupView;

- (void)setupConstraints;
    
- (void)updateWithViewModel:(RCBaseCellViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
