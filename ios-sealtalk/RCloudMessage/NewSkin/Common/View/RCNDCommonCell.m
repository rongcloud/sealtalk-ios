//
//  RCNDCommonCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCommonCell.h"
#import "RCNDCommonCellViewModel.h"

NSString  * const RCNDCommonCellIdentifier = @"RCNDCommonCellIdentifier";

@implementation RCNDCommonCell

- (void)setupView {
    [super setupView];
    [self.contentStackView addArrangedSubview:self.labelTitle];
    [self.contentStackView addArrangedSubview:self.labelSubtitle];
    [self.contentStackView addArrangedSubview:self.imageViewArrow];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDCommonCellViewModel class]]) {
        RCNDCommonCellViewModel *vm = (RCNDCommonCellViewModel *)viewModel;
        self.imageViewArrow.hidden = vm.hideArrow;
        self.labelTitle.text = vm.title;
        self.labelSubtitle.text = vm.subtitle;
    }
}

- (void)setupConstraints {
    [super setupConstraints];
    [self updateLineViewConstraints:10 trailing:-10];
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

- (UIImageView *)imageViewArrow {
   if (!_imageViewArrow) {
       _imageViewArrow = [[UIImageView alloc] init];
       _imageViewArrow.translatesAutoresizingMaskIntoConstraints = NO;
       UIImage *image = [UIImage imageNamed:@"right_arrow"];
       if ([RCKitUtility isRTL]) {
            image = [image imageFlippedForRightToLeftLayoutDirection];
       }
       _imageViewArrow.image = image;
       [NSLayoutConstraint activateConstraints:@[
               [_imageViewArrow.widthAnchor constraintEqualToConstant:16],
               [_imageViewArrow.heightAnchor constraintEqualToConstant:16]
           ]];
   }
   return _imageViewArrow;
}

@end
