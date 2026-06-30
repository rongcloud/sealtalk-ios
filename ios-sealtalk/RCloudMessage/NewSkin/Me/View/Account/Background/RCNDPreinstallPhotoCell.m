//
//  RCPreinstallPhotoCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDPreinstallPhotoCell.h"
#import "RCNDPreinstallPhotoCellViewModel.h"

NSString  * const RCNDPreinstallPhotoCellIdentifier = @"RCNDPreinstallPhotoCellIdentifier";

@interface RCNDPreinstallPhotoCell()
@property (nonatomic, strong) UIView *selectionContainer;;
@end

@implementation RCNDPreinstallPhotoCell



- (void)setupView {
    [super setupView];
    [self.contentView addSubview:self.imageContent];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg_select"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *containerView = [UIView new];
    containerView.backgroundColor = RCDynamicColor(@"mask_color", @"0x00000080", @"0x00000080");
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.hidden = YES;
    [containerView addSubview:imageView];
    [self.contentView addSubview:containerView];
    self.selectionContainer = containerView;
    [NSLayoutConstraint activateConstraints:@[
          [imageView.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
          [imageView.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor]

      ]];
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
        [self.selectionContainer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.selectionContainer.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.selectionContainer.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [self.selectionContainer.heightAnchor constraintEqualToConstant:20],
          [self.imageContent.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
          [self.imageContent.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
          [self.imageContent.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
          [self.imageContent.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
          ]];
}

- (void)updateWithViewModel:(RCBaseCellViewModel *)viewModel {
    if ([viewModel isKindOfClass:[RCNDPreinstallPhotoCellViewModel class]]) {
        RCNDPreinstallPhotoCellViewModel *vm = (RCNDPreinstallPhotoCellViewModel *)viewModel;
        self.selectionContainer.hidden = !vm.selected;
        self.imageContent.image = [UIImage imageNamed:vm.imageName];
    }
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
