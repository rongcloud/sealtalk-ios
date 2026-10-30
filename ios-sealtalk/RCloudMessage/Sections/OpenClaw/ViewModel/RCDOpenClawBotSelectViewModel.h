//
//  RCDOpenClawBotSelectViewModel.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDOpenClawBotListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawBotSelectViewModel : RCDOpenClawBotListViewModel

@property (nonatomic, copy, readonly) NSString *groupId;

- (instancetype)initWithGroupId:(NSString *)groupId
                  existingBotIds:(NSArray<NSString *> *)existingBotIds;
- (BOOL)isBotAlreadyAddedAtIndex:(NSInteger)index;
- (BOOL)isBotAlreadyAdded:(nullable RCDOpenClawBot *)bot;
- (void)addBotAtIndex:(NSInteger)index success:(void (^)(RCDOpenClawBot *bot))success error:(RCDOpenClawViewModelErrorBlock)error;
- (NSArray<RCDOpenClawBot *> *)botsWithBotIds:(NSArray<NSString *> *)botIds;
- (void)addBotsWithBotIds:(NSArray<NSString *> *)botIds
                  success:(void (^)(NSArray<RCDOpenClawBot *> *bots))success
                    error:(RCDOpenClawViewModelErrorBlock)error;

@end

NS_ASSUME_NONNULL_END
