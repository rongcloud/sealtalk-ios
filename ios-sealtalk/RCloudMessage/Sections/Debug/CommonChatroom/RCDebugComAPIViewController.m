//
//  RCDebugComAPIViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDebugComAPIViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDebugGlobalUndistributeViewController.h"
#import "RCDebugPushLevelViewController.h"


NSString *const RCDBaseSettingTableViewCellIdentifier = @"RCDBaseSettingTableViewCellIdentifier";



@interface RCDebugComAPIViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSDictionary *dataInfo;
@end

@implementation RCDebugComAPIViewController

- (NSDictionary *)dataInfo {
    if (!_dataInfo) {
        NSDictionary *dic = @{
            @(RCDComChatroomOptionCategory2_1) : @"2.1 设置->指定时间段内的免打扰",
            @(RCDComChatroomOptionCategory2_2) : @"2.2 移除->指定时间段内的免打扰",
            @(RCDComChatroomOptionCategory2_3) : @"2.3 查询->指定时间段内的免打扰",
            @(RCDComChatroomOptionCategory3_1) : @"3.1 设置->指定频道免打扰设置",
            @(RCDComChatroomOptionCategory3_2) : @"3.2 移除->指定频道免打扰设置",
            @(RCDComChatroomOptionCategory3_3) : @"3.3 查询->指定频道免打扰设置",
            @(RCDComChatroomOptionCategory4_1) : @"4.1 设置->指定会话免打扰设置",
            @(RCDComChatroomOptionCategory4_2) : @"4.2 移除->指定会话免打扰设置",
            @(RCDComChatroomOptionCategory4_3) : @"4.3 查询->指定会话免打扰设置",
            @(RCDComChatroomOptionCategory5_1) : @"5.1 设置->指定会话类型免打扰设置",
            @(RCDComChatroomOptionCategory5_2) : @"5.2 移除->指定会话类型免打扰设置",
            @(RCDComChatroomOptionCategory5_3) : @"5.3 查询->指定会话类型免打扰设置"
        };
        _dataInfo = dic;
    }
    return _dataInfo;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSArray *array = [self.dataInfo allKeys];
        _dataSource = [array sortedArrayUsingSelector:@selector(compare:)];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[RCDBaseSettingTableViewCell class]
           forCellReuseIdentifier:RCDBaseSettingTableViewCellIdentifier];
}


- (NSString *)getNotificationQuietHoursLevelString:(RCPushNotificationQuietHoursLevel)level {
    NSString* levelstr = @"";
    switch (level) {
        case RCPushNotificationQuietHoursLevelMention:
            levelstr = @"1: 群聊超级群仅@消息通知，单聊代表消息不通知";
            break;
        case RCPushNotificationQuietHoursLevelDefault:
            levelstr = @"0: 未设置（向上查询群或者APP级别设置）";
            break;
        case RCPushNotificationQuietHoursLevelBlocked:
            levelstr = @"5: 消息通知被屏蔽，即不接收消息通知";
            break;
        default:
            break;
    }
    
    return levelstr;
}

- (NSString *)getPushNotificationLevelString:(RCPushNotificationLevel)level {
    NSString* levelstr = @"";
    switch (level) {
        case RCPushNotificationLevelAllMessage:
            levelstr = @"-1: 全部消息通知";
            break;
        case RCPushNotificationLevelDefault:
            levelstr = @"0: 未设置（向上查询群或者APP级别设置）";
            break;
        case RCPushNotificationLevelMention:
            levelstr = @"1: 群聊超级群仅@消息通知（现在通知）单聊代表全部消息通知";
            break;
        case RCPushNotificationLevelMentionUsers:
            levelstr = @"2: 指定用户通知";
            break;
        case RCPushNotificationLevelMentionAll:
            levelstr = @"4: 群全员通知";
            break;
        case RCPushNotificationLevelBlocked:
            levelstr = @"5: 消息通知被屏蔽，即不接收消息通知";
            break;
        default:
            break;
    }
    
    return levelstr;
}


- (void)showAlertMessage:(NSString *)title msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCAlertView showAlertController:title message:msg cancelTitle:RCDLocalizedString(@"confirm")];
    });
}

