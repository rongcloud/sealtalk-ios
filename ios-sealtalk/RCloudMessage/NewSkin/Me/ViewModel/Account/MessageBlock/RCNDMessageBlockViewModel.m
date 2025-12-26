//
//  RCNDMessageBlockViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMessageBlockViewModel.h"
#import "RCNDCommonCellViewModel.h"
#import "RCNDSwitchCellViewModel.h"

@interface RCNDMessageBlockViewModel()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *timeDuration;
@property (nonatomic, strong) RCNDCommonCellViewModel *beginVM;
@property (nonatomic, strong) RCNDCommonCellViewModel *endVM;
@property (nonatomic, strong) RCNDSwitchCellViewModel *blockVM;
@property (nonatomic, strong) RCNDCommonCellViewModel *currentTimeVM;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation RCNDMessageBlockViewModel

- (void)ready {
    [super ready];
    self.dataSource = [NSMutableArray array];
    self.timeDuration = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    RCNDSwitchCellViewModel *blockVM = [[RCNDSwitchCellViewModel alloc] initWithSwitchOn:YES switchBlock:^(BOOL switchOn, RCNDSwitchCellViewModelInnerBoolBlock  _Nullable innerBlock) {
        [weakSelf updateQuietHours:switchOn completion:^(BOOL ret) {
            if (innerBlock) {
                innerBlock(ret);
            }
            [weakSelf reloadData];
        }];
    }];
    blockVM.title = RCDLocalizedString(@"mute_notifications");
    self.blockVM = blockVM;
    [self.dataSource addObject:@[blockVM]];
    
    RCNDCommonCellViewModel *start = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        [weakSelf timeViewModelTouched:YES];

    }];
    start.title = RCDLocalizedString(@"Start_time");
    start.subtitle = @"00:00:000";
    self.beginVM = start;
    
    RCNDCommonCellViewModel *end = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        [weakSelf timeViewModelTouched:NO];
    }];
    end.title = RCDLocalizedString(@"end_time");
    end.subtitle = @"00:00:000";
    self.endVM = end;
    
    [self.timeDuration addObject:start];
    [self.timeDuration addObject:end];
}


- (void)timeViewModelTouched:(BOOL)isBeginTime {
    if (isBeginTime) {
        self.currentTimeVM = self.beginVM;
    } else {
        self.currentTimeVM = self.endVM;
    }
    if ([self.dateDelegate respondsToSelector:@selector(showDatePicker:)]) {
        NSString *startTime = self.currentTimeVM.subtitle;
        NSDate *date = [self.formatter dateFromString:startTime];
        [self.dateDelegate showDatePicker:date];
    }
}

- (void)fetchAllData {
    [[RCCoreClient sharedCoreClient] getNotificationQuietHours:^(NSString *startTime, int spanMins) {
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        NSDate *startDate = [formatterE dateFromString:startTime];
        NSDate *endDate = [startDate dateByAddingTimeInterval:60 * spanMins];
        NSString *endTime = [formatterE stringFromDate:endDate];
        if (spanMins > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.beginVM.subtitle = startTime;
                self.endVM.subtitle = endTime;
                self.blockVM.switchOn = YES;
                [self reloadData];
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

- (void)updateUIAtErrorStatus {
    NSString *startTime =
    [DEFAULTS objectForKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
    NSString *endTime =
    [DEFAULTS objectForKey:[NSString stringWithFormat:@"endTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
    if (!startTime && !endTime) {
        startTime = @"23:00:00";
        endTime = @"07:00:00";
    }
    self.beginVM.subtitle = startTime;
    self.endVM.subtitle = endTime;
    self.blockVM.switchOn = NO;
    [self reloadData];
}


- (void)reloadData {
    if (self.blockVM.switchOn) {
        if (![self.dataSource containsObject:self.timeDuration]) {
            [self.dataSource addObject:self.timeDuration];
        }
    } else {
        [self.dataSource removeObject:self.timeDuration];
    }
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self removeSeparatorLineIfNeed:self.dataSource];
        [self.delegate reloadData:NO];
    }
}


- (void)configureQuietHours:(void(^)(BOOL ret))completion {
    NSDateFormatter *formatterF = [[NSDateFormatter alloc] init];
    [formatterF setDateFormat:@"HH:mm:ss"];
    NSDate *startDate = [formatterF dateFromString:self.beginVM.subtitle];
    NSDate *endDate = [formatterF dateFromString:self.endVM.subtitle];
    
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
    setting.startTime = self.beginVM.subtitle;
    setting.spanMins = timeDif;
    setting.level = RCPushNotificationQuietHoursLevelMention;
    [[RCChannelClient sharedChannelManager] setNotificationQuietHoursWithSetting:setting
                                                                         success:^{
        if (completion) {
            completion(YES);
        }
    }
                                                                           error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //                [self showAlert:RCDLocalizedString(@"alert")
            //                           message:RCDLocalizedString(@"set_fail")
            //                    cancelBtnTitle:RCDLocalizedString(@"cancel")];
            //                self.swch.on = NO;
            //                [self reloadList:NO];
            if (completion) {
                completion(YES);
            }
            
        });
    }];
}

- (void)removeQuietHours:(void(^)(BOOL ret))completion  {
    [[RCCoreClient sharedCoreClient] removeNotificationQuietHours:^{
        if (completion) {
            completion(YES);
        }
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //                [self showAlert:RCDLocalizedString(@"alert")
            //                           message:RCDLocalizedString(@"shut_down_failed")
            //                    cancelBtnTitle:RCDLocalizedString(@"cancel")];
            //                self.swch.on = YES;
            //                [self reloadList:YES];
        });
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)updateQuietHours:(BOOL)enable completion:(void(^)(BOOL ret))completion  {
    if (enable) {
        [self configureQuietHours:completion];
    } else {
        [self removeQuietHours:completion];
    }
}


- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDCommonCell class]
      forCellReuseIdentifier:RCNDCommonCellIdentifier];
    [tableView registerClass:[RCNDSwitchCell class]
      forCellReuseIdentifier:RCNDSwitchCellIdentifier];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataSource[section];
    return array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (RCBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataSource[indexPath.section];
    return array[indexPath.row];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    switch (section) {
        case 1:
            title = RCDLocalizedString(@"mute_notifications_prompt");
            break;
        default:
            break;
    }
    return title;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0.01;
    switch (section) {
        case 1:
            height = 23;
            break;
        default:
            break;
    }
    return height;
}

- (void)refreshTime:(NSDate *)date {
    NSString *currentDateStr = [self.formatter stringFromDate:date];
    self.currentTimeVM.subtitle = currentDateStr;
    [self updateQuietHours:YES completion:^(BOOL ret) {
        [DEFAULTS
            setObject:self.beginVM.subtitle
               forKey:[NSString stringWithFormat:@"startTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
        [DEFAULTS
            setObject:self.endVM.subtitle
               forKey:[NSString stringWithFormat:@"endTime_%@", [RCIM sharedRCIM].currentUserInfo.userId]];
        [self reloadData];
    }];
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
        [formatterE setDateFormat:@"HH:mm:ss"];
        _formatter = formatterE;
    }
    return _formatter;
}
@end
