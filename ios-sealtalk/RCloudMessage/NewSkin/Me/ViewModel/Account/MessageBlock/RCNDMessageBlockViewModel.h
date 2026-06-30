//
//  RCNDMessageBlockViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol RCNDMessageBlockViewModelDelegate <NSObject>

- (void)showDatePicker:(NSDate *)date;

@end
@interface RCNDMessageBlockViewModel : RCNDBaseListViewModel
@property (nonatomic, weak) id<RCNDMessageBlockViewModelDelegate> dateDelegate;
- (CGFloat)heightForHeaderInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (void)fetchAllData;
- (void)refreshTime:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END
