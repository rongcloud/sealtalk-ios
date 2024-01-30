//
//  RCCombineMessageUtility.h
//  RongIMKit
//
//  Created by liyan on 2019/8/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>

@class RCMessageModel;
@class RCCombineV2Message;

NS_ASSUME_NONNULL_BEGIN

@interface RCDCombineV2Utility : NSObject

+ (NSString *)getCombineMessageTitle:(RCCombineV2Message *)message;

+ (NSString *)getCombineMessageSummaryContent:(RCCombineV2Message *)message;

+ (void)forwardCombineV2MessageForConversations:(NSArray<RCConversation *> *) conversationList withMessages:(NSArray <RCMessageModel *> *)messageModels;
@end

NS_ASSUME_NONNULL_END
