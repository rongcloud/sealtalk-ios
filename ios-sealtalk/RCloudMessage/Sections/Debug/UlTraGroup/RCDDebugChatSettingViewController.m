//
//  RCDDebugChatSettingViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2021/11/29.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugChatSettingViewController.h"
#import <Masonry/Masonry.h>
#import "RCDBaseSettingTableViewCell.h"
#import <RongIMKit/RongIMKit.h>
#import <GCDWebServer/GCDWebUploader.h>
#import "RCDUIBarButtonItem.h"
#import "RCDDebugUltraGroupDefine.h"

@interface RCDDebugChatSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) GCDWebUploader *webUploader;

@end

@implementation RCDDebugChatSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titles = @[RCDLocalizedString(@"mute_notifications"), RCDLocalizedString(@"stick_on_top"), @"清空本地历史消息", @"清空本地和远端历史消息", @"删除本地「所有频道」当前时间之前的消息",@"删除本地「当前频道」当前时间之前的消息",@"删除「服务端」当前时间之前的消息", @"发一条携带{tKey:当前时间}文本消息", @"获取「当前超级群」所有频道的lastMsgUid"];
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
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initWithbuttonTitle:@"沙盒" titleColor:UIColor.blueColor buttonFrame:CGRectMake(0, 0, 50, 30) target:self action:@selector(startHttpServer)];
    self.navigationItem.rightBarButtonItem = rightBtn;
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
            break;
        case 10:
            break;
        default:
            break;
    }
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
    [[RCChannelClient sharedChannelManager]
     setConversationNotificationStatus:ConversationType_ULTRAGROUP
     targetId:self.targetId
     channelId:self.channelId
     isBlocked:swch.on
     success:^(RCConversationNotificationStatus nStatus) {
        NSLog(@"");
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
        _tableView.scrollEnabled = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
@end
