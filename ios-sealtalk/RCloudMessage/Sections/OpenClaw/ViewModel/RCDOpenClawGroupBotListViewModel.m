//
//  RCDOpenClawGroupBotListViewModel.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawGroupBotListViewModel.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotAPI.h"
#import "RCDOpenClawBotManager.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDGroupNotificationMessage ()
@property (nonatomic, strong) NSArray *targetUserNames;
@property (nonatomic, copy) NSString *operationName;
@end

@interface RCDOpenClawBotListViewModel ()
@property (nonatomic, copy) NSArray<RCDOpenClawBot *> *bots;
@end

@interface RCDOpenClawGroupBotListViewModel ()

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) BOOL canManage;

@end

@implementation RCDOpenClawGroupBotListViewModel

- (instancetype)initWithGroupId:(NSString *)groupId canManage:(BOOL)canManage {
    self = [super init];
    if (self) {
        _groupId = [groupId copy];
        _canManage = canManage;
    }
    return self;
}

- (NSArray<NSString *> *)existingBotIds {
    NSMutableArray *botIds = [NSMutableArray array];
    for (RCDOpenClawBot *bot in self.bots) {
        if (bot.botId.length > 0) {
            [botIds addObject:bot.botId];
        }
    }
    return botIds.copy;
}

- (void)loadGroupBotsWithSuccess:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error {
    [RCDOpenClawBotAPI getGroupBotsWithGroupId:self.groupId success:^(NSArray<RCDOpenClawBot *> *bots) {
        self.bots = bots ?: @[];
        [RCDOpenClawBotManager cacheBots:self.bots];
        if (success) {
            success();
        }
    } error:error];
}

- (void)removeBotAtIndex:(NSInteger)index success:(void (^)(void))success error:(RCDOpenClawViewModelErrorBlock)error {
    if (!self.canManage) {
        [self dispatchPermissionError:error];
        return;
    }
    RCDOpenClawBot *bot = [self botAtIndex:index];
    if (bot.botId.length == 0) {
        if (success) {
            success();
        }
        return;
    }
    [RCDOpenClawBotAPI removeBots:@[ bot.botId ] fromGroupId:self.groupId success:^(BOOL requestSuccess) {
        if (success) {
            success();
        }
    } error:error];
}

- (void)sendBotInviteNotification:(RCDOpenClawBot *)bot {
    if (bot.botId.length == 0) {
        return;
    }
    Class messageClass = RCDGroupNotificationMessage.class;
    if ([RCIM sharedRCIM].currentDataSourceType == RCDataSourceTypeInfoManagement) {
        Class rcuMessageClass = NSClassFromString(@"RCUGroupNotificationMessage");
        if (rcuMessageClass) {
            messageClass = rcuMessageClass;
        }
    }
    RCDGroupNotificationMessage *message = [messageClass new];
    message.operatorUserId = [RCIM sharedRCIM].currentUserInfo.userId;
    message.operationName = [RCIM sharedRCIM].currentUserInfo.name;
    message.targetUserIds = @[ bot.botId ];
    message.targetUserNames = @[ [self displayNameForBot:bot] ];
    message.operation = RCDGroupMemberAdd;
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP
                          targetId:self.groupId
                           content:message
                       pushContent:nil
                          pushData:nil
                           success:nil
                             error:nil];
}

- (void)dispatchPermissionError:(RCDOpenClawViewModelErrorBlock)error {
    if (!error) {
        return;
    }
    NSError *permissionError = [NSError errorWithDomain:@"cn.rongcloud.sealtalk.openclaw.bot"
                                                   code:-1
                                               userInfo:@{NSLocalizedDescriptionKey : RCDLocalizedString(@"OpenClawOnlyOwnerAdminCanManage")}];
    dispatch_async(dispatch_get_main_queue(), ^{
        error(permissionError);
    });
}

@end
