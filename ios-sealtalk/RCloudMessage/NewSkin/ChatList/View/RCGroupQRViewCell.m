//
//  RCGroupQRViewCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCGroupQRViewCell.h"

NSString  * const RCGroupQRViewCellIdentifier = @"RCGroupQRViewCellIdentifier";

@implementation RCGroupQRViewCell

- (void)setupView {
    [super setupView];
    [self.contentStackView addArrangedSubview:self.imageViewIcon];
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
