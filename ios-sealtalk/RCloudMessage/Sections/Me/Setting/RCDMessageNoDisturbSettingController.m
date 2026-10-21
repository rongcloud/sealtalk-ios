//
//  RCDMessageNoDisturbSettingController.m
//  RCloudMessage
//
//  Created by 张改红 on 15/7/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDMessageNoDisturbSettingController.h"
#import "RCDBaseSettingTableViewCell.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDMessageNoDisturbSettingController ()
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, assign) BOOL displaySetting;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSIndexPath *startIndexPath;
@property (nonatomic, strong) NSIndexPath *endIndexPath;
@end

@implementation RCDMessageNoDisturbSettingController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"Do_not_disturb_setting");

    [self configTableView];

    self.startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    self.endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
    [self.swch setFrame:CGRectMake(self.view.frame.size.width - self.swch.frame.size.width - 15, 6, 0, 0)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.swch.on) {
        if (self.startTime.length == 0 || self.endTime.length == 0) {
            return;
        }
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:self.startTime];
        NSDate *endDate = [formatterE dateFromString:self.endTime];
        double timeDiff = [endDate timeIntervalSinceDate:startDate];
        if (timeDiff < 0) {
            startDate = [NSDate dateWithTimeInterval:-24 * 60 * 60 sinceDate:startDate];
            timeDiff = [endDate timeIntervalSinceDate:startDate];
        }

        int timeDif = timeDiff / 60;
        RCNotificationQuietHoursSetting *setting = [RCNotificationQuietHoursSetting new];
        setting.timezone = [NSTimeZone localTimeZone].name;
        setting.startTime = self.startTime;
        setting.spanMins = timeDif;
        setting.level = RCPushNotificationQuietHoursLevelMention;
        NSLog(@"zgh timezone: %@, startTime:%@",setting.timezone, setting.startTime);
        [[RCChannelClient sharedChannelManager] setNotificationQuietHoursWithSetting:setting success:^{
                [DEFAULTS
                    setObject:self.startTime
                       forKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
                [DEFAULTS
                    setObject:self.endTime
                       forKey:[NSString stringWithFormat:@"endTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
            }
            error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlert:RCDLocalizedString(@"alert")
                               message:RCDLocalizedString(@"set_fail")
                        cancelBtnTitle:RCDLocalizedString(@"cancel")];
                });
            }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNoDisturbStaus];
}

- (void)getNoDisturbStaus {
    [[RCCoreClient sharedCoreClient] getNotificationQuietHours:^(NSString *startTime, int spanMins) {
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:startTime];
        NSDate *endDate = [startDate dateByAddingTimeInterval:60 * spanMins];
        NSString *endTime = [formatterE stringFromDate:endDate];
        if (spanMins > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.startTime = startTime;
                self.endTime = endTime;
                [self reloadList:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateUIAtErrorStatus];
            });
        }
    }
        error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateUIAtErrorStatus];
            });
        }];
}

- (void)setQuietHours {
    NSDateFormatter *formatterF = [[NSDateFormatter alloc] init];
    [formatterF setDateFormat:@"HH:mm:ss"];
    NSDate *startDate = [formatterF dateFromString:self.startTime];
    NSDate *endDate = [formatterF dateFromString:self.endTime];

    double timeDiff = [endDate timeIntervalSinceDate:startDate];
    NSDate *laterTime = [startDate laterDate:endDate];
    //开始时间大于结束时间，跨天设置
    if ([laterTime isEqualToDate:startDate]) {
        NSDate *dayEndTime = [formatterF dateFromString:@"23:59:59"];
        NSDate *dayBeginTime = [formatterF dateFromString:@"00:00:00"];
        double timeDiff1 = [dayEndTime timeIntervalSinceDate:startDate];
        double timeDiff2 = [endDate timeIntervalSinceDate:dayBeginTime];
        timeDiff = timeDiff1 + timeDiff2;
    }

    int timeDif = timeDiff / 60;

    RCNotificationQuietHoursSetting *setting = [RCNotificationQuietHoursSetting new];
    setting.timezone = [NSTimeZone localTimeZone].name;
    setting.startTime = self.startTime;
    setting.spanMins = timeDif;
    setting.level = RCPushNotificationQuietHoursLevelMention;
    [[RCChannelClient sharedChannelManager] setNotificationQuietHoursWithSetting:setting success:^{

        }
        error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:RCDLocalizedString(@"alert")
                           message:RCDLocalizedString(@"set_fail")
                    cancelBtnTitle:RCDLocalizedString(@"cancel")];
                self.swch.on = NO;
                [self reloadList:NO];
            });
        }];
}

