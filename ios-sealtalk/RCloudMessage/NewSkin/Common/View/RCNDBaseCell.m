//
//  RCNDBaseCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCell.h"

@implementation RCNDBaseCell

- (void)setupView {
    [super setupView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.paddingContainerView addSubview:self.contentStackView];
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.paddingContainerView.leadingAnchor constant:RCUserManagementPadding],
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.paddingContainerView.trailingAnchor constant:-RCUserManagementPadding],
        [self.contentStackView.topAnchor constraintEqualToAnchor:self.paddingContainerView.topAnchor],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.paddingContainerView.bottomAnchor]
    ]];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    self.viewModel = viewModel;
    self.hideSeparatorLine = viewModel.hideSeparatorLine;
}

- (UIStackView *)contentStackView {
   if (!_contentStackView) {
       _contentStackView = [[UIStackView alloc] init];
       _contentStackView.axis = UILayoutConstraintAxisHorizontal;
       _contentStackView.alignment = UIStackViewAlignmentCenter;
       _contentStackView.distribution = UIStackViewDistributionFill;
       _contentStackView.spacing = 5;
       _contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
   }
   return _contentStackView;
}
@end
