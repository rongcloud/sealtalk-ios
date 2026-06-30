//
//  RCNDSearchMoreMessagesViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMoreViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchMoreMessagesViewModel : RCNDSearchMoreViewModel
- (instancetype)initWithTitle:(NSString *)title
                      keyword:(NSString *)keyword
                 conversation:(RCConversation *)conversation;
@end

NS_ASSUME_NONNULL_END
