//
//  RCDOpenClawBotListViewModel.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDOpenClawViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawBotListViewModel : NSObject

@property (nonatomic, copy, readonly) NSArray<RCDOpenClawBot *> *bots;

- (void)loadBotsWithSuccess:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error;
- (NSInteger)numberOfBots;
- (nullable RCDOpenClawBot *)botAtIndex:(NSInteger)index;
- (NSArray<RCDOpenClawBot *> *)allLoadedBots;
- (NSString *)displayNameForBot:(RCDOpenClawBot *)bot;
- (NSString *)portraitUriForBot:(RCDOpenClawBot *)bot;
- (void)cacheBot:(RCDOpenClawBot *)bot;
- (void)updateSearchKeyword:(nullable NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
