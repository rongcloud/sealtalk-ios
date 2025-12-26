//
//  RCNDFooterView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDFooterView.h"

@implementation RCNDFooterView

- (void)setupView {
    [super setupView];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentStackView];
}

- (void)setupConstraints {
    [super setupConstraints];
    
    // 创建水平约束并降低优先级，避免在 tableFooterView 中宽度为 0 时冲突
    NSLayoutConstraint *leadingConstraint = [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:RCUserManagementPadding];
    leadingConstraint.priority = UILayoutPriorityDefaultHigh; // 750
    
    NSLayoutConstraint *trailingConstraint = [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-RCUserManagementPadding];
    trailingConstraint.priority = UILayoutPriorityDefaultHigh; // 750
    
    [NSLayoutConstraint activateConstraints:@[
          leadingConstraint,
          trailingConstraint,
          [self.contentStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:40],
          [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
      ]];
}

- (UIStackView *)contentStackView {
   if (!_contentStackView) {
       _contentStackView = [[UIStackView alloc] init];
       _contentStackView.axis = UILayoutConstraintAxisVertical;
       _contentStackView.alignment = UIStackViewAlignmentFill;
       _contentStackView.distribution = UIStackViewDistributionFill;
       _contentStackView.spacing = 5;
       _contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
   }
   return _contentStackView;
}
@end
