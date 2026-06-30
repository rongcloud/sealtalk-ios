//
//  RCNDSwitchCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSwitchCell.h"
#import "RCNDSwitchCellViewModel.h"

NSString  * const RCNDSwitchCellIdentifier = @"RCNDSwitchCellIdentifier";

@implementation RCNDSwitchCell

- (void)setupView {
    [super setupView];
    [self.contentStackView addArrangedSubview:self.labelTitle];
    [self.contentStackView addArrangedSubview:self.switchView];
}

- (void)setupConstraints {
    [super setupConstraints];
    [self updateLineViewConstraints:10 trailing:-10];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDSwitchCellViewModel class]]) {
        RCNDSwitchCellViewModel *vm = (RCNDSwitchCellViewModel *)viewModel;
        self.labelTitle.text = vm.title;
        self.switchView.on = vm.switchOn;
    }
}


- (void)switchValueChanged:(UISwitch *)switchView {
    if ([self.viewModel isKindOfClass:[RCNDSwitchCellViewModel class]]) {
        RCNDSwitchCellViewModel *vm = (RCNDSwitchCellViewModel *)self.viewModel;
        [vm switchValueChanged:switchView completion:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!isSuccess) {
                    self.switchView.on = !self.switchView.on;
                }
            });
        }];
    }
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        _switchView.onTintColor = RCDynamicColor(@"success_color", @"0x0099ff", @"0x0099ff");
        [_switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        _switchView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _switchView;
}

- (UILabel *)labelTitle {
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = RCDynamicColor(@"text_primary_color", @"0x111f2c", @"0x9f9f9f");
        _labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelTitle setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _labelTitle;
}
@end
