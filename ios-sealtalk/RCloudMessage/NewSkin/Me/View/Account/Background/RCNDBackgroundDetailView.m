//
//  RCNDBackgroundDetailView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBackgroundDetailView.h"

@implementation RCNDBackgroundDetailView


- (void)setupView {
    [super setupView];
    [self addSubview:self.imageContent];
   
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
          [self.imageContent.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
          [self.imageContent.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
          [self.imageContent.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
          [self.imageContent.topAnchor constraintEqualToAnchor:self.topAnchor],
          ]];
}

- (UIImageView *)imageContent {
   if (!_imageContent) {
       _imageContent = [[UIImageView alloc] init];
       _imageContent.translatesAutoresizingMaskIntoConstraints = NO;
//       [NSLayoutConstraint activateConstraints:@[
//               [_imageViewRadio.widthAnchor constraintEqualToConstant:18],
//               [_imageViewRadio.heightAnchor constraintEqualToConstant:18]
//           ]];
   }
   return _imageContent;
}
@end
