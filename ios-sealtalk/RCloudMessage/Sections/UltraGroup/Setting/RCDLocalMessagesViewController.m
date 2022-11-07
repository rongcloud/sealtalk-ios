//
//  RCDLocalMessagesViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/9/23.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDLocalMessagesViewController.h"
#import "RCDLocalMessagesView.h"
#import "RCDAllConversationViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "UIView+MBProgressHUD.h"
#import "RCDUserInfoManager.h"
#import "RCDMessageDigestCell.h"

@interface RCDLocaMessageDigest : NSObject
@property (nonatomic, copy) NSString *userInfo;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *messageID;
@end

@implementation RCDLocaMessageDigest

@end

@interface RCDLocalMessagesViewController()<UITableViewDelegate, UITableViewDataSource, RCDConversationSelectorDelegate>
@property (nonatomic, strong) RCDLocalMessagesView *mentionedView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIBarButtonItem *btnConversation;
@property (nonatomic, strong) UIBarButtonItem *btnFlip;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) RCDConversationItem *currentItem;
@end

@implementation RCDLocalMessagesViewController


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
    RCDAllConversationViewController *vc = [RCDAllConversationViewController new];
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
        case INVALID_PARAMETER_MESSAGELIST:
            msg = @"数量或内容(count)非法";
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
    [self.mentionedView hideKeyboardIfNeed];
    [self fetchCommonMessageBy:self.currentItem];
}

- (void)fetchMessageDetailBy:(NSArray<RCMessage *> *)history {
    NSInteger count = history.count;
    [self.mentionedView showTips:[NSString stringWithFormat:@"拉取 %ld 条 历史消息", (long)count]];
    NSMutableArray *messageUIDs = [NSMutableArray array];
    //[每个消息对象需包含ConversationType,targetId,channelId, messageUid,sentTime]
    for (RCMessage *message in history) {
        [messageUIDs addObject:message.messageUId];
    }
    NSString *uid = self.mentionedView.txtMessageUID.text;
    if (uid.length > 0) {
        if ([uid isEqualToString:@"0"]) {
            [messageUIDs addObjectsFromArray:@[@"aa",@"bb",@(123456789)]];
        } else {
            NSArray *more = [uid componentsSeparatedByString:@","];
            [messageUIDs addObjectsFromArray:more];
        }
    }
    [self.mentionedView showTips:[NSString stringWithFormat:@"待拉取 %ld 条 消息", (long)messageUIDs.count]];
    NSString *targetID = self.mentionedView.txtTargetID.text;
    NSString *channelID = self.mentionedView.txtChannelID.text;
    [[RCChannelClient sharedChannelManager] getBatchLocalMessages:self.currentItem.type
                                                         targetId:targetID
                                                        channelId:channelID
                                                      messageUIDs:messageUIDs
                                                          success:^(NSArray<RCMessage *> * _Nonnull messages, NSArray<NSString *> * _Nonnull mismatch) {
        [self.mentionedView showTips:[NSString stringWithFormat:@"拉取 %ld 条消息, 未匹配消息 %ld 条", (long)messages.count, mismatch.count]];
        [self.mentionedView showTips:[NSString stringWithFormat:@"未匹配UID 消息: %@", [mismatch componentsJoinedByString:@"\n"]]];
        [self fillDataSourceWith:messages];
    } error:^(RCErrorCode status) {
        [self showErrorWith:status funcString:@"获取消息"];
        [self.mentionedView showTips:[NSString stringWithFormat:@"UID 消息: %@", [messageUIDs componentsJoinedByString:@"\n"]]];

    }];
     

}

- (void)fillDataSourceWith:(NSArray<RCMessage *> *)messages {
    NSMutableArray *array = [NSMutableArray array];
    for (RCMessage *msg in messages) {
        RCDLocaMessageDigest *detail = [RCDLocaMessageDigest new];
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

- (void)fetchCommonMessageBy:(RCDConversationItem *)conversation {
    NSTimeInterval time = [self.date timeIntervalSince1970]*1000;
    NSInteger count = [self.mentionedView.txtCount.text intValue];
    RCHistoryMessageOption *opt = [RCHistoryMessageOption new];
    opt.recordTime = time;
    opt.count = count;
    opt.order = RCHistoryMessageOrderDesc;
    if (conversation.type == ConversationType_ULTRAGROUP) {
        [[RCChannelClient sharedChannelManager] getMessages:conversation.type
                                                   targetId:conversation.targetID
                                                  channelId:conversation.channelID
                                                     option:opt
                                                   complete:^(NSArray *messages, RCErrorCode code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchMessageDetailBy:messages];
            });
        }];
    } else {
        [[RCCoreClient sharedCoreClient] getMessages:conversation.type
                                            targetId:conversation.targetID
                                              option:opt
                                            complete:^(NSArray *messages, RCErrorCode code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchMessageDetailBy:messages];
            });
        }];
    }
}
#pragma mark - datePickerValueChanged

- (void)datePickerChanged:(UIDatePicker *)picker {
    self.date = picker.date;
    self.mentionedView.txtTime.text = [self.formatter stringFromDate:picker.date];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDLocaMessageDigest *digest = self.dataSource[indexPath.row];
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

#pragma mark - Delegate

- (void)conversationDidSelected:(RCDConversationItem *)item;
 {
     self.currentItem = item;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = item.title;
        self.mentionedView.txtTargetID.text = item.targetID;
        self.mentionedView.txtChannelID.text = item.channelID;
        self.mentionedView.txtTime.text = @"0";
    });
}

- (RCDLocalMessagesView *)mentionedView {
    if (!_mentionedView) {
        _mentionedView = [RCDLocalMessagesView new];
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
