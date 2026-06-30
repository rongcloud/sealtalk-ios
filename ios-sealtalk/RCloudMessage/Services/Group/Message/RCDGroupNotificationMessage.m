//
//  RCDGroupNotificationMessage.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupNotificationMessage.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupManager.h"
#import <RongIMKit/RongIMKit.h>
NSString *const RCDGroupCreate = @"Create";
NSString *const RCDGroupMemberAdd = @"Add";
NSString *const RCDGroupMemberQuit = @"Quit";
NSString *const RCDGroupDismiss = @"Dismiss";
NSString *const RCDGroupMemberKicked = @"Kicked";
NSString *const RCDGroupRename = @"Rename";
NSString *const RCDGroupBulletin = @"Bulletin";
NSString *const RCDGroupOwnerTransfer = @"Transfer";
NSString *const RCDGroupMemberJoin = @"Join";
NSString *const RCDGroupMemberManagerSet = @"SetManager";
NSString *const RCDGroupMemberManagerRemove = @"RemoveManager";
NSString *const RCDGroupMemberManagerRemoveDisplay = @"RemoveManagerDisplay";

NSString *const RCDGroupMemberProtectionOpen = @"openMemberProtection";
NSString *const RCDGroupMemberProtectionClose = @"closeMemberProtection";
@interface RCDGroupNotificationMessage ()
@property (nonatomic, copy) NSString *targetGroupName;
@property (nonatomic, strong) NSArray *targetUserNames;
@property (nonatomic, copy) NSString *operationName;
@end
@implementation RCDGroupNotificationMessage
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED;
}

- (NSData *)encode {
    NSMutableDictionary *dict = [self encodeBaseData];
    if (self.operation) {
        [dict setObject:self.operation forKey:@"operation"];
    }
    if (self.operatorUserId) {
        [dict setObject:self.operatorUserId forKey:@"operatorUserId"];
    }
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.operationName) {
        [dataDict setObject:self.operationName forKey:@"operatorNickname"];
    }
    if (self.targetUserIds) {
        [dataDict setObject:self.targetUserIds forKey:@"targetUserIds"];
    }
    if (self.targetGroupName) {
        [dataDict setObject:self.targetGroupName forKey:@"targetGroupName"];
    }
    if (self.targetUserNames) {
        [dataDict setObject:self.targetUserNames forKey:@"targetUserDisplayNames"];
    }
    if (dataDict.count > 0) {
        [dict setObject:dataDict forKey:@"data"];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return jsonData;
}

- (void)decodeWithData:(NSData *)data {
    __autoreleasing NSError *__error = nil;
    if (!data) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&__error];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (!__error && dict) {
        self.operation = [dict objectForKey:@"operation"];
        self.operatorUserId = [dict objectForKey:@"operatorUserId"];
        NSDictionary *dataDic = dict[@"data"];
        if ([dataDic isKindOfClass:NSDictionary.class]) {
            self.operationName = dataDic[@"operatorNickname"];
            self.targetUserIds = dataDic[@"targetUserIds"];
            self.targetGroupName = dataDic[@"targetGroupName"];
            self.targetUserNames = dict[@"data"][@"targetUserDisplayNames"];
        }
        self.extra = dict[@"extra"];
    } else {
        self.rawJSONData = data;
    }
}

- (NSString *)conversationDigest {
    return [self getDigest:nil];
}

+ (NSString *)getObjectName {
    return RCDGroupNotificationMessageIdentifier;
}

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
- (NSString *)getDisplayNames:(NSArray<NSString *> *)userIds groupId:(NSString *)groupId {
    NSString *displayNames = @"";
    for (NSString *userId in userIds) {
        NSString *name;
        if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            name = RCLocalizedString(@"You");
        } else {
            RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
            if (friend && friend.displayName.length > 0) {
                name = friend.displayName;
            } else {
                RCDUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
                if (groupId.length > 0) {
                    RCDGroupMember *member = [RCDGroupManager getGroupMember:userId groupId:groupId];
                    if (member && member.groupNickname.length > 0) {
                        name = member.groupNickname;
                    } else {
                        name = user.name;
                    }
                } else {
                    name = user.name;
                }
            }
            if (name.length == 0 && [userId isEqualToString:self.operatorUserId]) {
                name = self.operationName;
            }
            if (name.length == 0 && [self.targetUserIds isEqualToArray:userIds]) {
                NSInteger index = [userIds indexOfObject:userId];
                if(self.targetUserNames.count > index){
                    name = self.targetUserNames[index];
                }
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
