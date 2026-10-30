//
//  RCNDMeViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCNDMeViewModel : RCNDBaseListViewModel
- (void)clearAccountInfo;
+ (void)fetchMyProfile:(void(^)(RCUserProfile * _Nullable userProfile))completion;
@end

NS_ASSUME_NONNULL_END
