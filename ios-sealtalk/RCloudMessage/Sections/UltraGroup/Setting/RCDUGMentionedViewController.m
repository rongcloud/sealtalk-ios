//
//  RCDUGMentionedViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/8/3.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUGMentionedViewController.h"
#import "RCDMentionedView.h"
#import "RCDUGSelectListViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "UIView+MBProgressHUD.h"
#import "RCDUserInfoManager.h"
#import "RCDMessageDigestCell.h"

@interface RCDDigestDetail : NSObject
@property (nonatomic, copy) NSString *userInfo;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *messageID;
@end

@implementation RCDDigestDetail

@end
@interface RCDUGMentionedViewController()<UITableViewDelegate, UITableViewDataSource, RCDUGSelectListViewControllerDelegate>
@property (nonatomic, strong) RCDMentionedView *mentionedView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIBarButtonItem *btnConversation;
@property (nonatomic, strong) UIBarButtonItem *btnFlip;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSDate *date;
@end


@implementation RCDUGMentionedViewController


- (void)loadView {
    self.view = self.mentionedView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

#pragma mark - Private

- (void)ready {
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(back)];
    self.navigationItem.leftBarButtonItem = btn;
    
    UIBarButtonItem *btnConversation = [[UIBarButtonItem alloc] initWithTitle:@"会话"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                                       action:@selector(btnConversationClick:)];
    self.navigationItem.rightBarButtonItem = btnConversation;
    self.btnConversation = btnConversation;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnConversationClick:(id)sender {
    RCDUGSelectListViewController *vc = [RCDUGSelectListViewController new];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)stringBy:(RCErrorCode)code {
    NSString *msg = @"请求失败";
    switch (code) {
        case -1:
            msg = @"请求结束";
            break;
        case INVALID_PARAMETER_TARGETID:
            msg = @"非法的 targetID";
            break;
        case INVALID_PARAMETER_CHANNELID:
            msg = @"非法的 channelID";
            break;
        case INVALID_PARAMETER_COUNT:
            msg = @"数量(count)非法";
            break;
        case INVALID_PARAMETER_SEND_TIME:
            msg = @"消息发送时间(sendTime)非法";
            break;
        default:
            break;
    }
    return msg;
}
- (void)showErrorWith:(RCErrorCode)code funcString:(NSString *)funcString {
    NSString *msg = [self stringBy:code];
    msg = [NSString stringWithFormat:@"%@[%ld]: %@", funcString, (long)code, msg];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view hideLoading];
        [self.view showHUDMessage:msg];
    });
}

- (void)queryTest {
    [self.view showLoading];
    [self.mentionedView cleanTips];
    NSString *targetID = self.mentionedView.txtTargetID.text;
    NSString *channelID = self.mentionedView.txtChannelID.text;
    NSTimeInterval time = [self.date timeIntervalSince1970];
    NSInteger count = [self.mentionedView.txtCount.text intValue];
    RCHistoryMessageOption *opt = [RCHistoryMessageOption new];
    opt.recordTime = time;
    opt.count = count;
    opt.order = RCHistoryMessageOrderAsc;
    
    [[RCChannelClient sharedChannelManager] getMessages:ConversationType_ULTRAGROUP
                                               targetId:targetID
                                              channelId:channelID
                                                 option:opt
                                               complete:^(NSArray<RCMessage *> * _Nullable messages, long long timestamp, BOOL isRemaining, RCErrorCode code) {
        [self.mentionedView showTips:[NSString stringWithFormat:@"拉取 %ld 条消息", (long)messages.count]];
        [self fillDataSourceWith:messages];
    } error:^(RCErrorCode status) {
        [self showErrorWith:status funcString:@"获取远端消息"];
    }];
}
- (void)query {
    [self.view showLoading];
    [self.mentionedView cleanTips];
    NSString *targetID = self.mentionedView.txtTargetID.text;
    NSString *channelID = self.mentionedView.txtChannelID.text;
    NSTimeInterval time = [self.date timeIntervalSince1970]*1000;
    NSInteger count = [self.mentionedView.txtCount.text intValue];
    [[RCChannelClient sharedChannelManager] getUltraGroupUnreadMentionedDigests:targetID
                                                                      channelId:channelID
                                                                       sendTime:time
                                                                          count:count
                                                                        success:^(NSArray<RCMessageDigestInfo *> * _Nonnull digests) {
        if (digests.count) {
            [self fetchMessageDetailBy:digests];
        } else {
            [self showErrorWith:-1 funcString:@"没有摘要数据"];
        }
    }
                                                                          error:^(RCErrorCode status) {
        [self showErrorWith:status funcString:@"获取摘要"];
        }];
}