- (void)quereySettingInfoBy:(RCDComChatroomOptionCategory)category {
    switch (category) {
        case RCDComChatroomOptionCategory2_3: {
            [[RCChannelClient sharedChannelManager] getNotificationQuietHoursLevel:^(NSString *startTime, int spanMins, RCPushNotificationQuietHoursLevel level) {
                [self showAlertMessage:nil
                                   msg:[NSString stringWithFormat:@"开始时间：%@，间隔时间：%d分钟，级别:%@", startTime, spanMins, [self getNotificationQuietHoursLevelString:level]]];
            } error:^(RCErrorCode status) {
                [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                   msg:nil];
            }];
        }
            break;
        case RCDComChatroomOptionCategory3_3: {
            [[RCChannelClient sharedChannelManager] getConversationChannelNotificationLevel:self.type
                                                                                   targetId:self.targetId
                                                                                  channelId:self.channelId
                                                                                    success:^(RCPushNotificationLevel level) {
                [self showAlertMessage:nil
                                   msg:[NSString stringWithFormat:@"频道免打扰级别:%@", [self getPushNotificationLevelString:level]]];
            } error:^(RCErrorCode status) {
                [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                   msg:nil];
            }];
        }
            break;
        case RCDComChatroomOptionCategory4_3: {
            [[RCChannelClient sharedChannelManager] getConversationNotificationLevel:self.type
                                                                            targetId:self.targetId
                                                                             success:^(RCPushNotificationLevel level) {
                [self showAlertMessage:nil
                                   msg:[NSString stringWithFormat:@"会话免打扰级别:%@", [self getPushNotificationLevelString:level]]];
            } error:^(RCErrorCode status) {
                [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                   msg:nil];
            }];
        }
            break;
        case RCDComChatroomOptionCategory5_3: {
         
          [[RCChannelClient sharedChannelManager] getConversationTypeNotificationLevel:self.type
                                                                                 success:^(RCPushNotificationLevel level) {
                [self showAlertMessage:nil
                                   msg:[NSString stringWithFormat:@"会话类型免打扰级别:%@", [self getPushNotificationLevelString:level]]];
            } error:^(RCErrorCode status) {
                [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                   msg:nil];
                
            }];
          
        }
            break;
        default:
            break;
    }
}

- (void)removeSettingInfoBy:(RCDComChatroomOptionCategory)category {
    switch (category) {
        case RCDComChatroomOptionCategory2_2: {
            [[RCCoreClient sharedCoreClient] removeNotificationQuietHours:^() {
                [self showAlertMessage:@"删除设置成功" msg:nil];
            } error:^(RCErrorCode status) {
                [self showAlertMessage:@"删除设置失败" msg:[NSString stringWithFormat:@"错误码为%zd", status]];
            }];
        }
            break;
        case RCDComChatroomOptionCategory3_2: {
            [[RCChannelClient sharedChannelManager] setConversationChannelNotificationLevel:self.type
                                                                                   targetId:self.targetId
                                                                                  channelId:self.channelId
                                                                                      level:RCPushNotificationLevelDefault
                                                                                    success:^() {
                [self showAlertMessage:@"删除设置成功" msg:nil];
            } error:^(RCErrorCode status) {
                [self showAlertMessage:@"删除设置失败" msg:[NSString stringWithFormat:@"错误码为%zd", status]];
            }];
        }
            break;
        case RCDComChatroomOptionCategory4_2: {
            [[RCChannelClient sharedChannelManager] setConversationNotificationLevel:self.type
                                                                            targetId:self.targetId
                                                                               level:RCPushNotificationLevelDefault
                                                                             success:^() {
                [self showAlertMessage:@"删除设置成功" msg:nil];
            } error:^(RCErrorCode status) {
                [self showAlertMessage:@"删除设置失败" msg:[NSString stringWithFormat:@"错误码为%zd", status]];
            }];
        }
            break;
        case RCDComChatroomOptionCategory5_2: {
            
            [[RCChannelClient sharedChannelManager] setConversationTypeNotificationLevel:self.type
                                                                                   level:RCPushNotificationLevelDefault
                                                                                 success:^() {
                [self showAlertMessage:@"删除设置成功" msg:nil];
            } error:^(RCErrorCode status) {
                [self showAlertMessage:@"删除设置失败"
                                   msg:[NSString stringWithFormat:@"错误码为%zd", status]];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)userDidSelectedCategory:(RCDComChatroomOptionCategory)category {
    switch (category) {
            // 移除
        case RCDComChatroomOptionCategory2_2:
        case RCDComChatroomOptionCategory3_2:
        case RCDComChatroomOptionCategory4_2:
        case RCDComChatroomOptionCategory5_2:
            [self removeSettingInfoBy:category];
            break;
            // 查询
        case RCDComChatroomOptionCategory2_3:
        case RCDComChatroomOptionCategory3_3:
        case RCDComChatroomOptionCategory4_3:
        case RCDComChatroomOptionCategory5_3:
            [self quereySettingInfoBy:category];
            break;
            // 设置
        case RCDComChatroomOptionCategory2_1:
        case RCDComChatroomOptionCategory3_1:
        case RCDComChatroomOptionCategory4_1:
        case RCDComChatroomOptionCategory5_1: {
            [self showSettingDetailBy:category];
        }
            break;
        default:
            break;
    }
}

- (void)showSettingDetailBy:(RCDComChatroomOptionCategory)category {
    NSString *title = self.dataInfo[@(category)];
    RCDebugComBaseViewController *vc = nil;
    if (category == RCDComChatroomOptionCategory2_1) {
        vc = [RCDebugGlobalUndistributeViewController new];
    } else {
        RCDebugPushLevelViewController *v = [RCDebugPushLevelViewController new];
        v.category = category;
        vc = v;
    }
    vc.targetId = self.targetId;
    vc.type = self.type;
    vc.channelId = self.channelId;
    vc.title = title;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDBaseSettingTableViewCellIdentifier];
    NSNumber *num = self.dataSource[indexPath.row];
    NSString *title = self.dataInfo[num];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *num = self.dataSource[indexPath.row];
    [self userDidSelectedCategory:[num integerValue]];
}
@end
