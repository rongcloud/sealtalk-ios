//
//  RCDUltraGroupManager.m
//  SealTalk
//
//  Created by 张改红 on 2022/1/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUltraGroupManager.h"
#import "RCDHTTPUtility.h"
#import "RCDUtilities.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "RCDDBManager.h"

typedef NS_ENUM(NSInteger, RCDUtralGroupChannelType) {
    RCDUtralGroupChannelTypePublic, // 公有频道
    RCDUtralGroupChannelTypePrivate // 私有频道
};

@implementation RCDUltraGroupManager
+ (void)createUltraGroup:(NSString *)groupName
             portraitUri:(NSString *)portraitUri
                 summary:(NSString *)summary
                complete:(void (^)(NSString *groupId, RCDUltraGroupCode code))complete{
    if (!groupName) {
        SealTalkLog(@"groupName is nil");
        if (complete) {
            complete(nil, RCDUltraGroupCodeParameterError);
        }
        return;
    }
    NSDictionary *params = @{ @"groupName" : groupName,
                              @"portraitUri" : portraitUri?:@"",
                              @"summary": summary?:@"" };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/create"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.success) {
                NSString *channelId = result.content[@"defaultChannelId"];
                NSString *channelName = result.content[@"defaultChannelName"];
                NSString *groupId = result.content[@"groupId"];
                RCInformationNotificationMessage *info = [RCInformationNotificationMessage notificationWithMessage:[NSString stringWithFormat:@"%@ 创建了频道",[RCIM sharedRCIM].currentUserInfo.name] extra:nil];
                RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_ULTRAGROUP targetId:groupId direction:MessageDirection_SEND messageId:-1 content:info];
                message.channelId = channelId;
                [[RCIM sharedRCIM] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
                    
                } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
                    
                }];
                if (complete) {
                    complete(groupId, result.errorCode);
                }
            } else {
                if (complete) {
                    complete(nil, result.errorCode);
                }
            }
        });
    }];
}

//退出群组
+ (void)quitUltraGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/quit"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result.success);
            }
        });
        
    }];
}

//解散群组
+ (void)dismissUltraGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/dismiss"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result.success);
            }
        });
    }];
}

//添加成员
+ (void)addUsers:(NSArray *)userIds
         groupId:(NSString *)groupId
        complete:(void (^)(BOOL success))complete{
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"memberIds" : userIds };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/add"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
            if (result.success) {
                NSArray *joinedUsers = result.content;
                if(joinedUsers.count > 0){
                    NSString *names = @"";
                    for (NSString *str in joinedUsers) {
                        if (names.length > 0) {
                            names = [names stringByAppendingString:@", "];
                        }
                        NSString *name = [RCDUserInfoManager getUserInfo:str].name;
                        if (name.length == 0) {
                            name = str;
                        }
                        names = [names stringByAppendingString:name];
                    }
                    RCInformationNotificationMessage *info = [RCInformationNotificationMessage notificationWithMessage:[NSString stringWithFormat:@"%@ 邀请 %@ 进入本群",[RCIM sharedRCIM].currentUserInfo.name,names] extra:nil];
                    RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_ULTRAGROUP targetId:groupId direction:MessageDirection_SEND messageId:-1 content:info];
                    NSArray *conversationList = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:ConversationType_ULTRAGROUP targetId:groupId];
                    for (RCConversation *conversation in conversationList) {
                        message.channelId = conversation.channelId;
                        [[RCIM sharedRCIM] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
                            
                        } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
                            
                        }];
                        [NSThread sleepForTimeInterval:0.3];
                    }
                }
            }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result.success);
            }
        });
    }];
}

//从 server 获取超级群列表
+ (void)getUltraGroupList:(void (^)(NSArray<RCDUltraGroup *> *groupList))complete{
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/ultragroups"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
        if (result.success) {
            NSMutableArray *groupList = [NSMutableArray new];
            NSArray *list = result.content;
            for (NSDictionary *dic in list) {
                RCDUltraGroup *group = [[RCDUltraGroup alloc] initWithJson:dic];
                if (!group.portraitUri || group.portraitUri.length == 0) {
                    group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                }
                [groupList addObject:group];
            }
            [RCDDBManager saveMyUltraGroups:groupList];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(groupList.copy);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete([RCDDBManager getMyUltraGroups]);
                }
            });
        }
    }];
}

