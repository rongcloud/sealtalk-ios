//
//  RCDDebugUltraGroupListSelectController.h
//  SealTalk
//
//  Created by Lang on 2023/7/17.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDDebugUltraGroupListSelectController : RCConversationListViewController

@property (nonatomic, copy) NSString *targetId;

@property (nonatomic, copy) void (^selectedChannelIdsResult)(NSArray<NSString *> *channelIds);

@end

NS_ASSUME_NONNULL_END
