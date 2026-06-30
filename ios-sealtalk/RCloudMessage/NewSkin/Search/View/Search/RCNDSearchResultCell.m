//
//  RCNDSearchResultCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/28.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchResultCell.h"

@implementation RCNDSearchResultCell


- (void)setupView {
    [super setupView];
    [self.rightStackView addArrangedSubview:self.labelTitle];
    [self.contentStackView addArrangedSubview:self.self.imageViewPortrait];
    [self.contentStackView addArrangedSubview:self.rightStackView];
}


- (void)setupConstraints {
    [super setupConstraints];
    [self updateLineViewConstraints:60 trailing:-16];
}

- (UIImageView *)imageViewPortrait {
   if (!_imageViewPortrait) {
       _imageViewPortrait = [[UIImageView alloc] init];
       _imageViewPortrait.translatesAutoresizingMaskIntoConstraints = NO;
       if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
           RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
           _imageViewPortrait.layer.cornerRadius = 16;
       }else{
           _imageViewPortrait.layer.cornerRadius = 5.f;
       }
       _imageViewPortrait.layer.masksToBounds = YES;
       [NSLayoutConstraint activateConstraints:@[
               [_imageViewPortrait.widthAnchor constraintEqualToConstant:32],
               [_imageViewPortrait.heightAnchor constraintEqualToConstant:32]
           ]];
   }
   return _imageViewPortrait;
}

- (UIStackView *)rightStackView {
  if (!_rightStackView) {
      _rightStackView = [[UIStackView alloc] init];
      _rightStackView.axis = UILayoutConstraintAxisVertical;
      _rightStackView.alignment = UIStackViewAlignmentFill;
      _rightStackView.distribution = UIStackViewDistributionFill;
      _rightStackView.spacing = 8;
      _rightStackView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _rightStackView;
}

- (UILabel *)labelTitle {
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = RCDynamicColor(@"text_primary_color", @"0x111f2c", @"0x9f9f9f");
        _labelTitle.font = [UIFont boldSystemFontOfSize:17];
        _labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelTitle setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _labelTitle;
}

@end
