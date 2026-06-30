//
//  RCNDAccountSettingViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol RCNDAccountSettingViewModelDelegate <NSObject>

- (void)userDidSelectedCleanCache;

@end
@interface RCNDAccountSettingViewModel : RCNDBaseListViewModel
@property (nonatomic, weak) id<RCNDAccountSettingViewModelDelegate> accountDelegate;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (CGFloat)heightForHeaderInSection:(NSInteger)section;
- (void)clearCache:(void(^)(void))completion;
- (void)removeAccount:(void (^)(BOOL success))completeBlock;
+ (void)clearAccountInfo;
@end

NS_ASSUME_NONNULL_END
