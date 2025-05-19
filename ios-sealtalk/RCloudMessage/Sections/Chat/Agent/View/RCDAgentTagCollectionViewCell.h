//
//  RCDAgentTagCollectionViewCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RCDAgentTagCollectionCellViewModel.h"


NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString * _Nullable const RCDAgentTagCollectionViewCellIdentifier;

@interface RCDAgentTagCollectionViewCell : RCBaseCollectionViewCell
- (void)updateCellWithViewModel:(RCDAgentTagCollectionCellViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
