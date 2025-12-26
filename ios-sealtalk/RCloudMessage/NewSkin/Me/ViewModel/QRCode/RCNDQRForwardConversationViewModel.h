//
//  RCNDQRForwardConversationViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import <RongIMKit/RongIMKit.h>
#import "RCNDQRForwardSelectCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol RCNDQRForwardConversationViewModelDelegate <NSObject>

- (void)userDidSelectedForwardViewModel:(RCNDQRForwardSelectCellViewModel *)viewModel
                   parentViewController:(UIViewController *)controller;

@end
@interface RCNDQRForwardConversationViewModel : RCNDBaseListViewModel
@property (nonatomic, weak) id<RCNDQRForwardConversationViewModelDelegate> forwardDelegate;
- (void)fetchData;
@end

NS_ASSUME_NONNULL_END
