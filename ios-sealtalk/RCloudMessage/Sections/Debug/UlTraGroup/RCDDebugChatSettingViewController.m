//
//  RCDDebugChatSettingViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2021/11/29.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugChatSettingViewController.h"

#import <Masonry/Masonry.h>
#import <GCDWebServer/GCDWebUploader.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import <RongIMKit/RongIMKit.h>

#import "RCDBaseSettingTableViewCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDDebugUltraGroupDefine.h"
#import "RCDDebugNotificationQuietHoursSettingViewController.h"
#import "RCDDebugConversationChannelNotificationLevelViewController.h"
#import "RCDDebugUltraGroupUnreadMessageViewController.h"

@interface RCDDebugChatSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) GCDWebUploader *webUploader;

@end

@implementation RCDDebugChatSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[RCDLocalizedString(@"mute_notifications"), //0
                    RCDLocalizedString(@"stick_on_top"), // 1
                    @"清空本地历史消息", //2
                    @"清空本地和远端历史消息",// 3
                    @"删除本地「所有频道」当前时间之前的消息", // 4
                    @"删除本地「当前频道」当前时间之前的消息",// 5
                    @"删除「服务端」当前时间之前的消息", // 6
                    @"发一条携带{tKey:当前时间}文本消息", //7
                    @"获取「当前超级群」所有频道的lastMsgUid", // 8
                    @"2.3 查询 -> 全局免打扰设置查询",// 9
                    @"2.1 设置 -> 全局免打扰设置",// 10
                    @"2.2 移除 -> 全局免打扰设置移除",// 11
                    @"3.3 查询 -> 频道免打扰设置查询",// 12
                    @"3.1 设置 -> 频道免打扰设置",// 13
                    @"3.2 移除 -> 频道免打扰设置移除",// 14
                    @"4.3 查询 -> 会话免打扰设置查询",// 15
                    @"4.1 设置 -> 会话免打扰设置",// 16
                    @"4.2 移除 -> 会话免打扰设置移除",// 17
                    @"5.3 查询 -> 会话类型免打扰设置查询",// 18
                    @"5.1 设置 -> 会话类型免打扰设置",// 19
                    @"5.2 移除 -> 会话类型免打扰设置移除",// 20
                    @"6.1.1 设置指定超级群默认通知配置",//21
                    @"6.1.2 查询指定超级群默认通知配置",// 22
                    @"6.2.1 设置指定超级群特定频道默认通知配置",//23
                    @"6.2.2 查询指定超级群特定频道默认通知配置",// 24
                    @"(其他)获取超级群未读数"];//25
    [self setupSubviews];
    [self setNavi];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.webUploader.running) {
        [self.webUploader stop];
    }
}

#pragma mark - Private Method
- (void)setupSubviews {
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}

