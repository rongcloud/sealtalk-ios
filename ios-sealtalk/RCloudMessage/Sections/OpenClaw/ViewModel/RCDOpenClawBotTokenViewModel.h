//
//  RCDOpenClawBotTokenViewModel.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDOpenClawViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawBotTokenViewModel : NSObject

@property (nonatomic, strong, readonly) RCDOpenClawBot *bot;
@property (nonatomic, assign, readonly) BOOL created;

- (instancetype)initWithBot:(RCDOpenClawBot *)bot created:(BOOL)created;
- (NSString *)pageTitle;
- (NSString *)displayName;
- (NSString *)portraitUri;
- (NSString *)tokenText;
- (NSString *)refreshButtonTitle;
- (BOOL)hasToken;
- (void)cacheCurrentBot;
- (BOOL)needsLoadDetail;
- (void)loadBotDetailWithSuccess:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error;
- (void)refreshTokenWithSuccess:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error;

@end

NS_ASSUME_NONNULL_END
