//
//  RCNDQRForwardCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardCell.h"
#import "RCNDQRForwardSelectCellViewModel.h"
#import <SDWebImage/SDWebImage.h>

NSString  * const RCNDQRForwardCellIdentifier = @"RCNDQRForwardCellIdentifier";

@interface RCNDQRForwardCell()<RCNDQRForwardSelectCellViewModelDelegate>

@end

@implementation RCNDQRForwardCell

- (void)setupView {
    [super setupView];
    [self.contentStackView addArrangedSubview:self.imageViewPortrait];
    [self.contentStackView addArrangedSubview:self.labelTitle];
}

- (void)setupConstraints {
    [super setupConstraints];
    [self updateLineViewConstraints:60 trailing:-10];
}


- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDQRForwardSelectCellViewModel class]]) {
        RCNDQRForwardSelectCellViewModel *vm = (RCNDQRForwardSelectCellViewModel *)viewModel;
        vm.cellDelegate = self;
        self.labelTitle.text = vm.title;
        self.hideSeparatorLine = vm.hideSeparatorLine;
        BOOL ret = vm.conversationType == ConversationType_GROUP ;
        UIImage *placeholderImage = ret ? RCDynamicImage(@"conversation-list_cell_group_portrait_img", @"default_group_portrait") :RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg");
        if (!vm.portraitURL) {
            [self.imageViewPortrait setImage:placeholderImage];
            return;
        }
        NSURL *url = [NSURL URLWithString:vm.portraitURL];
        [self.imageViewPortrait sd_setImageWithURL:url placeholderImage:placeholderImage];
    }
}

- (void)refreshCellWith:(RCNDQRForwardSelectCellViewModel *)viewModel {
    if (viewModel == self.viewModel) {
        self.labelTitle.text = viewModel.title;
        BOOL ret = viewModel.conversationType == ConversationType_GROUP ;
        UIImage *placeholderImage = ret ? RCDynamicImage(@"conversation-list_cell_group_portrait_img", @"default_group_portrait") :RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg");
        if (!viewModel.portraitURL) {
            [self.imageViewPortrait setImage:placeholderImage];
            return;
        }
    
        NSURL *url = [NSURL URLWithString:viewModel.portraitURL];
  
        
        [self.imageViewPortrait sd_setImageWithURL:url placeholderImage:placeholderImage];
    }
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

- (UILabel *)labelTitle {
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = RCDynamicColor(@"text_primary_color", @"0x111f2c", @"0x9f9f9f");
        _labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelTitle setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _labelTitle;
}

@end
