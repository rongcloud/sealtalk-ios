//
//  RCDDebugTableViewController.m
//  SealTalk
//
//  Created by Jue on 2018/5/11.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCDDebugTableViewController.h"
#import "RCDDebugViewController.h"
#import "RCDDebugNoDisturbViewController.h"
#import <RongIMKit/RongIMKit.h>
#import <SSZipArchive/SSZipArchive.h>
#import "RCDCommonString.h"
#import <GCDWebServer/GCDWebUploader.h>
#import "RCDDebugJoinChatroomViewController.h"
#import "RCDDataStatistics.h"
#import "RCDDebugSelectChatController.h"
#import "RCDDebugDiscussionController.h"
#import "RCDDebugMessagePushConfigController.h"
#import "RCDDebugChatListViewController.h"
#import "UIView+MBProgressHUD.h"
#import "RCDDebugConversationTagController.h"
#import "RCDDebugGroupChatListViewController.h"
#import "RCDDebugMsgShortageChatListController.h"
#import <UMCommon/UMCommon.h>
#import "RCDDebugUltraGroupListController.h"
#import <RongChatRoom/RongChatRoom.h>
#import "UIView+MBProgressHUD.h"
#import "RCDDebugComChatListController.h"
#import "RCDDebugFileIconViewController.h"
#define DISPLAY_ID_TAG 100
#define DISPLAY_ONLINE_STATUS_TAG 101
#define JOIN_CHATROOM_TAG 102
#define DATA_STATISTICS_TAG 103
#define BURN_MESSAGE_TAG 104
#define SEND_COMBINE_MESSAGE_TAG 105
#define DISABLE_SYSTEM_EMOJI_TAG 106
#define DISABLE_UTRAL_GORUP_SYNC_TAG 107
#define DISABLE_KEYBOARD_TAG 108
#define DISABLE_ULTRA_GROUP_TAG 109
#define DISABLE_COMPLEX_TEXT_AYNC_DRAW 110
#define DISABLE_COMMON_PHRASES 111
#define DISABLE_HIDDEN_PORTRAIT 112
#define ENABLE_CUSTOM_EMOJI 113
#define DISABLE_EMOJI_BUTTON 114
#define DISABLE_CHECK_DUP_MESSAGE 115
#define ENABLE_GROUP_REAL_TIME_LOCATION 116
#define ENABLE_INTERCEPT_WILLSEND_COMBINE 117
#define ENABLE_CONVERSATION_DISPLAY_NAME 118
#define FILEMANAGER [NSFileManager defaultManager]

@interface RCCoreClient()
- (void)refetchNavidataSuccess:(void (^)(void))success
                       failure:(void (^)(NSInteger errorCode, NSString *responseData, NSString *errorDescription))failure;

@end

@interface RCDDebugTableViewController ()

@property (nonatomic, strong) NSDictionary *functions;

@property (nonatomic, strong) NSString *documentPath;

@property (nonatomic, strong) NSString *libraryPath;

@property (nonatomic, strong) NSString *currentDateStr;

@property (nonatomic, strong) NSString *createPath;

@property (nonatomic, strong) GCDWebUploader *webUploader;
@end