- (void)fetchMessageDetailBy:(NSArray<RCMessageDigestInfo *> *)digests {
    NSInteger count = digests.count;
    [self.mentionedView showTips:[NSString stringWithFormat:@"拉取 %ld 条 摘要", (long)count]];
    NSMutableArray *messages = [NSMutableArray array];
    //[每个消息对象需包含ConversationType,targetId,channelId, messageUid,sentTime]
    for (RCMessageDigestInfo *digest in digests) {
        RCMessage *msg = [[RCMessage alloc] init];
        msg.conversationType = digest.conversationType;
        msg.targetId = digest.targetId;
        msg.channelId = digest.channelId;
        msg.sentTime = digest.sentTime;
        msg.messageUId = digest.messageUid;
        [messages addObject:msg];
    }
    [self.mentionedView showTips:[NSString stringWithFormat:@"待拉取 %ld 条 消息", (long)count]];
    [[RCChannelClient sharedChannelManager] getBatchRemoteUltraGroupMessages:messages
                                                                     success:^(NSArray<RCMessage *> * _Nonnull matchedMsgList, NSArray<RCMessage *> * _Nonnull notMatchMsgList) {
        [self.mentionedView showTips:[NSString stringWithFormat:@"拉取 %ld 条消息, 未匹配消息 %ld 条", (long)matchedMsgList.count, notMatchMsgList.count]];
        [self fillDataSourceWith:matchedMsgList];
    } error:^(RCErrorCode status) {
        [self showErrorWith:status funcString:@"获取消息"];
    }];
}

- (void)fillDataSourceWith:(NSArray<RCMessage *> *)messages {
    NSMutableArray *array = [NSMutableArray array];
    for (RCMessage *msg in messages) {
        RCDDigestDetail *detail = [RCDDigestDetail new];
        detail.messageID = msg.messageUId;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:msg.sentTime/1000];
        detail.time = [self.formatter stringFromDate:date];;
        if ([msg.content isKindOfClass:[RCTextMessage class]]) {
            RCTextMessage *content = (RCTextMessage *)msg.content;
            detail.content = content.content;
        } else {
            detail.content = NSStringFromClass([msg.content class]);
        }
        RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:msg.senderUserId];
        detail.userInfo = userInfo.name;
        [array addObject:detail];
    }
    self.dataSource = array;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view hideLoading];
        [self showResult];
    });
}

- (void)showResult {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.btnFlip) {
            self.btnFlip = [[UIBarButtonItem alloc] initWithTitle:@"翻转"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(flip)];
        }
        self.navigationItem.rightBarButtonItem = self.btnFlip;;
        [self.mentionedView showResult:YES];
        [self.mentionedView.tableView reloadData];
    });
}

- (void)flip {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItem = self.btnConversation;
        [self.mentionedView showResult:NO];
        
    });
}

#pragma mark - datePickerValueChanged

- (void)datePickerChanged:(UIDatePicker *)picker {
    self.date = picker.date;
    self.mentionedView.txtTime.text = [self.formatter stringFromDate:picker.date];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDDigestDetail *digest = self.dataSource[indexPath.row];
    RCDMessageDigestCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDMessageDigestCellIdentifier forIndexPath:indexPath];
    cell.labUser.text = digest.userInfo;
    cell.labTime.text = digest.time;
    cell.labContent.text = digest.content;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - RCDUGSelectListViewControllerDelegate

- (void)userDidSelected:(NSString *)conversationName
               targetID:(NSString *)targetID
            channelName:(NSString *)channelName
              channelID:(NSString *)channelID {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = [NSString stringWithFormat:@"%@ - %@", conversationName, channelName];
        self.mentionedView.txtTargetID.text = targetID;
        self.mentionedView.txtChannelID.text = channelID;
        self.mentionedView.txtTime.text = @"0";
    });
}

- (RCDMentionedView *)mentionedView {
    if (!_mentionedView) {
        _mentionedView = [RCDMentionedView new];
        _mentionedView.tableView.delegate = self;
        _mentionedView.tableView.dataSource = self;
        [_mentionedView.btnQuery addTarget:self
                                    action:@selector(query)
                          forControlEvents:UIControlEventTouchUpInside];
        _mentionedView.txtTime.inputView = self.datePicker;
        [_mentionedView.tableView registerClass:[RCDMessageDigestCell class]
                         forCellReuseIdentifier:RCDMessageDigestCellIdentifier];
    }
    return _mentionedView;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker addTarget:self
                        action:@selector(datePickerChanged:)
              forControlEvents:UIControlEventValueChanged];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"cn_ZH"];
        [_datePicker setDate:[NSDate date] animated:YES];
        _datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT+8"];
        if(@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            CGFloat width = [[UIScreen mainScreen] bounds].size.width;
            _datePicker.frame = CGRectMake(0, 0, width, 320);
        }
    }
    return _datePicker;
}
- (NSDateFormatter *)formatter {
    if (!_formatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        _formatter = formatter;
    }
    return _formatter;
}

@end
