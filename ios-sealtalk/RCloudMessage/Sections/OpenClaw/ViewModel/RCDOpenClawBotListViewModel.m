//
//  RCDOpenClawBotListViewModel.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotListViewModel.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotAPI.h"
#import "RCDOpenClawBotManager.h"

@interface RCDOpenClawBotListViewModel ()

@property (nonatomic, copy) NSArray<RCDOpenClawBot *> *allBots;
@property (nonatomic, copy) NSArray<RCDOpenClawBot *> *bots;
@property (nonatomic, copy) NSString *searchKeyword;

@end

@implementation RCDOpenClawBotListViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _allBots = @[];
        _bots = @[];
    }
    return self;
}

- (void)loadBotsWithSuccess:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error {
    [RCDOpenClawBotAPI getMyBotsWithSuccess:^(NSArray<RCDOpenClawBot *> *bots) {
        self.allBots = bots ?: @[];
        [self updateFilteredBots];
        [RCDOpenClawBotManager cacheBots:self.allBots];
        if (success) {
            success();
        }
    } error:error];
}

- (NSInteger)numberOfBots {
    return self.bots.count;
}

- (RCDOpenClawBot *)botAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.bots.count) {
        return nil;
    }
    return self.bots[index];
}

- (NSArray<RCDOpenClawBot *> *)allLoadedBots {
    return self.allBots ?: @[];
}

- (NSString *)displayNameForBot:(RCDOpenClawBot *)bot {
    return bot.name.length > 0 ? bot.name : [RCDOpenClawBotManager defaultBotName];
}

- (NSString *)portraitUriForBot:(RCDOpenClawBot *)bot {
    return bot.portraitUri.length > 0 ? bot.portraitUri : [RCDOpenClawBotManager defaultPortraitUri];
}

- (void)cacheBot:(RCDOpenClawBot *)bot {
    [RCDOpenClawBotManager cacheBot:bot];
}

- (void)updateSearchKeyword:(NSString *)keyword {
    self.searchKeyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"";
    [self updateFilteredBots];
}

- (void)updateFilteredBots {
    if (self.searchKeyword.length == 0) {
        self.bots = self.allBots;
        return;
    }
    
    NSMutableArray<RCDOpenClawBot *> *filteredBots = [NSMutableArray array];
    for (RCDOpenClawBot *bot in self.allBots) {
        NSString *name = [self displayNameForBot:bot];
        NSRange range = [name rangeOfString:self.searchKeyword
                                    options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
        if (range.location != NSNotFound) {
            [filteredBots addObject:bot];
        }
    }
    self.bots = filteredBots;
}

@end
