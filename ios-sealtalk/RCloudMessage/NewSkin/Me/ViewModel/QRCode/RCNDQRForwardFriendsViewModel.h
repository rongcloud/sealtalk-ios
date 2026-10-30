//
//  RCNDQRForwardFriendsViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/4.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import "RCNDQRForwardConversationViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDQRForwardFriendsViewModel : RCNDBaseListViewModel
@property (nonatomic, weak) id<RCNDQRForwardConversationViewModelDelegate> forwardDelegate;
@property (nonatomic, strong) NSArray *dataSource;
- (void)fetchData;
@end

NS_ASSUME_NONNULL_END