@implementation RCDDebugTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initdata];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.webUploader.running) {
        [self.webUploader stop];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.functions.allKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *allkeys = [self.functions allKeys];
    NSArray *titles = self.functions[allkeys[section]];
    return titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *title = [[UILabel alloc] init];
    title.font = [UIFont systemFontOfSize:15];
    title.textColor = [UIColor grayColor];
    title.text = self.functions.allKeys[section];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    根据indexPath准确地取出一行，而不是从cell重用队列中取出
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    NSArray *allkeys = [self.functions allKeys];
    NSArray *titles = self.functions[allkeys[indexPath.section]];
    NSString *title = titles[indexPath.row];
    cell.textLabel.text = title;
    cell.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                    darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    cell.detailTextLabel.text = @"";
    cell.textLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    if ([title isEqualToString:RCDLocalizedString(@"show_ID")]) {
        [self setSwitchButtonCell:cell tag:DISPLAY_ID_TAG];
    }
    if ([title isEqualToString:RCDLocalizedString(@"show_online_status")]) {
        [self setSwitchButtonCell:cell tag:DISPLAY_ONLINE_STATUS_TAG];
    }
    if ([title isEqualToString:RCDLocalizedString(@"Joining_the_chat_room_failed_to_stay_in_the_session_interface")]) {
        [self setSwitchButtonCell:cell tag:JOIN_CHATROOM_TAG];
    }
    if ([title isEqualToString:@"打开性能数据统计"]) {
        [self setSwitchButtonCell:cell tag:DATA_STATISTICS_TAG];
    }
    if ([title isEqualToString:@"阅后即焚"]) {
        [self setSwitchButtonCell:cell tag:BURN_MESSAGE_TAG];
    }
    if ([title isEqualToString:@"合并转发"]) {
        [self setSwitchButtonCell:cell tag:SEND_COMBINE_MESSAGE_TAG];
    }
    if ([title isEqualToString:@"禁用系统表情"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_SYSTEM_EMOJI_TAG];
    }
    if ([title isEqualToString:@"超级群消息同步监听"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_UTRAL_GORUP_SYNC_TAG];
    }
    if ([title isEqualToString:@"输入时弹框"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_KEYBOARD_TAG];
    }
    if ([title isEqualToString:@"超级群功能"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_ULTRA_GROUP_TAG];
    }
    if ([title isEqualToString:@"长文本异步绘制"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_COMPLEX_TEXT_AYNC_DRAW];
    }
    if ([title isEqualToString:@"动态常用语"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_COMMON_PHRASES];
    }
    if ([title isEqualToString:@"隐藏头像"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_HIDDEN_PORTRAIT];
    }
    
    if ([title isEqualToString:@"自定义表情"]) {
        [self setSwitchButtonCell:cell tag:ENABLE_CUSTOM_EMOJI];
    }
    if ([title isEqualToString:@"隐藏表情按钮"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_EMOJI_BUTTON];
    }
    if ([title isEqualToString:@"关闭消息排重并杀死APP"]) {
        [self setSwitchButtonCell:cell tag:DISABLE_CHECK_DUP_MESSAGE];
    }
    if ([title isEqualToString:@"开启群组实时位置共享"]) {
        [self setSwitchButtonCell:cell tag:ENABLE_GROUP_REAL_TIME_LOCATION];
    }
    if ([title isEqualToString:@"开启合并转发拦截"]) {
        [self setSwitchButtonCell:cell tag:ENABLE_INTERCEPT_WILLSEND_COMBINE];
    }
    if ([title isEqualToString:@"私聊显示用户名"]) {
        [self setSwitchButtonCell:cell tag:ENABLE_CONVERSATION_DISPLAY_NAME];
    }
    
    if ([title isEqualToString:RCDLocalizedString(@"Set_offline_message_compensation_time")] ||
        [title isEqualToString:RCDLocalizedString(@"Set_global_DND_time")]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if([title isEqualToString:@"友盟设备识别信息"]){
    }
    return cell;
}

- (void)startHttpServer:(int)index {
    NSString *homePath = NSHomeDirectory();
    if (1 == index) {
        homePath = [self getIMDBPath];
    }
    self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:homePath];
    if ([self.webUploader start]) {
        NSString *host = self.webUploader.serverURL.absoluteString;
        [RCAlertView showAlertController:host message:@"请在电脑浏览器打开上面的地址" cancelTitle:@"确定" inViewController:self];
        NSLog(@"web uploader host:%@ port:%@", host, @(self.webUploader.port));
    }
}


