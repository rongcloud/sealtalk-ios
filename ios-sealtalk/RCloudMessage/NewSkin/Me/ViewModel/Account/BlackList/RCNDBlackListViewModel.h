//
//  RCNDBlackListViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDBlackListViewModel : RCNDBaseListViewModel
- (UIView *)searchBar;
- (void)endEditingState;
- (void)fetchAllData;
@end

NS_ASSUME_NONNULL_END
