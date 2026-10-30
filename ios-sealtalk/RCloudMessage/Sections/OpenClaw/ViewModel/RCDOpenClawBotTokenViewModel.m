//
//  RCDOpenClawBotTokenViewModel.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotTokenViewModel.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotAPI.h"
#import "RCDOpenClawBotManager.h"

@interface RCDOpenClawBotTokenViewModel ()

@property (nonatomic, strong) RCDOpenClawBot *bot;
@property (nonatomic, assign) BOOL created;

@end

@implementation RCDOpenClawBotTokenViewModel

- (instancetype)initWithBot:(RCDOpenClawBot *)bot created:(BOOL)created {
    self = [super init];
    if (self) {
        _bot = bot;
        _created = created;
    }
    return self;
}

- (NSString *)pageTitle {
    return self.created ? RCDLocalizedString(@"OpenClawCreateSuccessTitle") : RCDLocalizedString(@"OpenClawDetailsTitle");
}

- (NSString *)displayName {
    return self.bot.name.length > 0 ? self.bot.name : [RCDOpenClawBotManager defaultBotName];
}

- (NSString *)portraitUri {
    return self.bot.portraitUri.length > 0 ? self.bot.portraitUri : [RCDOpenClawBotManager defaultPortraitUri];
}

- (NSString *)tokenText {
    return self.bot.token ?: @"";
}

- (NSString *)refreshButtonTitle {
    return RCDLocalizedString(@"OpenClawRefreshTokenButton");
}

- (BOOL)hasToken {
    return self.bot.token.length > 0;
}

- (void)cacheCurrentBot {
    [RCDOpenClawBotManager cacheBot:self.bot];
}

- (BOOL)needsLoadDetail {
    return !self.created && self.bot.botId.length > 0;
}

- (void)loadBotDetailWithSuccess:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error {
    [RCDOpenClawBotAPI getBotWithBotId:self.bot.botId success:^(RCDOpenClawBot *bot) {
        if (self.bot.token.length > 0 && bot.token.length == 0) {
            bot.token = self.bot.token;
        }
        self.bot = bot;
        [RCDOpenClawBotManager cacheBot:bot];
        if (success) {
            success();
        }
    } error:error];
}

- (void)refreshTokenWithSuccess:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error {
    [RCDOpenClawBotAPI refreshTokenWithBotId:self.bot.botId success:^(RCDOpenClawBot *bot) {
        self.bot = bot;
        [RCDOpenClawBotManager cacheBot:bot];
        if (success) {
            success();
        }
    } error:error];
}

@end
