//
//  RCNDSearchMessageCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMessageCell.h"
#import "RCNDSearchMessageCellViewModel.h"
#import <SDWebImage/SDWebImage.h>

NSString  * const RCNDSearchMessageCellIdentifier = @"RCNDSearchMessageCellIdentifier";

@interface RCNDSearchMessageCell()<RCNDSearchMessageCellViewModelDelegate>

@end

@implementation RCNDSearchMessageCell


- (void)setupView {
    [super setupView];
    [self.topStackView addArrangedSubview:self.labelTitle];
    [self.topStackView addArrangedSubview:self.labelTime];
    [self.rightStackView addArrangedSubview:self.topStackView];
    [self.rightStackView addArrangedSubview:self.labelSubtitle];
    [self.contentStackView addArrangedSubview:self.self.imageViewPortrait];
    [self.contentStackView addArrangedSubview:self.rightStackView];
}


- (void)setupConstraints {
    [super setupConstraints];
    [self updateLineViewConstraints:60 trailing:-16];
}


- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDSearchMessageCellViewModel class]]) {
        RCNDSearchMessageCellViewModel *vm = (RCNDSearchMessageCellViewModel *)viewModel;
        vm.cellDelegate = self;
        self.labelTitle.text = vm.title;
        self.labelSubtitle.attributedText = vm.subtitle;
        self.labelSubtitle.lineBreakMode = vm.lineBreakMode;
        self.labelTime.text = vm.timeString;
        self.hideSeparatorLine = vm.hideSeparatorLine;
        if (!vm.portraitURI) {
            return;
        }
        NSURL *url = [NSURL URLWithString:vm.portraitURI];
        UIImage * placeholderImage = RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg");
        [self.imageViewPortrait sd_setImageWithURL:url placeholderImage:placeholderImage];
    }
}

- (void)refreshCellWith:(RCNDSearchMessageCellViewModel *)viewModel {
    if (viewModel == self.viewModel) {
        self.labelTitle.text = viewModel.title;
        self.labelSubtitle.attributedText = viewModel.subtitle;
        UIImage *placeholderImage = RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg");
        if (!viewModel.portraitURI) {
            [self.imageViewPortrait setImage:placeholderImage];
            return;
        }
        NSURL *url = [NSURL URLWithString:viewModel.portraitURI];
  
        
        [self.imageViewPortrait sd_setImageWithURL:url placeholderImage:placeholderImage];
    }
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

- (UIStackView *)topStackView {
  if (!_topStackView) {
      _topStackView = [[UIStackView alloc] init];
      _topStackView.axis = UILayoutConstraintAxisHorizontal;
      _topStackView.alignment = UIStackViewAlignmentCenter;
      _topStackView.distribution = UIStackViewDistributionFill;
      _topStackView.spacing = 8;
      _topStackView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _topStackView;
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


- (UILabel *)labelSubtitle {
    if (!_labelSubtitle) {
        _labelSubtitle = [[UILabel alloc] init];
        _labelSubtitle.textColor = RCDynamicColor(@"text_secondary_color", @"0x7C838E", @"0x7C838E");
        _labelSubtitle.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelSubtitle setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_labelSubtitle setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                        forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _labelSubtitle;
}

- (UILabel *)labelTime {
    if (!_labelTime) {
        _labelTime = [[UILabel alloc] init];
        _labelTime.textColor = RCDynamicColor(@"text_secondary_color", @"0x7C838E", @"0x7C838E");
        _labelTime.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelTime setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_labelTime setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                        forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _labelTime;
}

@end