- (NSString *)getIMDBPath{
    NSURL *sharedURL = [[NSFileManager defaultManager]
                        containerURLForSecurityApplicationGroupIdentifier:RCDNotificationServiceGroup];
    NSString *path = sharedURL.path;
    NSLog(@"RCDPushExtention: im db path is %@",path);
    return path;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *title = cell.textLabel.text;
    if ([title isEqualToString:RCDLocalizedString(@"force_crash")]) {
        [self doCrash];
    } else if ([title isEqualToString:RCDLocalizedString(@"send_log")]) {
        [self copyAndSendFiles];
    } else if ([title isEqualToString:@"显示沙盒内容"]) {
        [self startHttpServer];
    }  else if([title isEqualToString:@"显示PushExt沙盒"]){

        [self startHttpServer:1];
    } else if ([title isEqualToString:RCDLocalizedString(@"Set_offline_message_compensation_time")]) {
        [self pushToDebugVC];
    } else if ([title isEqualToString:RCDLocalizedString(@"Set_global_DND_time")]) {
        [self pushToNoDisturbVC];
    } else if ([title isEqualToString:@"进入聊天室存储测试"]) {
        [self pushToChatroomStatusVC];
    } else if([title isEqualToString:@"聊天室绑定RTCRoom"]) {
        [self showChatroomBindAlert];
    }
    else if ([title isEqualToString:RCDLocalizedString(@"Set_chatroom_default_history_message")]) {
        [self showAlertController];
    } else if ([title isEqualToString:@"讨论组"]) {
        [self pushToDiscussionVC];
    } else if ([title isEqualToString:@"配置消息推送属性"]) {
        [self pushToMessagePushConfigVC];
    } else if ([title isEqualToString:@"进入消息推送属性测试"]) {
        [self pushToChatListVC];
    } else if ([title isEqualToString:@"消息扩展"]){
        [self pushDebugMessageExtensionVC];
    } else if ([title isEqualToString:@"设置推送语言"]) {
        [self setPushLauguageCode];
    } else if ([title isEqualToString:@"会话标签"]) {
        [self pushConversationTagVC];
    }else if ([title isEqualToString:@"新的群已读回执"]) {
        [self pushGroupChatListVC];
    }else if ([title isEqualToString:@"消息断档"]) {
        [self selectChatLoadMessageType];
    }else if ([title isEqualToString:@"友盟设备识别信息"]) {
        [self  showUMengDeviceInfoAlertController];
    }else if ([title isEqualToString:@"超级群"]) {
        [self pushUltraGroupChatListVC];
    } else if ([title isEqualToString:@"普通群"]) {
        [self showCommonChatRoom];
    } else if ([title isEqualToString:@"选择聚合头像方式"]) {
        [self selectConversationCollectionInfoModifyType];
    } else if ([title isEqualToString:@"刷新NaviData"]) {
        [self refreshNaviData];
    } else if ([title isEqualToString:@"自定义文件图标"]) {
        [self showCustomFileIcon];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - init data for tabelview
- (void)initdata {
    NSMutableDictionary *dic = [NSMutableDictionary new];

    [dic setObject:@[ RCDLocalizedString(@"show_ID"), RCDLocalizedString(@"show_online_status") ]
            forKey:RCDLocalizedString(@"show_setting")];

    [dic setObject:@[
        RCDLocalizedString(@"force_crash"),
        RCDLocalizedString(@"send_log"),
        @"显示沙盒内容",
        @"显示PushExt沙盒",
        RCDLocalizedString(@"Joining_the_chat_room_failed_to_stay_in_the_session_interface"),
        @"打开性能数据统计",
        @"阅后即焚",
        @"合并转发",
        @"消息扩展",
        @"禁用系统表情",
        @"超级群消息同步监听",
        @"输入时弹框",
        @"超级群功能",
        @"长文本异步绘制",
        @"刷新NaviData",
        @"动态常用语",
        @"隐藏头像",
        @"自定义表情",
        @"隐藏表情按钮",
        @"关闭消息排重并杀死APP",
        @"开启群组实时位置共享",
        @"开启合并转发拦截",
        @"自定义文件图标",
        @"私聊显示用户名"
    ]
            forKey:RCDLocalizedString(@"custom_setting")];
    [dic setObject:@[ @"进入聊天室存储测试", RCDLocalizedString(@"Set_chatroom_default_history_message"), @"聊天室绑定RTCRoom" ]
            forKey:@"聊天室测试"];
    [dic setObject:@[
        RCDLocalizedString(@"Set_offline_message_compensation_time"),
        RCDLocalizedString(@"Set_global_DND_time")
    ]
            forKey:RCDLocalizedString(@"time_setting")];

    [dic setObject:@[@"讨论组", @"配置消息推送属性", @"进入消息推送属性测试", @"设置推送语言", @"会话标签",@"新的群已读回执", @"消息断档",@"友盟设备识别信息", @"超级群", @"普通群", @"选择聚合头像方式"] forKey:@"功能"];
    self.functions = [dic copy];
}

#pragma mark private methord

/**
 为cell添加swtich button

 @param cell cell对象
 */
- (void)addSwitchToCell:(UITableViewCell *)cell {
    BOOL isNeedAdd = YES;
    for (UIView *subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UISwitch class]]) {
            isNeedAdd = NO;
            break;
        }
    }
    if (isNeedAdd == NO)
        return;
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.onTintColor = HEXCOLOR(0x0099ff);
    switchView.translatesAutoresizingMaskIntoConstraints = NO;
    [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    switchView.tag = cell.tag;
    BOOL isButtonOn = NO;
    switch (cell.tag) {
        case DISPLAY_ID_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDisplayIDKey];
        } break;
            
        case DISPLAY_ONLINE_STATUS_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDisplayOnlineStatusKey];
        }
            break;
        case JOIN_CHATROOM_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDStayAfterJoinChatRoomFailedKey];
        }
            break;
        case DATA_STATISTICS_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDebugDataStatisticsKey];
        }
            break;
        case BURN_MESSAGE_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDebugBurnMessageKey];
        }
            break;
        case SEND_COMBINE_MESSAGE_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDebugSendCombineMessageKey];
        }
            break;
        case DISABLE_SYSTEM_EMOJI_TAG:{
            isButtonOn = [DEFAULTS boolForKey:RCDDebugDisableSystemEmoji];
            break;
        }
        case DISABLE_UTRAL_GORUP_SYNC_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDebugUtralGroupSyncKey];
        }
            break;
        case DISABLE_KEYBOARD_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDebugInputKeyboardUIKey];
        }
            break;
            
        case DISABLE_ULTRA_GROUP_TAG:{
            isButtonOn = [DEFAULTS boolForKey:RCDDebugUltraGroupEnable];
        }
            break;
            
        case DISABLE_COMPLEX_TEXT_AYNC_DRAW:{
            isButtonOn = [DEFAULTS boolForKey:RCDDebugTextAsyncDrawEnable];
        }
            break;
        case DISABLE_COMMON_PHRASES:{
            isButtonOn = [DEFAULTS boolForKey:RCDDebugCommonPhrasesEnable];
        }
            break;
        case DISABLE_HIDDEN_PORTRAIT:{
            isButtonOn = [DEFAULTS boolForKey:RCDDebugHidePortraitEnable];
        }
            break;
        case ENABLE_CUSTOM_EMOJI:{
            isButtonOn = [DEFAULTS boolForKey:RCDDebugEnableCustomEmoji];
        }
            break;
        case DISABLE_EMOJI_BUTTON:{
            isButtonOn = [DEFAULTS boolForKey:RCDDebugDisableEmojiBtn];
            break;
        }
        case DISABLE_CHECK_DUP_MESSAGE:{
            isButtonOn = [DEFAULTS boolForKey:RCDDebugDisableCheckDupMessage];
            break;
        }
        case  ENABLE_GROUP_REAL_TIME_LOCATION:
            isButtonOn = [DEFAULTS boolForKey:RCDDebugEnableRealTimeLocation];
            break;
        case ENABLE_INTERCEPT_WILLSEND_COMBINE: {
            isButtonOn = [DEFAULTS boolForKey:RCDDebugInterceptWillSendCombineFuntion];
            break;
        }
        case ENABLE_CONVERSATION_DISPLAY_NAME: {
            isButtonOn = [DEFAULTS boolForKey:RCDDebugDisplayUserName];
            break;
            
        }
        default:
            break;
    }
    switchView.on = isButtonOn;
    [cell.contentView addSubview:switchView];

    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:switchView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];

    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:switchView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:-20]];
}

