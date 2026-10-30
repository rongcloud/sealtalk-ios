//
//  RCNDThemeViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDThemeViewModel : RCNDBaseListViewModel

- (instancetype)initWithBlock:(void(^)(NSString *))themeSavedBlock;
- (void)save;
+ (NSString *)currentThemeTitle;
@end

NS_ASSUME_NONNULL_END
