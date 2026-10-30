//
//  RCNDImageCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDImageCell.h"
#import "RCNDImageCellViewModel.h"

NSString  * const RCNDImageCellIdentifier = @"RCNDImageCellIdentifier";

@implementation RCNDImageCell

- (void)setupView {
    [super setupView];
    [self.contentStackView insertArrangedSubview:self.imageViewIcon atIndex:0];
}

- (void)setupConstraints {
    [super setupConstraints];
    [self updateLineViewConstraints:60 trailing:-10];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDImageCellViewModel class]]) {
        RCNDImageCellViewModel *vm = (RCNDImageCellViewModel *)viewModel;
        self.imageViewIcon.hidden = vm.hideIcon;
        if (vm.imageName) {
            self.imageViewIcon.image = [UIImage imageNamed:vm.imageName];
        }
        self.imageViewArrow.hidden = vm.hideArrow;
        self.labelTitle.text = vm.title;
        self.labelSubtitle.text = vm.subtitle;
    }
}

- (UIImageView *)imageViewIcon {
   if (!_imageViewIcon) {
       _imageViewIcon = [[UIImageView alloc] init];
       _imageViewIcon.translatesAutoresizingMaskIntoConstraints = NO;
       if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
           RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
           _imageViewIcon.layer.cornerRadius = 16;
       }else{
           _imageViewIcon.layer.cornerRadius = 5.f;
       }
       _imageViewIcon.layer.masksToBounds = YES;
       [NSLayoutConstraint activateConstraints:@[
               [_imageViewIcon.widthAnchor constraintEqualToConstant:32],
               [_imageViewIcon.heightAnchor constraintEqualToConstant:32]
           ]];
   }
   return _imageViewIcon;
}
@end
