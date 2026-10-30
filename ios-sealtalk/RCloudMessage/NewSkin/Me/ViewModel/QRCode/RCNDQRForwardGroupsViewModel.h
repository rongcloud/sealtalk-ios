//
//  RCNDQRForwardGroupsViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import "RCNDQRForwardConversationViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDQRForwardGroupsViewModel : RCNDBaseListViewModel
@property (nonatomic, weak) id<RCNDQRForwardConversationViewModelDelegate> forwardDelegate;
- (void)loadMore:(void(^)(BOOL noMoreData))completion;
/// 获取数据
- (void)fetchData:(void(^)(BOOL noMoreData))completion;
@end

NS_ASSUME_NONNULL_END
