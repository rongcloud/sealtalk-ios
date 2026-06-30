//
//  RCDOpenClawGroupBotListViewController.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

@class RCDOpenClawBot;

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawGroupBotListViewController : RCDViewController

- (instancetype)initWithGroupId:(NSString *)groupId;
@property (nonatomic, assign) BOOL canManage;
@property (nonatomic, copy, nullable) void (^botAddedBlock)(RCDOpenClawBot *bot);

@end

NS_ASSUME_NONNULL_END