- (void)removeQuietHours {
    [[RCCoreClient sharedCoreClient] removeNotificationQuietHours:^{

    } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:RCDLocalizedString(@"alert")
                           message:RCDLocalizedString(@"shut_down_failed")
                    cancelBtnTitle:RCDLocalizedString(@"cancel")];
                self.swch.on = YES;
                [self reloadList:YES];
            });
        }];
}

- (void)updateQuietHoursIfNeed {
    if (self.swch.on) {
        [self setQuietHours];
    } else {
        [self removeQuietHours];
    }
}

- (void)updateUIAtErrorStatus {
    self.startTime =
        [DEFAULTS objectForKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
    self.endTime =
        [DEFAULTS objectForKey:[NSString stringWithFormat:@"endTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
    if (!self.startTime && !self.endTime) {
        self.startTime = @"23:00:00";
        self.endTime = @"07:00:00";
    }
    self.swch.on = NO;
    [self reloadList:NO];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.displaySetting) {
        if (self.indexPath) {
            return 3;
        } else {
            return 2;
        }
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 50;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        view.backgroundColor = self.tableView.backgroundColor;
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(12, -15, view.frame.size.width - 40, 50);
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor grayColor];
        label.text = RCDLocalizedString(@"mute_notifications_prompt");
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 44;
    }
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCellReuseIdentifier"];
    if (!cell) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }

    if (indexPath.section == 0) {
        [cell setCellStyle:SwitchStyle];
        cell.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                        darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
        cell.textLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.leftLabel.text  = RCDLocalizedString(@"Turn_on_message_do_not_disturb");
        [cell.switchButton addTarget:self action:@selector(setSwitchState:) forControlEvents:UIControlEventValueChanged];
        cell.switchButton.on = self.displaySetting;
        self.swch = cell.switchButton;
    } else if (indexPath.section == 1) {
        [cell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        if (indexPath.row == 0) {
            cell.leftLabel.text = RCDLocalizedString(@"Start_time");
            cell.rightLabel.text = self.startTime;
        } else {
            cell.leftLabel.text = RCDLocalizedString(@"end_time");
            cell.rightLabel.text = self.endTime;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        [cell setCellStyle:OnlyDisplayLeftLabelStyle];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.datePicker];
    }
    return cell;
}

#pragma mark - Table view Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        [self.tableView selectRowAtIndexPath:_indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        return;
    }
    self.indexPath = indexPath;
    RCDBaseSettingTableViewCell *cell = (RCDBaseSettingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    // 点击 cell 时 datePicker 滚动到相应的位置
    NSString *dateString = cell.rightLabel.text;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *date = [formatter dateFromString:dateString];
    [self.datePicker setDate:date];
    [self reloadList:self.displaySetting];
}

#pragma mark - datePickerValueChanged
- (void)datePickerValueChanged:(UIDatePicker *)datePicker {
    if (!_indexPath) {
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:datePicker.date];
    if (_indexPath.section == self.startIndexPath.section && _indexPath.row == self.startIndexPath.row) {
        self.startTime = currentDateStr;
    } else if (_indexPath.section == self.endIndexPath.section && _indexPath.row == self.endIndexPath.row) {
        self.endTime = currentDateStr;
    }
    [self reloadList:self.displaySetting];
}

#pragma mark - setSwitchState
- (void)setSwitchState:(UISwitch *)swich {
    [self reloadList:swich.on];
    [self updateQuietHoursIfNeed];
}

- (void)configTableView {
    self.tableView.scrollEnabled = NO;
    [self.tableView selectRowAtIndexPath:self.startIndexPath
                                animated:YES
                          scrollPosition:UITableViewScrollPositionMiddle];
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
}

- (void)showAlert:(NSString *)title
          message:(NSString *)message
   cancelBtnTitle:(NSString *)cBtnTitle {
    [RCAlertView showAlertController:title message:message cancelTitle:cBtnTitle inViewController:self];
}

- (void)reloadList:(BOOL)displaySetting {
    self.displaySetting = displaySetting;
    [self.tableView reloadData];
    if (self.displaySetting && self.indexPath) {
        [self.tableView selectRowAtIndexPath:self.indexPath animated:YES scrollPosition:(UITableViewScrollPositionNone)];
    }
}

#pragma mark - getter

- (UISwitch *)swch {
    if (!_swch) {
        _swch = [[UISwitch alloc] init];
        _swch.onTintColor = HEXCOLOR(0x0099ff);
    }
    return _swch;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {

        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSString *startTime = [DEFAULTS
            objectForKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
        if (startTime == nil) {
            startTime = @"23:00:00";
        }
        NSDate *startDate = [formatterE dateFromString:startTime];

        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        [_datePicker setDate:startDate];
        [_datePicker addTarget:self
                        action:@selector(datePickerValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}
@end