- (void)setNavi {
    RCDUIBarButtonItem *rightBtn = 
        [[RCDUIBarButtonItem alloc] initWithbuttonTitle:@"沙盒" 
                                             titleColor:UIColor.blueColor 
                                            buttonFrame:CGRectMake(0, 0, 50, 30) 
                                                 target:self 
                                                 action:@selector(startHttpServer)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (NSString *)getNotificationQuietHoursLevelString:(RCPushNotificationQuietHoursLevel)level {
    NSString* levelstr = @"";
    switch (level) {
    case RCPushNotificationQuietHoursLevelMention:
        levelstr = @"群聊超级群仅@消息通知，单聊代表消息不通知";
        break;
    case RCPushNotificationQuietHoursLevelDefault:
        levelstr = @"未设置（向上查询群或者APP级别设置）";
        break;
    case RCPushNotificationQuietHoursLevelBlocked:
        levelstr = @"消息通知被屏蔽，即不接收消息通知";
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
        levelstr = @"全部消息通知";
        break;
    case RCPushNotificationLevelDefault:
        levelstr = @"未设置（向上查询群或者APP级别设置）";
        break;
    case RCPushNotificationLevelMention:
        levelstr = @"群聊超级群仅@消息通知（现在通知）单聊代表全部消息通知";
        break;
    case RCPushNotificationLevelMentionUsers:
        levelstr = @"指定用户通知";
        break;
    case RCPushNotificationLevelMentionAll:
        levelstr = @"群全员通知";
        break;
    case RCPushNotificationLevelBlocked:
        levelstr = @"消息通知被屏蔽，即不接收消息通知";
        break;
    default:
        break;
    }

    return levelstr;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 15)];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCDBaseSettingTableViewCellID"];
    if (!cell) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    cell.leftLabel.text = self.titles[indexPath.row];
    switch (indexPath.row) {
        case 0: {
            [cell setCellStyle:SwitchStyle];
            cell.switchButton.hidden = NO;
            [self setCurrentNotificationStatus:cell.switchButton];
            [cell.switchButton removeTarget:self
                                     action:@selector(clickIsTopBtn:)
                           forControlEvents:UIControlEventValueChanged];

            [cell.switchButton addTarget:self
                                  action:@selector(clickNotificationBtn:)
                        forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 1: {
            [cell setCellStyle:SwitchStyle];
            cell.switchButton.hidden = NO;
            RCConversationIdentifier *identifier = [[RCConversationIdentifier alloc] initWithConversationIdentifier:ConversationType_ULTRAGROUP targetId:self.targetId];
            BOOL isTop = [[RCCoreClient sharedCoreClient] getConversationTopStatus:identifier];
            cell.switchButton.on = isTop;
            [cell.switchButton addTarget:self
                                  action:@selector(clickIsTopBtn:)
                        forControlEvents:UIControlEventValueChanged];
        }
            break;
        default:
            [cell setCellStyle:DefaultStyle];
            cell.switchButton.hidden = YES;
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.titles[indexPath.row];
    if ([title isEqualToString:@"清空本地历史消息"]) {
        //清理历史消息
        [RCActionSheetView showActionSheetView:@"确定清除本地聊天记录？" cellArray:@[RCDLocalizedString(@"confirm")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
            [self clearHistoryMessage:NO];
        } cancelBlock:^{
                
        }];
    } else if ([title isEqualToString:@"清空本地和远端历史消息"]) {
        [RCActionSheetView showActionSheetView:@"确定清除本地和远端聊天记录？" cellArray:@[RCDLocalizedString(@"confirm")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
            [self clearHistoryMessage:YES];
        } cancelBlock:^{
                
        }];
    }
    
    switch (indexPath.row) {
        case 4:
            [self deleteUltraGroupMessagesForAllChannel];
            break;
        case 5:
            [self deleteUltraGroupMessages];
            break;
        case 6:
            [self deleteRemoteUltraGroupMessages];
            break;
        case 7:
            [self sendKVTextMessage];
            break;
        case 8:
            [self getConversationListForAllChannel:ConversationType_ULTRAGROUP targetId:self.targetId];
            break;
        case 9:
            [self showNotificationQuietHoursLevel];
            break;
        case 10:
            [self pushToNotificationSettingVC];
            break;
        case 11:
            [self showDeleteNotificationQuietHoursLevel];
            break;
        case 12:
            [self showConversationChannelNotificationLevel];
            break;
        case 13:
            [self pushToChannelNotificationSettingVC];
            break;
        case 14:
            [self showDeleteChannelNotificationLevel];
            break;
        case 15:
            [self showConversationNotificationLevel];
            break;
        case 16:
            [self pushToConversationNotificationSettingVC];
            break;
        case 17:
            [self showDeleteConversationNotificationLevel];
            break;
        case 18:
            [self showConversationTypeNotificationLevel];
            break;
        case 19:
            [self pushToConversationTypeNotificationSettingVC];
            break;
        case 20:
            [self showDeleteConversationTypeNotificationLevel];
            break;
        case 21:
            [self configureUltraGroupConversationDefaultNotificationLevel];
            break;
        case 22:
            [self showUltraGroupConversationDefaultNotificationLevel];
            break;
        case 23:
            [self configureUltraGroupConversationChannelDefaultNotificationLevel];
            break;
        case 24:
            [self showUltraGroupConversationChannelDefaultNotificationLevel];
            break;
        case 25:
            [self unreadMessageVerify];
            break;
        default:
            break;
    }
}

- (void)unreadMessageVerify {
    RCDDebugUltraGroupUnreadMessageViewController *vc = [RCDDebugUltraGroupUnreadMessageViewController new];
    NSString *title = [NSString stringWithFormat:@"未读消息数测试(TargetID): %@", self.targetId];
    vc.title = title;
    vc.targetID = self.targetId;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)setCurrentNotificationStatus:(UISwitch *)switchButton {
    
    [[RCChannelClient sharedChannelManager] getConversationNotificationStatus:ConversationType_ULTRAGROUP targetId:self.targetId channelId:self.channelId success:^(RCConversationNotificationStatus nStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switchButton.on = !nStatus;
            });
        } error:^(RCErrorCode status) {
            
        }];
}

- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    RCConnectionStatus connectStatus = [[RCIM sharedRCIM] getConnectionStatus];
    if (connectStatus != ConnectionStatus_Connected) {
        swch.on = !swch.on;
        [RCAlertView showAlertController:nil message:RCDLocalizedString(@"Set failed") cancelTitle:RCDLocalizedString(@"confirm")];
        return;
    }
    [[RCChannelClient sharedChannelManager] setConversationNotificationStatus:ConversationType_ULTRAGROUP
                                                                     targetId:self.targetId
                                                                    channelId:self.channelId
                                                                    isBlocked:swch.isOn
                                                                      success:^(RCConversationNotificationStatus nStatus) {
        
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            swch.on = !swch.on;
        });
    }];
}

- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_ULTRAGROUP targetId:self.targetId isTop:swch.on];
}

- (void)clearHistoryMessage:(BOOL)clearRemote {
    [[RCChannelClient sharedChannelManager] clearHistoryMessages:self.type
                                                        targetId:self.targetId
                                                       channelId:self.channelId
                                                      recordTime:self.recordTime
                                                     clearRemote:clearRemote
                                                         success:^{
        [self showAlertMessage:nil msg:RCDLocalizedString(@"clear_chat_history_success")];
    } error:^(RCErrorCode status) {
        [self showAlertMessage:nil msg:RCDLocalizedString(@"clear_chat_history_fail")];
    }];
}

- (void)showAlertMessage:(NSString *)title msg:(NSString *)msg {
    [RCAlertView showAlertController:title message:msg cancelTitle:RCDLocalizedString(@"confirm")];
}

- (void)sendKVTextMessage {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRCDDebugChatSettingNotification object:@(RCDDebugNotificationTypeSendMsgKV)];
}

#pragma mark- 获取特定会话下所有频道的会话列表
- (void)getConversationListForAllChannel:(RCConversationType)conversationType targetId:(NSString *)targetId {
    NSArray <RCConversation *>*conversationList = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:conversationType targetId:targetId];
    if (conversationList) {
        NSMutableArray *msgUids = [NSMutableArray new];
        for (RCConversation *con in conversationList) {
            [msgUids addObject:[NSString stringWithFormat:@"%@-%@-%@",@(con.conversationType),con.targetId, con.channelId]];
        }
        NSString *msgUid = [msgUids componentsJoinedByString:@"\n"];
        [self showAlertMessage:[NSString stringWithFormat:@"%tu类型-会话ID-频道Id",conversationList.count] msg:msgUid];
    } else {
        [self showAlertMessage:nil msg:@"获得的会话列表数获取失败"];
    }
}

- (void)showGetConversationListAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入会话id和会话类型" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //增加确定按钮
    [alertController addAction:[UIAlertAction actionWithTitle:@"查找" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        //获取第1个输入框；
        UITextField *titleTextField = alertController.textFields[0];
        UITextField *titleTextField2 = alertController.textFields[1];
        
        if (titleTextField.text.length * titleTextField2.text.length != 0) {
            [self getConversationListForAllChannel:[titleTextField.text integerValue] targetId:titleTextField2.text];
        }
    }]];

    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入会话类型";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入会话ID";
    }];
    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark- 删除消息
