//
//  RCDOpenClawBot.h
//  SealTalk
//
//  Created by RC on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawBotCreator : NSObject

@property (nonatomic, copy) NSString *creatorId;
@property (nonatomic, copy) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface RCDOpenClawBot : NSObject

@property (nonatomic, copy) NSString *botId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *portraitUri;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *connectToken;
@property (nonatomic, strong, nullable) RCDOpenClawBotCreator *creator;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
