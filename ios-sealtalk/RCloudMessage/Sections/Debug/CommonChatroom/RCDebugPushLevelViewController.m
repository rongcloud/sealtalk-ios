//
//  RCDebugPushLevelViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDebugPushLevelViewController.h"

@interface RCDComPushLevelModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) RCPushNotificationLevel level;
@end
@implementation RCDComPushLevelModel

@end

@interface RCDebugPushLevelViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UITextField *levelTextField;

@property (nonatomic, strong) UIPickerView *categoryPicker;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) RCDComPushLevelModel *currentLevel;
@property (nonatomic, strong) UILabel *infoLabel;
@end

@implementation RCDebugPushLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self functionString];
    [self setupViews];
    [self.categoryPicker selectRow:0 inComponent:0 animated:NO];
    self.currentLevel = self.dataSource[0];
    self.levelTextField.text = self.currentLevel.title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self querySettings];
}

- (void)setupViews {
    [self.view addSubview:self.self.infoLabel];;
    [self.view addSubview:self.levelTextField];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(80);
        make.left.mas_equalTo(self.view).mas_equalTo(16);
        make.right.mas_equalTo(self.view).mas_equalTo(-16);
        make.top.mas_equalTo(self.view).mas_offset(20);
    }];
    
    [self.levelTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view).mas_equalTo(16);
        make.right.mas_equalTo(self.view).mas_equalTo(-16);
        make.top.mas_equalTo(self.infoLabel.mas_bottom).mas_offset(10);
    }];
    UIBarButtonItem *barItems =[[UIBarButtonItem alloc] initWithTitle:@"提交"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(confirmBtnClick)];
    self.navigationItem.rightBarButtonItem = barItems;

}

- (NSString *)functionString {
    NSString *string = @"";
    switch (self.category) {
        case RCDComChatroomOptionCategory3_1:
            string = @"3.1 设置 -> 频道免打扰设置";
            break;
        case RCDComChatroomOptionCategory4_1:
            string = @"4.1 设置 -> 会话免打扰设置";
            break;
        case RCDComChatroomOptionCategory5_1:
            string = @"5.1 设置 -> 会话类型免打扰设置";
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
        [self loadingFinished];
        NSString *title = RCDLocalizedString(@"alert");
        [RCAlertView showAlertController:title
                                 message:content
                            actionTitles:nil cancelTitle:nil
                            confirmTitle:RCDLocalizedString(@"confirm")
                          preferredStyle:(UIAlertControllerStyleAlert)
                            actionsBlock:nil
                             cancelBlock:nil
                            confirmBlock:^{
        }
                        inViewController:self];
        
    });
}

- (void)confirmBtnClick {
    [self.levelTextField resignFirstResponder];
    [self showLoading];
    __weak __typeof(self)ws = self;

    switch (self.category) {
        case RCDComChatroomOptionCategory3_1: {
            [[RCChannelClient sharedChannelManager] setConversationChannelNotificationLevel:self.type
                                                                                   targetId:self.targetId
                                                                                  channelId:self.channelId
                                                                                      level:self.currentLevel.level
                                                                                    success:^() {
                [ws showSuccess];
            } error:^(RCErrorCode nErrorCode) {
                [ws showFailedWith:nErrorCode];
            }];
            break;
        }
        case RCDComChatroomOptionCategory4_1: {
            [[RCChannelClient sharedChannelManager] setConversationNotificationLevel:self.type
                                                                            targetId:self.targetId
                                                                               level:self.currentLevel.level
                                                                             success:^() {
                [ws showSuccess];
            } error:^(RCErrorCode nErrorCode) {
                [ws showFailedWith:nErrorCode];
            }];
            break;
        }
        case RCDComChatroomOptionCategory5_1: {
            [[RCChannelClient sharedChannelManager] setConversationTypeNotificationLevel:self.type
                                                                                   level:self.currentLevel.level
                                                                                 success:^() {
                [ws showSuccess];
            } error:^(RCErrorCode nErrorCode) {
                [ws showFailedWith:nErrorCode];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.levelTextField resignFirstResponder];
}


- (void)showAlert:(BOOL)success {
    NSString *title = RCDLocalizedString(@"setting_success");
    if (!success) {
        title = RCDLocalizedString(@"set_fail");
    }
    [RCAlertView showAlertController:title
                             message:@""
                        actionTitles:nil cancelTitle:nil
                        confirmTitle:RCDLocalizedString(@"confirm")
                      preferredStyle:(UIAlertControllerStyleAlert)
                        actionsBlock:nil
                         cancelBlock:nil
                        confirmBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }
    inViewController:self];
}

- (void)querySettings {
   
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSource.count;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component  {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    return width;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60;;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView
                      titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    RCDComPushLevelModel *model = self.dataSource[row];
    return  model.title;;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    RCDComPushLevelModel *model = self.dataSource[row];
    self.currentLevel = model;
    self.levelTextField.text = model.title;
}

#pragma mark - datePickerValueChanged


- (UITextField *)levelTextField {
    if (!_levelTextField) {
        _levelTextField = [UITextField new];
        _levelTextField.backgroundColor = [UIColor blackColor];
        _levelTextField.textColor = [UIColor redColor];

        _levelTextField.inputView = self.categoryPicker;
    }
    return _levelTextField;
}


- (UIPickerView *)categoryPicker {
    if (!_categoryPicker) {
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        _categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, width, 360)];
        _categoryPicker.delegate = self;
        _categoryPicker.dataSource = self;
    }
    return _categoryPicker;
}


- (NSArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray *array = [NSMutableArray array];
        RCDComPushLevelModel *model = [RCDComPushLevelModel new];
        model.level = RCPushNotificationLevelAllMessage;
        model.title = @"-1: 全部消息通知（接收全部消息通知 -- 显示指定关闭免打扰功能）";
        [array addObject:model];
        
        model = [RCDComPushLevelModel new];
        model.level = RCPushNotificationLevelDefault;
        model.title = @"0: 未设置（向上查询群或者APP级别设置）";
        [array addObject:model];
        
        model = [RCDComPushLevelModel new];
        model.level = RCPushNotificationLevelMention;
        model.title = @"1: 群聊超级群仅@消息通知（现在通知）单聊代表全部消息通知";
        [array addObject:model];
        
        model = [RCDComPushLevelModel new];
        model.level = RCPushNotificationLevelMentionUsers;
        model.title = @"2: 指定用户通知";
        [array addObject:model];
        
        model = [RCDComPushLevelModel new];
        model.level = RCPushNotificationLevelMentionAll;
        model.title = @"4: 群全员通知";
        [array addObject:model];
        
        model = [RCDComPushLevelModel new];
        model.level = RCPushNotificationLevelBlocked;
        model.title = @"5: 消息通知被屏蔽，即不接收消息通知";
        [array addObject:model];
        
        _dataSource = array;
    }
    return _dataSource;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [UILabel new];
        _infoLabel.numberOfLines = 0;
        NSString *msg = [NSString stringWithFormat:@"TargetID:  %@ \nType:  %lu \nChannelID:  %@", self.targetId, (unsigned long)self.type,self.channelId];
        _infoLabel.text = msg;
    }
    return _infoLabel;
}
@end
