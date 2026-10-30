//
//  RCNDMessageBlockView.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCNDMessageBlockView : RCSearchBarListView
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIButton *confirmButton;
- (void)showDatePicker:(NSDate *)date;
- (void)hideDatePicker;
@end

NS_ASSUME_NONNULL_END
