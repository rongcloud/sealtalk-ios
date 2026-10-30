//
//  RCNDSearchViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/28.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchViewModel : RCNDBaseListViewModel
- (UIView *)searchBar;
- (void)endEditingState;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (CGFloat)heightForHeaderInSection:(NSInteger)section;
- (void)becomeFirstResponder;
@end

NS_ASSUME_NONNULL_END
