//
//  RCDDebugNotificationQuietHoursSettingViewController.m
//  SealTalk
//
//  Created by jiangchunyu on 2022/2/25.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDDebugNotificationQuietHoursSettingViewController.h"

#import <RongIMKit/RongIMKit.h>

@interface RCDDebugNotificationQuietHoursSettingViewController ()

@property (nonatomic, strong) UITextField *startTimeTextField;
@property (nonatomic, strong) UITextField *durationTimeTextField;
@property (nonatomic, strong) UITextField *levelTextField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation RCDDebugNotificationQuietHoursSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initSubviews];

    [[RCChannelClient sharedChannelManager] getNotificationQuietHoursLevel:^(NSString *startTime, int spanMins, RCPushNotificationQuietHoursLevel level) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startTimeTextField.text = startTime;
            self.durationTimeTextField.text = [NSString stringWithFormat:@"%d", spanMins];
            self.levelTextField.text = [NSString stringWithFormat:@"%d", level];
          });
      } error:^(RCErrorCode status) {
      }];
}

- (void)confirmButtonAction:(UIButton *)button {
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws showAlert:YES];
          });
      } error:^(RCErrorCode status) {
            [ws showAlert:NO];
      }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.startTimeTextField resignFirstResponder];
    [self.durationTimeTextField resignFirstResponder];
    [self.levelTextField resignFirstResponder];
}

#pragma mark - private method

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

- (void)initSubviews {
    [self.view setBackgroundColor:[UIColor lightGrayColor]];

    // start time label
    UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 130, 44)];
    startTimeLabel.text = RCDLocalizedString(@"Start_time1");
    [self.view addSubview:startTimeLabel];

    // start text field
    self.startTimeTextField =
        [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(startTimeLabel.frame), 100, 160, 44)];
    [self.startTimeTextField setBackgroundColor:[UIColor whiteColor]];
    [self.startTimeTextField setPlaceholder:@"HH:mm:ss"];
    NSAttributedString *attrString =
        [[NSAttributedString alloc] initWithString:self.startTimeTextField.placeholder
                                        attributes:@{
                                            NSForegroundColorAttributeName : HEXCOLOR(0x999999),
                                            NSFontAttributeName : self.startTimeTextField.font
                                        }];
    self.startTimeTextField.attributedPlaceholder = attrString;
    self.startTimeTextField.textColor = [UIColor redColor];
    self.startTimeTextField.inputView = self.datePicker;
    [self.view addSubview:self.startTimeTextField];

    // end time label
    UILabel *endTimeLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.startTimeTextField.frame) + 20, 130, 44)];
    endTimeLabel.text = RCDLocalizedString(@"continue_times");
    [self.view addSubview:endTimeLabel];

    // duration time text field
    self.durationTimeTextField = [[UITextField alloc]
        initWithFrame:CGRectMake(CGRectGetMaxX(endTimeLabel.frame), endTimeLabel.frame.origin.y, 160, 44)];
    [self.durationTimeTextField setBackgroundColor:[UIColor whiteColor]];
    self.durationTimeTextField.textColor = [UIColor redColor];
    [self.view addSubview:self.durationTimeTextField];

    // level label
    UILabel *levelLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.durationTimeTextField.frame) + 20, 130, 44)];
    levelLabel.text = RCDLocalizedString(@"level");
    [self.view addSubview:levelLabel];

    // level text field
    self.levelTextField = [[UITextField alloc]
        initWithFrame:CGRectMake(CGRectGetMaxX(levelLabel.frame), levelLabel.frame.origin.y, 160, 44)];
    [self.levelTextField setBackgroundColor:[UIColor whiteColor]];
    self.levelTextField.textColor = [UIColor redColor];
    [self.view addSubview:self.levelTextField];

    UILabel *noteLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.levelTextField.frame) + 20, 800, 44)];
    noteLabel.text = @"level合法值有-1: 全部消息通知, 0: 未设置, 5: 消息通知被屏蔽";
    [self.view addSubview:noteLabel];

    // confirm button
    UIButton *confirmButton =
        [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(noteLabel.frame) + 40,
                                                   self.view.bounds.size.width - 100, 44)];
    [confirmButton setTitle:RCDLocalizedString(@"confirm") forState:UIControlStateNormal];
    [confirmButton addTarget:self 
                      action:@selector(confirmButtonAction:) 
            forControlEvents:UIControlEventTouchUpInside];
    [confirmButton setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:confirmButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)datePickerChanged:(UIDatePicker *)picker {
    self.startTimeTextField.text = [self.formatter stringFromDate:picker.date];
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
        _formatter = formatter;
    }
    return _formatter;
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
@end
