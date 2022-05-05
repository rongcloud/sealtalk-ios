//
//  RCDDebugConversationChannelNotificationLevelViewController.m
//  SealTalk
//
//  Created by jiangchunyu on 2022/2/25.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDDebugConversationChannelNotificationLevelViewController.h"

#import <RongIMKit/RCAlertView.h>

@interface RCDDebugConversationChannelNotificationLevelViewController ()

@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UITextField *levelTextField;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UILabel *infoLabel;
@end

@implementation RCDDebugConversationChannelNotificationLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor lightGrayColor]];

    [self.view addSubview:self.noteLabel];
    [self.view addSubview:self.levelTextField];
    [self.view addSubview:self.confirmBtn];
    [self.view addSubview:self.infoLabel];
}

- (void)confirm {
    [self.levelTextField resignFirstResponder];
    self.confirmBtn.userInteractionEnabled = NO;
    [self.confirmBtn setTitle:@"请求中..." forState:UIControlStateNormal];

    RCPushNotificationLevel level = (RCPushNotificationLevel)[self.levelTextField.text integerValue];
    __weak typeof(self) ws = self;
    if (self.settingType == RCDUltraGroupSettingTypeConversationChannel) {
        [[RCChannelClient sharedChannelManager] setConversationChannelNotificationLevel:self.type
                                                                               targetId:self.targetId
                                                                              channelId:self.channelId
                                                                                  level:level
                                                                                success:^() {
            [ws showSuccess];
        } error:^(RCErrorCode nErrorCode) {
            [ws showFailedWith:nErrorCode];
        }];
    } else if (self.settingType == RCDUltraGroupSettingTypeConversation) {
        [[RCChannelClient sharedChannelManager] setConversationNotificationLevel:self.type
                                                                        targetId:self.targetId
                                                                           level:level
                                                                         success:^() {
            [ws showSuccess];
        } error:^(RCErrorCode nErrorCode) {
            [ws showFailedWith:nErrorCode];
        }];
    } else if (self.settingType == RCDUltraGroupSettingTypeConversationType) {
        [[RCChannelClient sharedChannelManager] setConversationTypeNotificationLevel:self.type
                                                                               level:level
                                                                             success:^() {
            [ws showSuccess];
        } error:^(RCErrorCode nErrorCode) {
            [ws showFailedWith:nErrorCode];
        }];
    } else if(self.settingType == RCDUltraGroupSettingTypeConversationDefault) {
        [[RCChannelClient sharedChannelManager] setUltraGroupConversationDefaultNotificationLevel:self.targetId
                                                                                            level:level
                                                                                          success:^{
            [ws showSuccess];
        } error:^(RCErrorCode status) {
            [ws showFailedWith:status];
        }];
    } else if(self.settingType == RCDUltraGroupSettingTypeConversationChannelDefault) {
        [[RCChannelClient sharedChannelManager] setUltraGroupConversationChannelDefaultNotificationLevel:self.targetId
                                                                                               channelId:self.channelId
                                                                                                   level:level
                                                                                                 success:^{
            [ws showSuccess];
        } error:^(RCErrorCode status) {
            [ws showFailedWith:status];
        }];
    }
}

- (NSString *)functionString {
    NSString *string = @"";
    switch (self.settingType) {
        case RCDUltraGroupSettingTypeConversationChannel:
            string = @"3.1 设置 -> 频道免打扰设置";
            break;
        case RCDUltraGroupSettingTypeConversation:
            string = @"4.1 设置 -> 会话免打扰设置";
            break;
        case RCDUltraGroupSettingTypeConversationType:
            string = @"5.1 设置 -> 会话类型免打扰设置";
            break;
        case RCDUltraGroupSettingTypeConversationDefault:
            string = @"6.1.1 设置指定超级群默认通知配置";
            break;
        case RCDUltraGroupSettingTypeConversationChannelDefault:
            string = @"6.2.1 设置指定超级群特定频道默认通知配置";
            break;
        default:
            break;
    }
    return string;
}

- (void)showFailedWith:(NSInteger)code {
    NSString *content = RCDLocalizedString(@"set_fail");
    content = [NSString stringWithFormat:@"%@  : %@(%ld)", [self functionString], content, (long)code];
    [self showAlertWith:content];
}

- (void)showSuccess {
    NSString *content = RCDLocalizedString(@"setting_success");
    content = [NSString stringWithFormat:@"%@ : %@", [self functionString], content];
    [self showAlertWith:content];
}

- (void)showAlertWith:(NSString *)content {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = RCDLocalizedString(@"alert");
        [RCAlertView showAlertController:title
                                 message:content
                            actionTitles:nil cancelTitle:nil
                            confirmTitle:RCDLocalizedString(@"confirm")
                          preferredStyle:(UIAlertControllerStyleAlert)
                            actionsBlock:nil
                             cancelBlock:nil
                            confirmBlock:^{
//            [self.navigationController popViewControllerAnimated:YES];
            self.confirmBtn.userInteractionEnabled = YES;
            [self.confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        }
                        inViewController:self];
        
    });
}

#pragma mark - getter

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(10, 310, self.view.bounds.size.width - 10, 150)];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.textColor = [UIColor blackColor];
        _infoLabel.numberOfLines = 0;
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        NSString *info = [NSString stringWithFormat:@" TargetID : %@ \n ChannelId : %@ \n Type : %lu \n", self.targetId ?: @"None", self.channelId ?: @"None", (unsigned long)self.type];
        _infoLabel.text = info;
        
    }
    return _infoLabel;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width - 10, 150)];
        _noteLabel.textAlignment = NSTextAlignmentCenter;
        _noteLabel.textColor = [UIColor blackColor];
        _noteLabel.numberOfLines = 0;
        _noteLabel.text =
          @"level合法值有-1（全部消息通知）、0（未设置）、1（群聊超级群仅@消息通知（现在通知）单聊代表全部消息通知）、2（指定用户通知）、4（群全员通知）、5（消息通知被屏蔽，即不接收消息通知）";
    }
    return _noteLabel;
}

- (UITextField *)levelTextField {
    if (!_levelTextField) {
        _levelTextField =
            [[UITextField alloc] initWithFrame:CGRectMake(50, 150, self.view.bounds.size.width - 100, 50)];
        [_levelTextField setFont:[UIFont systemFontOfSize:13]];
        _levelTextField.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _levelTextField;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn =
            [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) / 2, 250, 100, 50)];
        [_confirmBtn setTitle:RCDLocalizedString(@"confirm") forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = [UIColor blueColor];
        [_confirmBtn addTarget:self 
                        action:@selector(confirm) 
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

@end
