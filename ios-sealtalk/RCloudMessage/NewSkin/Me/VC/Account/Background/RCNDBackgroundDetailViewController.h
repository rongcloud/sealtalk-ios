//
//  RCNDBackgroundDetailViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewController.h"
#import "RCNDPreinstallPhotoCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDBackgroundDetailViewController : RCNDBaseViewController
- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithViewModel:(RCNDPreinstallPhotoCellViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
