//
//  RCAIConversationViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/7.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCAIConversationViewController : RCConversationViewController<RCAgentMessageDataSource>
@property (nonatomic, strong) RCAgentFacadeModel *agent;
@end

NS_ASSUME_NONNULL_END
