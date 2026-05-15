//
//  RCDOpenClawBotSelectViewController.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

@class RCDOpenClawBot;

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawBotSelectViewController : RCDViewController

- (instancetype)initWithGroupId:(NSString *)groupId
                  existingBotIds:(NSArray<NSString *> *)existingBotIds;
@property (nonatomic, copy, nullable) void (^addSuccessBlock)(RCDOpenClawBot *bot);
@property (nonatomic, copy, nullable) void (^addBotsSuccessBlock)(NSArray<RCDOpenClawBot *> *bots);

@end

NS_ASSUME_NONNULL_END
