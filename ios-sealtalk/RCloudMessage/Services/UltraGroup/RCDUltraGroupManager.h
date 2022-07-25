//
//  RCDUltraGroupManager.h
//  SealTalk
//
//  Created by 张改红 on 2022/1/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDUltraGroup.h"
#import "RCDChannel.h"
#import "RCDEnum.h"

@interface RCDUltraGroupManager : NSObject
+ (void)createUltraGroup:(NSString *)groupName
             portraitUri:(NSString *)portraitUri
                 summary:(NSString *)summary
                complete:(void (^)(NSString *groupId, RCDUltraGroupCode code))complete;

//退出群组
+ (void)quitUltraGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete;

//解散群组
+ (void)dismissUltraGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete;

//添加成员
+ (void)addUsers:(NSArray *)userIds
         groupId:(NSString *)groupId
        complete:(void (^)(BOOL success))complete;

//从 server 获取超级群列表
+ (void)getUltraGroupList:(void (^)(NSArray<RCDUltraGroup *> *groupList))complete;

+ (void)getUltraGroupMemberList:(NSString *)groupId
                          count:(int)count
                       complete:(void (^)(NSArray<NSString *> *memberIdList))complete;

+ (void)createUltraGroupChannel:(NSString *)groupId
                    channelName:(NSString *)channelName
                      isPrivate:(BOOL)isPrivate
                       complete:(void (^)(NSString *channelId, RCDUltraGroupCode code))complete;

+ (void)getUltraGroupChannelList:(NSString *)groupId complete:(void (^)(NSArray<RCDChannel *> *))complete;

+ (void)getChannelName:(NSString *)groupId
             channelId:(NSString *)channelId
              complete:(void (^)(NSString *channelName))complete;

#pragma mark - 私有频道
+ (void)getUltraGroupMembersInWhiteList:(NSString *)groupID
                              channelID:(NSString *)channelID
                                  limit:(int)limit
                               complete:(void (^)(NSArray<NSString *> *memberIdList))complete;

+ (void)editUltraGroupMemberForWhiteList:(NSString *)groupID
                               channelID:(NSString *)channelID
                                isRemove:(BOOL)isRemove
                               memberIds:(NSArray<NSString *> *)memberIds
                                complete:(void (^)(NSArray<NSString *> *memberIdList, BOOL result))complete;

+ (void)editUltraGroupChannelType:(NSString *)groupID
                        channelID:(NSString *)channelID
                        isPrivate:(BOOL)isPrivate
                         complete:(void (^)(NSString *channelID, BOOL result))complete;

+ (void)disbandUltraGroupChannel:(NSString *)groupID
                       channelID:(NSString *)channelID
                        complete:(void (^)(NSString *channelID, BOOL result))complete;
@end