- (void)deleteUltraGroupMessagesForAllChannel {
    UInt64 time = [[NSDate date] timeIntervalSince1970]*1000;

    BOOL result = [[RCChannelClient sharedChannelManager] deleteUltraGroupMessagesForAllChannel:self.targetId timestamp:time];
    if (result) {
        [self showAlertMessage:nil msg:@"删除本地所有 channel 当前时间之前的消息成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRCDDebugChatSettingNotification object:@(RCDDebugNotificationTypeDelete)];
    } else {
        [self showAlertMessage:nil msg:@"删除本地所有 channel 当前时间之前的消息失败"];
    }
}

- (void)deleteUltraGroupMessages {
    UInt64 time = [[NSDate date] timeIntervalSince1970]*1000;
    
    BOOL result = [[RCChannelClient sharedChannelManager] deleteUltraGroupMessages:self.targetId channelId:self.channelId timestamp:time];
    
    if (result) {
        [self showAlertMessage:nil msg:@"删除本地当前 channel 当前时间之前的消息成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRCDDebugChatSettingNotification object:@(RCDDebugNotificationTypeDelete)];
    } else {
        [self showAlertMessage:nil msg:@"删除本地当前 channel 当前时间之前的消息失败"];
    }
}

- (void)deleteRemoteUltraGroupMessages {
    UInt64 time = [[NSDate date] timeIntervalSince1970]*1000;

    [[RCChannelClient sharedChannelManager] deleteRemoteUltraGroupMessages:self.targetId channelId:self.channelId timestamp:time success:^{
            [self showAlertMessage:nil msg:@"删除服务端当前 channel 当前时间之前的消息成功"];
        } error:^(RCErrorCode status) {
            [self showAlertMessage:nil msg:@"删除服务端当前 channel 当前时间之前的消息成功"];
        }];
}

#pragma mark - 免打扰
- (void)showNotificationQuietHoursLevel {
    [[RCChannelClient sharedChannelManager] getNotificationQuietHoursLevel:^(NSString *startTime, int spanMins, RCPushNotificationQuietHoursLevel level) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:nil 
                                       msg:[NSString stringWithFormat:@"开始时间：%@，间隔时间：%d分钟，级别:%@", startTime, spanMins, [self getNotificationQuietHoursLevelString:level]]];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                       msg:nil];
                });
        }];
}

- (void)pushToNotificationSettingVC {
    RCDDebugNotificationQuietHoursSettingViewController *vc = 
        [[RCDDebugNotificationQuietHoursSettingViewController alloc] init];
    vc.title = @"设置全局免打扰";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDeleteNotificationQuietHoursLevel {
    [[RCCoreClient sharedCoreClient] removeNotificationQuietHours:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"删除设置成功" msg:nil];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"删除设置失败" msg:[NSString stringWithFormat:@"错误码为%zd", status]];
                });
        }];
}

- (void)showConversationChannelNotificationLevel {
    [[RCChannelClient sharedChannelManager] getConversationChannelNotificationLevel:self.type
                                                                           targetId:self.targetId
                                                                          channelId:self.channelId
                                                                            success:^(RCPushNotificationLevel level) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:nil 
                                       msg:[NSString stringWithFormat:@"频道免打扰级别:%@", [self getPushNotificationLevelString:level]]];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                       msg:nil];
                });
        }];
}

- (void)pushToChannelNotificationSettingVC {
    RCDDebugConversationChannelNotificationLevelViewController *vc = 
        [[RCDDebugConversationChannelNotificationLevelViewController alloc] init];
    vc.title = @"设置频道免打扰";
    vc.targetId = self.targetId;
    vc.channelId = self.channelId;
    vc.type = self.type;
    vc.settingType = RCDUltraGroupSettingTypeConversationChannel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDeleteChannelNotificationLevel {
    [[RCChannelClient sharedChannelManager] setConversationChannelNotificationLevel:self.type
                                                                           targetId:self.targetId
                                                                          channelId:self.channelId
                                            level:RCPushNotificationLevelDefault
                                          success:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"删除设置成功" msg:nil];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"删除设置失败" msg:[NSString stringWithFormat:@"错误码为%zd", status]];
                });
        }];
}

- (void)showConversationNotificationLevel {
    [[RCChannelClient sharedChannelManager] getConversationNotificationLevel:self.type
                                                             targetId:self.targetId
                                                              success:^(RCPushNotificationLevel level) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:nil 
                                       msg:[NSString stringWithFormat:@"会话免打扰级别:%@", [self getPushNotificationLevelString:level]]];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                       msg:nil];
                });
        }];
}

