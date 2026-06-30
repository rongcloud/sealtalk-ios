//
//  RCNDMessageBlockView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMessageBlockView.h"

@interface RCNDMessageBlockView()
@property (nonatomic, strong) UIToolbar *accessoryToolbar;
@property (nonatomic, strong) UITextField *txtFiledHidden;
@end

@implementation RCNDMessageBlockView

- (void)setupView {
    [super setupView];
    self.txtFiledHidden.hidden = YES;
    [self.tableView.tableHeaderView addSubview: self.txtFiledHidden];
}

- (void)cancelPicker {
    [self.txtFiledHidden resignFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.accessoryToolbar.frame = CGRectMake(0, 0, self.bounds.size.width, 44);
}

- (void)dealloc
{
    
}
- (void)showDatePicker:(NSDate *)date {
    [self.datePicker setDate:date];
    [self.txtFiledHidden becomeFirstResponder];
}

- (void)hideDatePicker {
    [self.txtFiledHidden resignFirstResponder];
}

- (UITextField *)txtFiledHidden {
    if (!_txtFiledHidden) {
        _txtFiledHidden = [UITextField new];
        _txtFiledHidden.inputView = self.datePicker;
        _txtFiledHidden.inputAccessoryView = self.accessoryToolbar;
    }
    return _txtFiledHidden;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        // 2. 日期选择器配置
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    }
    return _datePicker;
}

- (UIToolbar *)accessoryToolbar {
    if (!_accessoryToolbar) {
        // 3. 顶部辅助栏（确定/取消）
        _accessoryToolbar = [[UIToolbar alloc] init];
        _accessoryToolbar.backgroundColor = RCDynamicColor(@"common_background_color", @"0xffffff", @"0x1a1a1a");
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:RCDLocalizedString(@"cancel")
                        forState:UIControlStateNormal];
        [cancelButton setTitleColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x007acc")
                             forState:UIControlStateNormal];
        [cancelButton addTarget:self
                         action:@selector(cancelPicker)
               forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
        UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
        _accessoryToolbar.items = @[cancelBtn, flexSpace, confirmBtn];
    }
    return _accessoryToolbar;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:RCDLocalizedString(@"confirm")
                        forState:UIControlStateNormal];
        [_confirmButton setTitleColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x007acc")
                             forState:UIControlStateNormal];
    }
    return _confirmButton;
}
@end
