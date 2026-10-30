//
//  RCNDCleanHistoryView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCleanHistoryView.h"

@interface RCNDCleanHistoryView()
@property (nonatomic, strong) UIStackView *bottomStackView;
@end

@implementation RCNDCleanHistoryView

- (void)setupView {
    [super setupView];
    [self addSubview:self.bottomStackView];
    [self.bottomStackView addArrangedSubview:self.buttonSelectAll];
    UIView *placeholder = [UIView new];
    [placeholder setContentHuggingPriority:UILayoutPriorityDefaultLow
                                   forAxis:UILayoutConstraintAxisHorizontal];
    [self.bottomStackView addArrangedSubview:placeholder];
    [self.bottomStackView addArrangedSubview:self.buttonDelete];
}

- (void)changeButtonsStatusBy:(NSInteger)count
                isAllSelected:(BOOL)allSelected {
    NSString *title = RCDLocalizedString(@"Delete");
    if (count != 0) {
        title = [NSString stringWithFormat:@"%@ (%ld)",RCDLocalizedString(@"Delete") ,(long)count];
    }
    [self.buttonDelete setTitle:title forState:UIControlStateNormal];
    if (count>0 && allSelected) {
        [self.buttonSelectAll setImage:RCDynamicImage(@"conversation_msg_cell_select_img", @"message_cell_select")
                              forState:UIControlStateNormal];
    } else {
          [self.buttonSelectAll setImage:RCDynamicImage(@"conversation_msg_cell_unselect_img", @"message_cell_unselect")
                              forState:UIControlStateNormal];
    }
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.contentStackView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.bottomStackView.topAnchor],
        
        [self.bottomStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:RCUserManagementPadding],
        [self.bottomStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-RCUserManagementPadding],
        [self.bottomStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.bottomStackView.heightAnchor constraintEqualToConstant:72]
    ]];
}

- (UIButton *)buttonDelete {
    if (!_buttonDelete) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:RCDLocalizedString(@"Delete") forState:UIControlStateNormal];
        [btn setBackgroundColor:RCDynamicColor(@"hint_color", @"0xF74D43", @"0xFF5047")];
        btn.contentEdgeInsets = UIEdgeInsetsMake(5, 12, 5, 12);
         btn.layer.cornerRadius = 6;
        btn.layer.masksToBounds = YES;
        [btn setTitleColor:RCDynamicColor(@"control_title_white_color", @"0xffffff", @"0xffffff")
                  forState:UIControlStateNormal];
        [btn setContentHuggingPriority:UILayoutPriorityRequired
                               forAxis:UILayoutConstraintAxisHorizontal];
        _buttonDelete = btn;
    }
    return _buttonDelete;
}

- (UIButton *)buttonSelectAll {
    if (!_buttonSelectAll) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:RCDLocalizedString(@"AllSelect") forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setImage:RCDynamicImage(@"conversation_msg_cell_unselect_img", @"message_cell_unselect")
             forState:UIControlStateNormal];
         [btn setTitleColor:RCDynamicColor(@"text_primary_color", @"0x3b3b3b", @"0xA7a7a7")
                   forState:UIControlStateNormal];

        [btn setContentHuggingPriority:UILayoutPriorityRequired
                               forAxis:UILayoutConstraintAxisHorizontal];
        _buttonSelectAll = btn;
    }
    return _buttonSelectAll;
}


- (UIStackView *)bottomStackView {
 if (!_bottomStackView) {
     _bottomStackView = [[UIStackView alloc] init];
     _bottomStackView.axis = UILayoutConstraintAxisHorizontal;
     _bottomStackView.alignment = UIStackViewAlignmentCenter;
     _bottomStackView.distribution = UIStackViewDistributionFill;
     _bottomStackView.spacing = 5;
     _bottomStackView.translatesAutoresizingMaskIntoConstraints = NO;
 }
 return _bottomStackView;
}
@end
