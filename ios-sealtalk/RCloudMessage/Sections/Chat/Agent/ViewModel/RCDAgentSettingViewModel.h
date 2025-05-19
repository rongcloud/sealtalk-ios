//
//  RCDAgentSettingViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/14.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDAgentSettingViewModel : NSObject
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) RCConversationIdentifier *identifier;
- (instancetype)initWithIdentifier:(RCConversationIdentifier*)identifier;
@end

NS_ASSUME_NONNULL_END
