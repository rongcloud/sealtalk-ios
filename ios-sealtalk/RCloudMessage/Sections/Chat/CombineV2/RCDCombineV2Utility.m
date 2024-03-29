//
//  RCCombineMessageUtility.m
//  RongIMKit
//
//  Created by liyan on 2019/8/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDCombineV2Utility.h"
#import <RongIMKit/RongIMKit.h>

#define kRCCombineMessageSummaryLimit 4

@implementation RCDCombineV2Utility

+ (NSString *)getCombineMessageTitle:(RCCombineV2Message *)message {
    if (!message) {
        return @"";
    }
    if (!message) {
        return @"";
    }
    NSString *title = @"";
    if (message.conversationType == ConversationType_GROUP) {
        title = RCLocalizedString(@"GroupChatHistory");
    } else {
        if (message.nameList && message.nameList.count > 1) {
            title = [NSString stringWithFormat:RCLocalizedString(@"ChatHistoryForXAndY"),
                     [message.nameList firstObject], [message.nameList lastObject]];
        } else if (message.nameList && message.nameList.count == 1) {
            title = [NSString stringWithFormat:RCLocalizedString(@"ChatHistoryForX"),
                     [message.nameList firstObject]];
        }
    }
    return title;
}

+ (NSString *)getCombineMessageSummaryContent:(RCCombineV2Message *)message {
    if (!message) {
        return @"";
    }
    
    if (!message.summaryList) {
        return @"";
    }
    NSMutableString *summaryContent = [[NSMutableString alloc] init];
    for (int i = 0; i < message.summaryList.count; i++) {
        NSString *summary = [message.summaryList objectAtIndex:i];
        [summaryContent appendString:summary];
        if (i < message.summaryList.count - 1) {
            [summaryContent appendString:@"\n"];
        }
    }
    return [summaryContent copy];
}

+ (void)forwardCombineV2MessageForConversations:(NSArray<RCConversation *> *)conversationList withMessages:(NSArray <RCMessageModel *> *)messageModels {
    if (messageModels.count == 0) {
        return;
    }
    //组装消息
    NSMutableArray *nameList = [[NSMutableArray alloc] init];
    NSMutableArray *summaryList = [[NSMutableArray alloc] init];
    NSMutableArray *messages = [NSMutableArray array];
    
    for (int i = 0; i < messageModels.count; i++) {
        RCMessageModel *messageModel = [messageModels objectAtIndex:i];
        RCMessage *message = [[RCCoreClient sharedCoreClient] getMessage:messageModel.messageId];
        if (!message) continue;
        [messages addObject:message];
        
        RCUserInfo *userInfo;
        NSString *senderUserName;
        //组装名字
        if (message.conversationType == ConversationType_GROUP) {
            userInfo = [[RCIM sharedRCIM] getGroupUserInfoCache:messageModel.senderUserId withGroupId:messageModel.targetId];
            if (!userInfo) {
                userInfo = [[RCUserInfo alloc] initWithUserId:messageModel.senderUserId name:nil portrait:nil];
            }
            senderUserName = userInfo.name;
            RCGroup *groupInfo =
            [[RCIM sharedRCIM] getGroupInfoCache:messageModel.targetId];
            NSString *groupName = groupInfo.groupName ?: [NSString stringWithFormat:@"group<%@>", messageModel.targetId];
            if (![nameList containsObject:groupName]) {
                [nameList addObject:groupName];
            }
        } else {
            userInfo = [[RCIM sharedRCIM] getUserInfoCache:messageModel.senderUserId];
            if (!userInfo) {
                userInfo = [[RCUserInfo alloc] initWithUserId:messageModel.senderUserId name:nil portrait:nil];
            }
            senderUserName = userInfo.name;
            if (![nameList containsObject:senderUserName]) {
                [nameList addObject:senderUserName];
            }
        }
        //组装缩略信息
        if (i < 4) {
            [summaryList addObject:[self rc_packageSummaryList:message senderUserName:senderUserName]];
        }
    }
    
    RCCombineV2Message *combineV2Content = [RCCombineV2Message messageWithSummaryList:summaryList nameList:nameList conversationType:messageModels.firstObject.conversationType messages:messages];
    for (RCConversation *conversation in conversationList) {
        [self sendCombineV2:combineV2Content forConversation:conversation];
    }
}

+ (void)sendCombineV2:(RCMessageContent *)content forConversation:(RCConversation *)conversation {
    [[RCIM sharedRCIM] sendMediaMessage:conversation.conversationType targetId:conversation.targetId content:content pushContent:nil pushData:nil progress:^(int progress, long messageId) {
            
        } success:^(long messageId) {
            
        } error:^(RCErrorCode errorCode, long messageId) {
            
        } cancel:^(long messageId) {
            
        }];
    [NSThread sleepForTimeInterval:0.4];
}

#pragma mark - Private -

+ (NSArray<RCMessage *> *)rc_sortMessages:(NSArray<RCMessage *> *)messages {
    NSMutableArray *msgList = messages.mutableCopy;
    [msgList sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        if (((RCMessage *)obj1).sentTime < ((RCMessage *)obj2).sentTime) {
            return NSOrderedAscending;
        } else if (((RCMessage *)obj1).sentTime == ((RCMessage *)obj2).sentTime) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    return msgList.copy;
}

+ (NSString *)rc_packageSummaryList:(RCMessage *)message senderUserName:(NSString *)senderUserName {
    NSMutableString *summaryContent = [[NSMutableString alloc] initWithFormat:@"%@：", senderUserName];
    NSString *digest = [RCKitUtility formatMessage:message.content
                                          targetId:message.targetId
                                  conversationType:message.conversationType];
    // 换行替换为空格
    digest = [digest stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    digest = [digest stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    digest = [digest stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    [summaryContent appendString:digest];
    return summaryContent;
}


@end
