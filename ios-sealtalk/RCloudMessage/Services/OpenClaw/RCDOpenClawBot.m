//
//  RCDOpenClawBot.m
//  SealTalk
//
//  Created by RC on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBot.h"

@implementation RCDOpenClawBotCreator

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _creatorId = [self stringValue:dictionary[@"id"]];
        _name = [self stringValue:dictionary[@"name"]];
    }
    return self;
}

- (NSString *)stringValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return @"";
}

@end

@implementation RCDOpenClawBot

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _botId = [self stringValue:dictionary[@"botId"]];
        _name = [self stringValue:dictionary[@"name"]];
        _portraitUri = [self stringValue:dictionary[@"portraitUri"]];
        _token = [self stringValue:dictionary[@"token"]];
        _connectToken = [self stringValue:dictionary[@"connectToken"]];
        NSDictionary *creatorDictionary = dictionary[@"creator"];
        if ([creatorDictionary isKindOfClass:[NSDictionary class]]) {
            _creator = [[RCDOpenClawBotCreator alloc] initWithDictionary:creatorDictionary];
        }
    }
    return self;
}

- (NSString *)stringValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return @"";
}

@end