+ (void)getUltraGroupMemberList:(NSString *)groupId
                          count:(int)count
                       complete:(void (^)(NSArray<NSString *> *memberIdList))complete{
    if (!groupId || count == 0) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"pageNum" : @(1), @"limit": @(count)};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/members"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *list = result.content;
                                         NSMutableArray *array = [[NSMutableArray alloc] init];
                                         for (NSDictionary *dic in list) {
                                             NSString *userId  = dic[@"user"][@"id"];
                                             [array addObject:userId];
                                         }
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (complete) {
                                                 complete(array.copy);
                                             }
                                         });
                                     } else {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (complete) {
                                                 complete(nil);
                                             }
                                         });
                                     }
                                 }];
}

+ (void)createUltraGroupChannel:(NSString *)groupId
                    channelName:(NSString *)channelName
                      isPrivate:(BOOL)isPrivate
                       complete:(void (^)(NSString *, RCDUltraGroupCode))complete{
    if (!groupId || !channelName) {
        SealTalkLog(@"groupId or channelName is nil");
        if (complete) {
            complete(nil,RCDUltraGroupCodeParameterError);
        }
        return;
    }
    int type = !isPrivate ? RCDUtralGroupChannelTypePublic : RCDUtralGroupChannelTypePrivate;
    NSDictionary *params = @{ @"groupId" : groupId,
                              @"channelName" : channelName,
                              @"type":@(type)
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/channel/create"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.success) {
                NSString *channelId = result.content[@"channelId"];
                RCInformationNotificationMessage *info = [RCInformationNotificationMessage notificationWithMessage:[NSString stringWithFormat:@"%@ 创建了频道",[RCIM sharedRCIM].currentUserInfo.name] extra:nil];
                RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_ULTRAGROUP targetId:groupId direction:MessageDirection_SEND messageId:-1 content:info];
                message.channelId = channelId;
                [[RCIM sharedRCIM] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
                    
                } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
                    
                }];
                if (complete) {
                    complete(channelId, result.errorCode);
                }
            } else {
                if (complete) {
                    complete(nil, result.errorCode);
                }
            }
        });
    }];
}

+ (void)getUltraGroupChannelList:(NSString *)groupId complete:(void (^)(NSArray<RCDChannel *> *))complete{
    if (!groupId) {
        SealTalkLog(@"groupIdis nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/channel/list"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.success) {
                NSMutableArray *channelList = [NSMutableArray new];
                NSArray *list = result.content;
                for (NSDictionary *dic in list) {
                    RCDChannel *channel = [[RCDChannel alloc] init];
                    channel.channelId = dic[@"channelId"];
                    channel.channelName = dic[@"channelName"];
                    channel.type = [dic[@"type"] integerValue];
                    [channelList addObject:channel];
                }
                [RCDDBManager saveUltraGroupChannels:groupId channels:channelList];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(channelList);
                    }
                });
            } else {
                if (complete) {
                    complete(nil);
                }
            }
        });
    }];
}

+ (void)getChannelName:(NSString *)groupId channelId:(NSString *)channelId complete:(void (^)(NSString *))complete{
    void(^innerCompletion)(NSString *) = ^(NSString *name){
        if (complete) complete(name);
    };
    if (channelId.length == 0) {
        return innerCompletion(@"Channel<>");
    }
    NSString *name = [RCDDBManager getChannelName:groupId channelId:channelId];
    if (name.length) {
        return innerCompletion(name);
    }
    [self getUltraGroupChannelList:groupId complete:^(NSArray<RCDChannel *> *list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (RCDChannel *channel in list) {
                if ([channel.channelId isEqualToString:channelId]) {
                    return innerCompletion(channel.channelName);
                }
            }
            innerCompletion([NSString stringWithFormat:@"Channel<%@>",channelId]);
        });
    }];
}

