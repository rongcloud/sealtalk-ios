//
//  RCNDDataCenterViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDDataCenterViewModel : RCNDBaseListViewModel
- (instancetype)initWithBlock:(void(^)(NSString *name))completion;
+ (NSString *)currentDataCenter;

+ (void)refreshEnvironmentStatus;
@end

NS_ASSUME_NONNULL_END
