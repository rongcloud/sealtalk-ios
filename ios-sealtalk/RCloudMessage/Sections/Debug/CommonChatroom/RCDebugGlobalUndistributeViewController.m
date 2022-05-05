//
//  RCDebugGlobalUndistributeViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDebugGlobalUndistributeViewController.h"


@interface RCDComLevelModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) RCPushNotificationQuietHoursLevel level;
@end
@implementation RCDComLevelModel

@end


@interface RCDebugGlobalUndistributeViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UITextField *startTimeTextField;
@property (nonatomic, strong) UITextField *durationTimeTextField;
@property (nonatomic, strong) UITextField *levelTextField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) UIPickerView *categoryPicker;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) RCDComLevelModel *currentLevel;
@property (nonatomic, strong) UILabel *infoLabel;
@end

@implementation RCDebugGlobalUndistributeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self querySettings];
}

- (void)setupViews {
    [self.view addSubview:self.self.infoLabel];
    [self.view addSubview:self.startTimeTextField];
    [self.view addSubview:self.durationTimeTextField];
    [self.view addSubview:self.levelTextField];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(80);
        make.left.mas_equalTo(self.view).mas_equalTo(16);
        make.right.mas_equalTo(self.view).mas_equalTo(-16);
        make.top.mas_equalTo(self.view).mas_offset(20);
    }];
    [self.startTimeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view).mas_equalTo(16);
        make.right.mas_equalTo(self.view).mas_equalTo(-16);
        make.top.mas_equalTo(self.infoLabel.mas_bottom).mas_offset(10);
    }];
    [self.durationTimeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view).mas_equalTo(16);
        make.right.mas_equalTo(self.view).mas_equalTo(-16);
        make.top.mas_equalTo(self.startTimeTextField.mas_bottom).mas_offset(10);
    }];
    [self.levelTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view).mas_equalTo(16);
        make.right.mas_equalTo(self.view).mas_equalTo(-16);
        make.top.mas_equalTo(self.durationTimeTextField.mas_bottom).mas_offset(10);
    }];
    UIBarButtonItem *barItems =[[UIBarButtonItem alloc] initWithTitle:@"提交"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(confirmBtnClick)];
    self.navigationItem.rightBarButtonItem = barItems;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.startTimeTextField resignFirstResponder];
    [self.durationTimeTextField resignFirstResponder];
    [self.levelTextField resignFirstResponder];
}

- (void)confirmBtnClick {
    [self showLoading];
    [self.startTimeTextField resignFirstResponder];
    [self.durationTimeTextField resignFirstResponder];
    [self.levelTextField resignFirstResponder];

    NSString *startTime = self.startTimeTextField.text;
    int spanMins = [self.durationTimeTextField.text intValue];
    int level = [self.levelTextField.text intValue];

    __weak typeof(self) ws = self;
    [[RCChannelClient sharedChannelManager] setNotificationQuietHoursLevel:startTime
                                                           spanMins:spanMins
                                                              level:(RCPushNotificationQuietHoursLevel)level
                                                            success:^() {
            [ws showAlert:YES];
      } error:^(RCErrorCode status) {
            [ws showAlert:NO];
      }];
}

- (void)showAlert:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadingFinished];
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
    });

}

- (void)querySettings {
    [[RCChannelClient sharedChannelManager] getNotificationQuietHoursLevel:^(NSString *startTime, int spanMins, RCPushNotificationQuietHoursLevel level) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startTimeTextField.text = startTime;
            if (spanMins != 0) {
                self.durationTimeTextField.text = [NSString stringWithFormat:@"%d", spanMins];
            }
            for (int i = 0; i<self.dataSource.count; i++) {
                RCDComLevelModel *model = self.dataSource[i];
                if (model.level == level) {
                    [self.categoryPicker selectRow:i inComponent:0 animated:NO];
                    self.currentLevel = model;
                    self.levelTextField.text = model.title;
                    break;
                }
            }
          });
      } error:^(RCErrorCode status) {
      }];
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
    RCDComLevelModel *model = self.dataSource[row];
    return  model.title;;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    RCDComLevelModel *model = self.dataSource[row];
    self.currentLevel = model;
    self.levelTextField.text = model.title;
}

#pragma mark - datePickerValueChanged
- (void)datePickerChanged:(UIDatePicker *)picker {
    self.startTimeTextField.text = [self.formatter stringFromDate:picker.date];
}

- (UITextField *)startTimeTextField {
    if (!_startTimeTextField) {
        _startTimeTextField = [UITextField new];
        _startTimeTextField.backgroundColor = [UIColor blackColor];
        _startTimeTextField.inputView = self.datePicker;
        _startTimeTextField.textColor = [UIColor redColor];

    }
    return _startTimeTextField;
}

- (UITextField *)levelTextField {
    if (!_levelTextField) {
        _levelTextField = [UITextField new];
        _levelTextField.backgroundColor = [UIColor blackColor];
        _levelTextField.inputView = self.categoryPicker;
        _levelTextField.textColor = [UIColor redColor];

    }
    return _levelTextField;
}

- (UITextField *)durationTimeTextField {
    if (!_durationTimeTextField) {
        _durationTimeTextField = [UITextField new];
        _durationTimeTextField.backgroundColor = [UIColor blackColor];
        _durationTimeTextField.textColor = [UIColor redColor];
        _durationTimeTextField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _durationTimeTextField;
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
        _formatter = formatter;
    }
    return _formatter;
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

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker setDate:[NSDate date]];
        [_datePicker addTarget:self
                        action:@selector(datePickerChanged:)
              forControlEvents:UIControlEventValueChanged];
        _datePicker.datePickerMode = UIDatePickerModeTime;
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
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

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray *array = [NSMutableArray array];
        RCDComLevelModel *model = [RCDComLevelModel new];
        model.level = RCPushNotificationQuietHoursLevelDefault;
        model.title = @"0: 未设置（向上查询群或者APP级别设置）";
        [array addObject:model];
        
        model = [RCDComLevelModel new];
        model.level = RCPushNotificationQuietHoursLevelMention;
        model.title = @"1:  群聊超级群仅@消息通知，单聊代表消息不通知";
        [array addObject:model];
        
        model = [RCDComLevelModel new];
        model.level = RCPushNotificationQuietHoursLevelBlocked;
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