#pragma mark - 私有频道
+ (void)getUltraGroupMembersInWhiteList:(NSString *)groupID
                              channelID:(NSString *)channelID
                                  limit:(int)limit
                       complete:(void (^)(NSArray<NSString *> *memberIdList))complete{
    if (!groupID || limit == 0 || !channelID) {
        SealTalkLog(@"parameters error");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"channelId":channelID,
                              @"pageNum" : @(1),
                              @"limit": @(limit)};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/channel/private/users/get"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success && [result.content isKindOfClass:[NSDictionary class]]) {
                                         NSDictionary *info = (NSDictionary *)result.content;
                                             NSArray *userIDs  = info[@"users"];
                                         if ([userIDs isKindOfClass:[NSArray class]]) {
                                             if (complete) {
                                                 complete(userIDs);
                                             }
                                         } else {
                                             if (complete) {
                                                 complete(nil);
                                             }
                                         }
                                       
                                     } else {
                                             if (complete) {
                                                 complete(nil);
                                             }
                                     }
                                 }];
}

+ (void)editUltraGroupMemberForWhiteList:(NSString *)groupID
                              channelID:(NSString *)channelID
                                isRemove:(BOOL)isRemove
                                  memberIds:(NSArray<NSString *> *)memberIds
                       complete:(void (^)(NSArray<NSString *> *memberIdList, BOOL result))complete {
    if (!groupID || !memberIds|| !channelID) {
        SealTalkLog(@"parameters error");
        if (complete) {
            complete(memberIds, NO);
        }
        return;
    }
    NSString *url = @"ultragroup/channel/private/users/del";
    if (!isRemove) {
        url = @"ultragroup/channel/private/users/add";
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"channelId":channelID,
                              @"memberIds" : memberIds};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:url
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        if (complete) {
            complete(memberIds, result.success);
        }
        
    }];
}


+ (void)editUltraGroupChannelType:(NSString *)groupID
                            channelID:(NSString *)channelID
isPrivate:(BOOL)isPrivate
                             complete:(void (^)(NSString *channelID, BOOL result))complete {
    if (!groupID || !channelID) {
        SealTalkLog(@"parameters error");
        if (complete) {
            complete(channelID, NO);
        }
        return;
    }
RCDUtralGroupChannelType type = !isPrivate ? RCDUtralGroupChannelTypePublic : RCDUtralGroupChannelTypePrivate;
    NSString *url = @"ultragroup/channel/type/change";
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"channelId":channelID,
                              @"type" : @(type)};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:url
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        if (complete) {
            complete(channelID, result.success);
        }
    }];
}

+ (void)disbandUltraGroupChannel:(NSString *)groupID
                       channelID:(NSString *)channelID
                        complete:(void (^)(NSString *channelID, BOOL result))complete {
    if (!groupID || !channelID) {
        SealTalkLog(@"parameters error");
        if (complete) {
            complete(channelID, NO);
        }
        return;
    }

    NSString *url = @"ultragroup/channel/del";
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"channelId":channelID };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:url
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        if (complete) {
            complete(channelID, result.success);
        }
    }];
}

#pragma mark - 用户组
+ (void)createUserGroup:(NSString *)groupID
          userGroupName:(NSString *)userGroupName
               complete:(void (^)(NSString * userGroupID, RCDUltraGroupCode ret)) complete {
    if (!groupID || !userGroupName) {
        SealTalkLog(@"groupId or userGroupName is nil");
        if (complete) {
            complete(nil,RCDUltraGroupCodeParameterError);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"userGroupName" : userGroupName
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/usergroup/add"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.success) {
                NSString *userGroupID = result.content;
                if (complete) {
                    complete(userGroupID, result.errorCode);
                }
            } else {
                if (complete) {
                    complete(nil, result.errorCode);
                }
            }
        });
    }];
}

+ (void)deleteUserGroup:(NSString *)groupID
            userGroupID:(NSString *)userGroupID
               complete:(void (^)(RCDUltraGroupCode ret)) complete {
    if (!groupID || !userGroupID) {
        SealTalkLog(@"groupId or userGroupID is nil");
        if (complete) {
            complete(RCDUltraGroupCodeParameterError);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"userGroupId" : userGroupID
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/usergroup/del"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result.errorCode);
            }
        });
    }];
}