- (void)switchAction:(id)sender {
    UISwitch *switchButton = (UISwitch *)sender;
    BOOL isButtonOn = [switchButton isOn];
    switch (switchButton.tag) {
    case DISPLAY_ID_TAG: {
        [DEFAULTS setBool:isButtonOn forKey:RCDDisplayIDKey];
        [DEFAULTS synchronize];
    } break;

    case DISPLAY_ONLINE_STATUS_TAG: {
        [DEFAULTS setBool:isButtonOn forKey:RCDDisplayOnlineStatusKey];
        [DEFAULTS synchronize];
    } break;

    case JOIN_CHATROOM_TAG: {
        [DEFAULTS setBool:isButtonOn forKey:RCDStayAfterJoinChatRoomFailedKey];
        [DEFAULTS synchronize];
    } break;
    case DATA_STATISTICS_TAG: {
        [DEFAULTS setBool:isButtonOn forKey:RCDDebugDataStatisticsKey];
        [DEFAULTS synchronize];
        [[RCDDataStatistics sharedInstance] notify];
    } break;
    case BURN_MESSAGE_TAG: {
        [DEFAULTS setBool:isButtonOn forKey:RCDDebugBurnMessageKey];
        [DEFAULTS synchronize];
        RCKitConfigCenter.message.enableDestructMessage = isButtonOn;
    } break;
    case SEND_COMBINE_MESSAGE_TAG: {
        [DEFAULTS setBool:isButtonOn forKey:RCDDebugSendCombineMessageKey];
        [DEFAULTS synchronize];
        [RCIM sharedRCIM].enableSendCombineMessage = isButtonOn;
    } break;
        case DISABLE_SYSTEM_EMOJI_TAG:{
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugDisableSystemEmoji];
            [DEFAULTS synchronize];
            break;
        }
        case DISABLE_UTRAL_GORUP_SYNC_TAG: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugUtralGroupSyncKey];
            [DEFAULTS synchronize];
            break;
        }
        case DISABLE_KEYBOARD_TAG: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugInputKeyboardUIKey];
            [DEFAULTS synchronize];
            break;
        }
        case DISABLE_COMPLEX_TEXT_AYNC_DRAW: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugTextAsyncDrawEnable];
            [DEFAULTS synchronize];
            break;
        }
        case DISABLE_ULTRA_GROUP_TAG: {
            [self showUltraGroupAlert:switchButton];
            break;
        }
        case DISABLE_COMMON_PHRASES: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugCommonPhrasesEnable];
            [DEFAULTS synchronize];
            break;
        }
        case DISABLE_HIDDEN_PORTRAIT: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugHidePortraitEnable];
            [DEFAULTS synchronize];
            break;
        }
            
        case ENABLE_CUSTOM_EMOJI: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugEnableCustomEmoji];
            [DEFAULTS synchronize];
            break;
        }
        case DISABLE_EMOJI_BUTTON: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugDisableEmojiBtn];
            [DEFAULTS synchronize];
            break;
        }
        case DISABLE_CHECK_DUP_MESSAGE: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugDisableCheckDupMessage];
            [DEFAULTS synchronize];
            break;
        }
        case ENABLE_GROUP_REAL_TIME_LOCATION: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugEnableRealTimeLocation];
            [DEFAULTS synchronize];
            break;
        }
        case ENABLE_INTERCEPT_WILLSEND_COMBINE: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugInterceptWillSendCombineFuntion];
            [DEFAULTS synchronize];
            break;
        }
        case ENABLE_CONVERSATION_DISPLAY_NAME: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDebugDisplayUserName];
            [DEFAULTS synchronize];
            break;
        }
            
    default:
        break;
    }
}

