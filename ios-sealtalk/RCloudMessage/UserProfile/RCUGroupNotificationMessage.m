//
//  RCUGroupNotificationMessage.m
//  SealTalk
//
//  Created by zgh on 2024/9/14.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import "RCUGroupNotificationMessage.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDGroupNotificationMessage ()
@property (nonatomic, copy) NSString *targetGroupName;
@property (nonatomic, strong) NSArray *targetUserNames;
@property (nonatomic, copy) NSString *operationName;
@end

@implementation RCUGroupNotificationMessage

- (NSString *)getDigest:(NSString *)groupId {
    NSString *content;
    NSString *operationName = [self getDisplayNames:@[ self.operatorUserId?self.operatorUserId:@""] groupId:groupId];
    NSString *targetNames = [self getDisplayNames:self.targetUserIds groupId:groupId];
    BOOL isMeOperate = NO;
    if ([self.operatorUserId isEqualToString:[RCCoreClient sharedCoreClient].currentUserInfo.userId]) {
        isMeOperate = YES;
    }
    if ([self.operation isEqualToString:RCDGroupCreate]) {
        content =
            [NSString stringWithFormat:RCLocalizedString(isMeOperate ? @"GroupHaveCreated" : @"GroupCreated"),
                                       operationName];
    } else if ([self.operation isEqualToString:RCDGroupMemberAdd]) {
        if (self.targetUserIds.count == 1 && [self.targetUserIds containsObject:self.operatorUserId]) {
            content = [NSString
                stringWithFormat:RCLocalizedString(@"GroupJoin"), operationName];
        } else {
            content = [NSString
                stringWithFormat:RCLocalizedString(isMeOperate ? @"GroupHaveInvited" : @"GroupInvited"),
                                 operationName, targetNames];
        }
    } else if ([self.operation isEqualToString:RCDGroupMemberJoin]) {
        content =
            [NSString stringWithFormat:RCLocalizedString(@"GroupJoin"), operationName];
    } else if ([self.operation isEqualToString:RCDGroupMemberQuit]) {
        content = [NSString stringWithFormat:RCLocalizedString(isMeOperate ? @"GroupHaveQuit" : @"GroupQuit"),
                                             operationName];
    } else if ([self.operation isEqualToString:RCDGroupMemberKicked]) {
        content =
            [NSString stringWithFormat:RCLocalizedString(isMeOperate ? @"GroupHaveRemoved" : @"GroupRemoved"),
                                       operationName, targetNames];
    } else if ([self.operation isEqualToString:RCDGroupRename]) {
        content = [NSString stringWithFormat:RCLocalizedString(@"GroupChanged"),
                                             operationName, self.targetGroupName];
    } else if ([self.operation isEqualToString:RCDGroupDismiss]) {
        content =
            [NSString stringWithFormat:RCLocalizedString(isMeOperate ? @"GroupHaveDismiss" : @"GroupDismiss"),
                                       operationName];
    } else if ([self.operation isEqualToString:RCDGroupOwnerTransfer]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"GroupHasNewOwner"), targetNames];
    } else if ([self.operation isEqualToString:RCDGroupMemberManagerSet]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"GroupSetManagerMessage"), targetNames];
    } else if ([self.operation isEqualToString:RCDGroupMemberManagerRemoveDisplay]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"GroupRemoveManagerMessage"), targetNames];
    } else if ([self.operation isEqualToString:RCDGroupMemberProtectionOpen]) {
        content = RCDLocalizedString(@"openMemberProtection");
    } else if ([self.operation isEqualToString:RCDGroupMemberProtectionClose]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"closeMemberProtection"), operationName];
    } else {
        content = RCLocalizedString(@"unknown_message_cell_tip");
    }
    return content;
}

#pragma mark - helper
- (NSString *)getDisplayNames:(NSArray *)userIds groupId:(NSString *)groupId {
    NSString *displayNames = @"";
    for (NSString *userId in userIds) {
        NSString *name;
        if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            name = RCLocalizedString(@"You");
        } else {
            RCUserInfo *user = [[RCIM sharedRCIM] getUserInfoCache:userId];
            RCUserInfo *member = [[RCIM sharedRCIM] getGroupUserInfoCache:userId withGroupId:groupId];
            if (user.alias.length > 0) {
                name = user.alias;
            } else if (member.name.length > 0) {
                name = member.name;
            } else if (user.name.length > 0){
                name = user.name;
            }
        }
        if (name.length == 0) {
            name = [NSString stringWithFormat:@"name%@", userId];
        }
        displayNames = [displayNames stringByAppendingString:name];
        if ([userIds indexOfObject:userId] >= 20 && userIds.count > 20) {
            displayNames =
                [displayNames stringByAppendingString:RCLocalizedString(@"GroupEtc")];
            break;
        } else if (![userId isEqualToString:userIds[userIds.count - 1]]) {
            displayNames =
                [displayNames stringByAppendingString:RCLocalizedString(@"punctuation")];
        }
    }
    return displayNames;
}
@end