- (void)pushToConversationNotificationSettingVC {
    RCDDebugConversationChannelNotificationLevelViewController *vc = 
        [[RCDDebugConversationChannelNotificationLevelViewController alloc] init];
    vc.title = @"设置会话免打扰";
    vc.targetId = self.targetId;
    vc.type = self.type;
    vc.settingType = RCDUltraGroupSettingTypeConversation;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDeleteConversationNotificationLevel {
    [[RCChannelClient sharedChannelManager] setConversationNotificationLevel:self.type
                                                                    targetId:self.targetId
                                                                       level:RCPushNotificationLevelDefault
                                                                     success:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"删除设置成功" msg:nil];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"删除设置失败" msg:[NSString stringWithFormat:@"错误码为%zd", status]];
                });
        }];
}

- (void)showConversationTypeNotificationLevel {
    [[RCChannelClient sharedChannelManager] getConversationTypeNotificationLevel:self.type
                                                              success:^(RCPushNotificationLevel level) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:nil 
                                       msg:[NSString stringWithFormat:@"会话类型免打扰级别:%@", [self getPushNotificationLevelString:level]]];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                       msg:nil];
                });
        }];
}

- (void)pushToConversationTypeNotificationSettingVC {
    RCDDebugConversationChannelNotificationLevelViewController *vc = 
        [[RCDDebugConversationChannelNotificationLevelViewController alloc] init];
    vc.title = @"设置会话类型免打扰";
    vc.type = self.type;
    vc.settingType = RCDUltraGroupSettingTypeConversationType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDeleteConversationTypeNotificationLevel {
    [[RCChannelClient sharedChannelManager] setConversationTypeNotificationLevel:self.type
                                                                    level:RCPushNotificationLevelDefault
                                          success:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"删除设置成功" msg:nil];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"删除设置失败" msg:[NSString stringWithFormat:@"错误码为%zd", status]];
                });
        }];
}

- (void)configureUltraGroupConversationDefaultNotificationLevel {
    RCDDebugConversationChannelNotificationLevelViewController *vc =
        [[RCDDebugConversationChannelNotificationLevelViewController alloc] init];
    vc.title = @"6.1.1 设置指定超级群默认通知配置";
    vc.type = self.type;
    vc.targetId = self.targetId;
    vc.channelId = self.channelId;
    vc.settingType = RCDUltraGroupSettingTypeConversationDefault;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configureUltraGroupConversationChannelDefaultNotificationLevel {
    RCDDebugConversationChannelNotificationLevelViewController *vc =
        [[RCDDebugConversationChannelNotificationLevelViewController alloc] init];
    vc.title = @"6.2.1 设置指定超级群特定频道默认通知配置";
    vc.type = self.type;
    vc.targetId = self.targetId;
    vc.channelId = self.channelId;
    vc.settingType = RCDUltraGroupSettingTypeConversationChannelDefault;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)showUltraGroupConversationDefaultNotificationLevel {
    [[RCChannelClient sharedChannelManager] getUltraGroupConversationDefaultNotificationLevel:self.targetId
                                                                               success:^(RCPushNotificationLevel level) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:nil 
                                       msg:[NSString stringWithFormat:@"超级群默认通知级别:%@", [self getPushNotificationLevelString:level]]];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                       msg:nil];
                });
        }];
}

- (void)showUltraGroupConversationChannelDefaultNotificationLevel {
    [[RCChannelClient sharedChannelManager] getUltraGroupConversationChannelDefaultNotificationLevel:self.targetId
                                                                                           channelId:self.channelId
                                                                                             success:^(RCPushNotificationLevel level) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:nil 
                                       msg:[NSString stringWithFormat:@"超级群频道默认通知级别:%@", [self getPushNotificationLevelString:level]]];
                });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:[NSString stringWithFormat:@"查询失败，错误码：%zd", status]
                                       msg:nil];
                });
        }];
}

#pragma mark- 沙盒
- (void)startHttpServer {
    NSString *homePath = NSHomeDirectory();
    self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:homePath];
    if ([self.webUploader start]) {
        NSString *host = self.webUploader.serverURL.absoluteString;
        [RCAlertView showAlertController:host message:@"请在电脑浏览器打开上面的地址" cancelTitle:@"确定" inViewController:self];
        NSLog(@"web uploader host:%@ port:%@", host, @(self.webUploader.port));
    }
}

#pragma mark - Setter && Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = YES;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
@end