- (void)setSwitchButtonCell:(UITableViewCell *)cell tag:(int)tag {
    cell.tag = tag;
    [self addSwitchToCell:cell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)showUltraGroupAlert:(UISwitch *)btnSwitch {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"超级群功能变更"
                                            message:@"为了变更生效,需要重启App"
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction =
    [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [DEFAULTS setBool:btnSwitch.isOn forKey:RCDDebugUltraGroupEnable];
        [DEFAULTS synchronize];
        exit(0);
    }];
    [alertController addAction:okAction];

    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        btnSwitch.on = !btnSwitch.isOn;
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
/**
 强制Crash
 */
- (void)doCrash {
    [@[] objectAtIndex:1];
}

/**
 跳转到设置离线消息补偿时间的页面
 */
- (void)pushToDebugVC {
    RCDDebugViewController *vc = [[RCDDebugViewController alloc] init];
    vc.title = RCDLocalizedString(@"Set_offline_message_compensation_time");
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 跳转到设置全局免打扰的页面
 */
- (void)pushToNoDisturbVC {
    RCDDebugNoDisturbViewController *vc = [[RCDDebugNoDisturbViewController alloc] init];
    vc.title = @"设置全局免打扰";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushDebugMessageExtensionVC{
    RCDDebugSelectChatController *vc = [[RCDDebugSelectChatController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushConversationTagVC{
    RCDDebugConversationTagController *vc = [[RCDDebugConversationTagController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushGroupChatListVC{
    RCDDebugGroupChatListViewController *vc = [[RCDDebugGroupChatListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectChatLoadMessageType{
    [RCActionSheetView showActionSheetView:nil cellArray:@[@"总是加载", @"询问加载", @"只有成功时加载"] cancelTitle:RCDLocalizedString(@"Cancel") selectedBlock:^(NSInteger index) {
        [[NSUserDefaults standardUserDefaults] setObject:@(index) forKey:@"RCDChatLoadMessageType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } cancelBlock:^{
        
    }];
}

// 设置聚合头像的改变方式
- (void)selectConversationCollectionInfoModifyType {
    [RCActionSheetView showActionSheetView:nil cellArray:@[@"恢复默认", @"显示前修改聚合", @"全局配置修改聚合"] cancelTitle:RCDLocalizedString(@"Cancel") selectedBlock:^(NSInteger index) {
        [[NSUserDefaults standardUserDefaults] setObject:@(index) forKey:@"selectConversationCollectionInfoModifyType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } cancelBlock:^{
        
    }];
}
- (void)startHttpServer {
    NSString *homePath = NSHomeDirectory();
    self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:homePath];
    if ([self.webUploader start]) {
        NSString *host = self.webUploader.serverURL.absoluteString;
        [RCAlertView showAlertController:host message:@"请在电脑浏览器打开上面的地址" cancelTitle:@"确定" inViewController:self];
        NSLog(@"web uploader host:%@ port:%@", host, @(self.webUploader.port));
    }
}

// 显示设置加入聊天室时获取历史消息数量的弹窗
- (void)showAlertController {
    __block UITextField *tempTextField;
    NSInteger num = [DEFAULTS integerForKey:RCDChatroomDefalutHistoryMessageCountKey];
    NSString *message = [NSString stringWithFormat:RCDLocalizedString(@"pullXMessage"), num];
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:RCDLocalizedString(@"Set_chatroom_default_history_message_count")
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"OK")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   NSInteger count = [tempTextField.text integerValue];
                                   [DEFAULTS setInteger:count forKey:RCDChatroomDefalutHistoryMessageCountKey];
                               }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        tempTextField = textField;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showChatroomBindAlert {
    __block UITextField *txtChatroomID;
    __block UITextField *txtRtcRoomID;
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"聊天室绑定RTCRoom"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"OK")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                    NSString *chatroomID = txtChatroomID.text;
            NSString *rtcroomID = txtRtcRoomID.text;
            [self bindChatroom:chatroomID rtcRoom:rtcroomID];
                               }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = @"Chatroom ID";
        txtChatroomID = textField;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = @"RTC room ID";
        txtRtcRoomID = textField;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)bindChatroom:(NSString *)chatroomID rtcRoom:(NSString *)rtcroomID {
    __weak __typeof(self)weakSelf = self;
    [[RCChatRoomClient sharedChatRoomClient] bindChatRoom:chatroomID withRTCRoom:rtcroomID success:^{
        [weakSelf showTipsBy:@"绑定成功"];
    } error:^(RCErrorCode nErrorCode) {
        NSString *text =[NSString stringWithFormat:@"绑定失败: %ld", (long)nErrorCode];
        [weakSelf showTipsBy:text];
    }];
}

- (void)showTipsBy:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}

- (void)refreshNaviData {
    RCCoreClient *client = [RCCoreClient sharedCoreClient];
    if ([client respondsToSelector:@selector(refetchNavidataSuccess:failure:)]) {
        [client refetchNavidataSuccess:^{
            [self showTipsBy:@"刷新成功"];
        } failure:^(NSInteger errorCode, NSString *responseData, NSString *errorDescription) {
            [self showTipsBy:[NSString stringWithFormat:@"失败: %ld, %@", errorCode,errorDescription ]];
        }];
    } else {
        [self showTipsBy:@"不支持 navi 刷新"];
    }
}
-(void)showUMengDeviceInfoAlertController {
    __block NSString * deviceID =[UMConfigure deviceIDForIntegration];
    __block UITextField *tempTextField;
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"友盟设备信息"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        tempTextField = textField;
        tempTextField.text = deviceID;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)pushUltraGroupChatListVC {
    RCDDebugUltraGroupListController *vc = [[RCDDebugUltraGroupListController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCommonChatRoom {
    RCDDebugComChatListController *vc = [[RCDDebugComChatListController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToChatroomStatusVC {
    RCDDebugJoinChatroomViewController *vc = [[RCDDebugJoinChatroomViewController alloc] init];
    vc.title = @"加入聊天室";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToDiscussionVC{
    RCDDebugDiscussionController *vc = [[RCDDebugDiscussionController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToMessagePushConfigVC {
    RCDDebugMessagePushConfigController *vc = [[RCDDebugMessagePushConfigController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToChatListVC {
    RCDDebugChatListViewController *vc = [[RCDDebugChatListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 打包沙盒文件并发送
 */
- (void)copyAndSendFiles {
    //获取系统当前的时间戳
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [dat timeIntervalSince1970];
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:now];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.currentDateStr = [dateFormatter stringFromDate:detailDate];

    // Document目录
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentPath = [paths1 objectAtIndex:0];
    // Libaray目录
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    self.libraryPath = [paths2 objectAtIndex:0];

    self.createPath = [NSString stringWithFormat:@"%@/SealTalk%@", self.documentPath, self.currentDateStr];

    if (![FILEMANAGER
            fileExistsAtPath:
                self.createPath]) //判断createPath路径文件夹是否已存在，此处createPath为需要新建的文件夹的绝对路径
    {

        [FILEMANAGER createDirectoryAtPath:self.createPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil]; //创建文件夹
    }

    [self copySealTalkDataBase];
    [self copyLogFile];
    [self copySDKFileAndDB];
    [self copyPlistFile];
    [self zipAndSend];
    [self sendBlinkLog];
}

- (void)copySealTalkDataBase {
    // SealTalk数据库导出
    NSString *dataBasePath = [self.libraryPath
        stringByAppendingString:[NSString stringWithFormat:@"/Application Support/RongCloud/RongIMDemoDB%@",
                                                           [RCIM sharedRCIM].currentUserInfo.userId]];
    if ([FILEMANAGER fileExistsAtPath:dataBasePath]) {
        [FILEMANAGER copyItemAtPath:dataBasePath
                             toPath:[NSString stringWithFormat:@"%@/SealTalkDatabase", self.createPath]
                              error:nil];
    }
}

- (void)copyLogFile {
    // log导出
    NSArray *files = [FILEMANAGER contentsOfDirectoryAtPath:self.documentPath error:nil];
    for (NSString *file in files) {
        if ([file hasPrefix:@"rc"]) {
            NSString *logPath = [NSString stringWithFormat:@"%@/%@", self.documentPath, file];
            if ([FILEMANAGER fileExistsAtPath:logPath]) {
                [FILEMANAGER copyItemAtPath:logPath
                                     toPath:[NSString stringWithFormat:@"%@/%@", self.createPath, file]
                                      error:nil];
            }
        }
    }
}

- (void)copySDKFileAndDB {
    // SDK的文件和数据库导出
    NSString *filesPath =
        [self.libraryPath stringByAppendingString:[NSString stringWithFormat:@"/Application Support/RongCloud/%@/%@",
                                                                             [DEFAULTS valueForKey:RCDAppKeyKey],
                                                                             [RCIM sharedRCIM].currentUserInfo.userId]];
    if ([FILEMANAGER fileExistsAtPath:filesPath]) {
        NSArray *files = [FILEMANAGER contentsOfDirectoryAtPath:filesPath error:nil];
        for (NSString *file in files) {
            if (![file hasSuffix:@"bak"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", filesPath, file];
                if ([FILEMANAGER fileExistsAtPath:filePath]) {
                    [FILEMANAGER copyItemAtPath:filePath
                                         toPath:[NSString stringWithFormat:@"%@/%@", self.createPath, file]
                                          error:nil];
                }
            }
        }
    }
}

- (void)copyPlistFile {
    // plist文件导出
    NSString *plistFilePath = [self.libraryPath stringByAppendingString:@"/Preferences"];
    plistFilePath = [NSString stringWithFormat:@"%@/%@.plist", plistFilePath, [[NSBundle mainBundle] bundleIdentifier]];
    if ([FILEMANAGER fileExistsAtPath:plistFilePath]) {
        [FILEMANAGER copyItemAtPath:plistFilePath
                             toPath:[NSString stringWithFormat:@"%@/%@.plist", self.createPath,
                                                               [[NSBundle mainBundle] bundleIdentifier]]
                              error:nil];
    }
}

- (void)zipAndSend {
    NSString *zipFilePath = [NSString stringWithFormat:@"%@/SealTalk%@.zip", self.documentPath, self.currentDateStr];
    [SSZipArchive createZipFileAtPath:zipFilePath
              withContentsOfDirectory:self.createPath
                  keepParentDirectory:NO
                     compressionLevel:-1
                             password:nil
                                  AES:YES
                      progressHandler:nil];
    if ([FILEMANAGER fileExistsAtPath:zipFilePath]) {
        RCFileMessage *zipFileMessage = [RCFileMessage messageWithFile:zipFilePath];
        [[RCCoreClient sharedCoreClient] sendMediaMessage:ConversationType_PRIVATE
            targetId:[RCIM sharedRCIM].currentUserInfo.userId
            content:zipFileMessage
            pushContent:nil
            pushData:nil
            progress:^(int progress, long messageId) {
            }
            success:^(long messageId) {
                [FILEMANAGER removeItemAtPath:zipFilePath error:nil];
            }
            error:^(RCErrorCode errorCode, long messageId) {
            }
            cancel:^(long messageId){
            }];
    }
}

- (void)sendBlinkLog {
    // blink log
    NSString *blinkLogPath = [NSString stringWithFormat:@"%@/Blink", self.documentPath];
    BOOL isDir = YES;
    if ([FILEMANAGER fileExistsAtPath:blinkLogPath isDirectory:&isDir]) {
        NSArray *files = [FILEMANAGER contentsOfDirectoryAtPath:blinkLogPath error:nil];
        if (files.count >= 1) {
            NSString *zipFilePath =
                [NSString stringWithFormat:@"%@/BlinkLog_%@.zip", self.documentPath, self.currentDateStr];
            [SSZipArchive createZipFileAtPath:zipFilePath
                      withContentsOfDirectory:blinkLogPath
                          keepParentDirectory:NO
                             compressionLevel:-1
                                     password:nil
                                          AES:YES
                              progressHandler:nil];
            RCFileMessage *zipFileMessage = [RCFileMessage messageWithFile:zipFilePath];
            [[RCCoreClient sharedCoreClient] sendMediaMessage:ConversationType_PRIVATE
                targetId:[RCIM sharedRCIM].currentUserInfo.userId
                content:zipFileMessage
                pushContent:nil
                pushData:nil
                progress:^(int progress, long messageId) {
                }
                success:^(long messageId) {
                    [FILEMANAGER removeItemAtPath:zipFilePath error:nil];
                }
                error:^(RCErrorCode errorCode, long messageId) {
                }
                cancel:^(long messageId){
                }];
        }
    }
}

- (void)setPushLauguageCode {
    __block UITextField *tempTextField;
    NSString *lauguageCode = [DEFAULTS objectForKey:RCDCurrentPushLauguageCodeKey];
    NSString *message = [NSString stringWithFormat:@"当前推送语言为：%@", lauguageCode ?: @""];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置推送语言，例如 zh_CN、en_US、ar_SA" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        NSString *code = tempTextField.text;
        [DEFAULTS setObject:code forKey:RCDCurrentPushLauguageCodeKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
        [[[RCPushProfile alloc] init] setPushLauguageCode:code success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.view showHUDMessage:@"设置成功"];
            });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.view showHUDMessage:[NSString stringWithFormat:@"%@ %ld", RCDLocalizedString(@"Failed"), (long)status]];
            });
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        tempTextField = textField;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showCustomFileIcon {
    RCDDebugFileIconViewController *controller = [[RCDDebugFileIconViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