+ (void)addToUserGroup:(NSString *)groupID
         userGroupID:(NSString *)userGroupID
             members:(NSArray<NSString *> *)members
               complete:(void (^)(RCDUltraGroupCode ret)) complete {
    if (!groupID || !members || !userGroupID) {
        SealTalkLog(@"groupId or userGroupID , members is nil");
        if (complete) {
            complete(RCDUltraGroupCodeParameterError);
        }
        return;
    }
    
    if (members.count == 0) {
        if (complete) {
            complete(RCDUltraGroupCodeSuccess);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"userGroupId" : userGroupID,
                              @"memberIds": members
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/usergroup/member/add"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result.errorCode);
            }
        });
    }];
}

+ (void)removeFromUserGroup:(NSString *)groupID
         userGroupID:(NSString *)userGroupID
             members:(NSArray<NSString *> *)members
               complete:(void (^)(RCDUltraGroupCode ret)) complete {
    if (!groupID || !members) {
        SealTalkLog(@"groupId or userGroupID is nil");
        if (complete) {
            complete(RCDUltraGroupCodeParameterError);
        }
        return;
    }
    if (members.count == 0) {
        if (complete) {
            complete(RCDUltraGroupCodeSuccess);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"userGroupId" : userGroupID,
                              @"memberIds": members
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"ultragroup/usergroup/member/del"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result.errorCode);
            }
        });
    }];
}

+ (void)bindToUserGroup:(NSString *)groupID
              channelID:(NSString *)channelID
             userGroups:(NSArray<NSString *> *)userGroups
               complete:(void (^)(RCDUltraGroupCode ret)) complete {
    if (!groupID || !channelID || !userGroups) {
        SealTalkLog(@"groupId or userGroupID is nil");
        if (complete) {
            complete(RCDUltraGroupCodeParameterError);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"channelId" : channelID,
                              @"userGroupIds": userGroups
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"/ultragroup/channel/usergroup/bind"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result.errorCode);
            }
        });
    }];
}

+ (void)unbindFromUserGroup:(NSString *)groupID
              channelID:(NSString *)channelID
             userGroups:(NSArray<NSString *> *)userGroups
               complete:(void (^)(RCDUltraGroupCode ret)) complete {
    if (!groupID || !channelID || !userGroups) {
        SealTalkLog(@"groupId or userGroupID is nil");
        if (complete) {
            complete(RCDUltraGroupCodeParameterError);
        }
        return;
    }

    NSDictionary *params = @{ @"groupId" : groupID,
                              @"channelId" : channelID,
                              @"userGroupIds": userGroups
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"/ultragroup/channel/usergroup/unbind"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result.errorCode);
            }
        });
    }];
}

+ (void)queryUserGroups:(NSString *)groupID
               complete:(void (^)(NSArray *array ,RCDUltraGroupCode ret))complete {
    if (!groupID) {
        SealTalkLog(@"groupId or userGroupID is nil");
        if (complete) {
            complete(nil, RCDUltraGroupCodeParameterError);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"pageNum" : @(1),
                              @"limit": @(50)
    };
    
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"/ultragroup/usergroup/query"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                NSArray *array = result.content;
                complete(array, result.errorCode);
            }
        });
    }];
}

+ (void)queryChannelUserGroups:(NSString *)groupID
                     channelID:(NSString *)channelID
               complete:(void (^)(NSArray *array ,RCDUltraGroupCode ret)) complete {
    if (!groupID || !channelID) {
        SealTalkLog(@"groupId or channelID is nil");
        if (complete) {
            complete(nil, RCDUltraGroupCodeParameterError);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"channelId" : channelID,
                              @"pageNum" : @(1),
                              @"limit": @(50)
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"/ultragroup/channel/usergroup/query"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                NSArray *array = result.content;

                complete(array, result.errorCode);
            }
        });
    }];
}

+ (void)queryUserGroupMembers:(NSString *)groupID
                  userGroupID:(NSString *)userGroupID
               complete:(void (^)(NSArray *array ,RCDUltraGroupCode ret)) complete {
    if (!groupID || !userGroupID) {
        SealTalkLog(@"groupId or userGroupID is nil");
        if (complete) {
            complete(nil, RCDUltraGroupCodeParameterError);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupID,
                              @"userGroupId" : userGroupID,
                              @"pageNum" : @(1),
                              @"limit": @(50)
    };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"/ultragroup/usergroup/member/query"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                NSArray *array = result.content;

                complete(array, result.errorCode);
            }
        });
    }];
}
@end
