//
//  RCDOpenClawGroupBotListViewModel.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDOpenClawBotListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawGroupBotListViewModel : RCDOpenClawBotListViewModel

@property (nonatomic, copy, readonly) NSString *groupId;
@property (nonatomic, assign, readonly) BOOL canManage;

- (instancetype)initWithGroupId:(NSString *)groupId canManage:(BOOL)canManage;
- (NSArray<NSString *> *)existingBotIds;
- (void)loadGroupBotsWithSuccess:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error;
- (void)removeBotAtIndex:(NSInteger)index success:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error;
- (void)sendBotInviteNotification:(RCDOpenClawBot *)bot;

@end

NS_ASSUME_NONNULL_END
