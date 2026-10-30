//
//  RCNDRadioCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDRadioCell.h"
#import "RCNDRadioCellViewModel.h"

NSString  * const RCNDRadioCellIdentifier = @"RCNDRadioCellIdentifier";

@implementation RCNDRadioCell

- (void)setupView {
    [super setupView];
    [self.contentStackView  addArrangedSubview:self.imageViewRadio];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDRadioCellViewModel class]]) {
        RCNDRadioCellViewModel *vm = (RCNDRadioCellViewModel *)viewModel;
        self.imageViewArrow.hidden = vm.hideArrow;
        self.labelTitle.text = vm.title;
        self.labelSubtitle.text = vm.subtitle;
        self.imageViewRadio.hidden = !vm.selected;
    }
}

- (UIImageView *)imageViewRadio {
   if (!_imageViewRadio) {
       _imageViewRadio = [[UIImageView alloc] init];
       _imageViewRadio.image = RCDynamicImage(@"group_manage_gender_cell_check_img", @"message_cell_select");
       _imageViewRadio.translatesAutoresizingMaskIntoConstraints = NO;
       [NSLayoutConstraint activateConstraints:@[
               [_imageViewRadio.widthAnchor constraintEqualToConstant:18],
               [_imageViewRadio.heightAnchor constraintEqualToConstant:18]
           ]];
   }
   return _imageViewRadio;
}
@end
