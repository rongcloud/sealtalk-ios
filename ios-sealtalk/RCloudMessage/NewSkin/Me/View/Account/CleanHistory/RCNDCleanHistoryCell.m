//
//  RCNDCleanHistoryCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCleanHistoryCell.h"
#import "RCNDCleanHistoryCellViewModel.h"
#import <SDWebImage/SDWebImage.h>

NSString  * const RCNDCleanHistoryCellIdentifier = @"RCNDCleanHistoryCellIdentifier";

@implementation RCNDCleanHistoryCell

- (void)setupView {
    [super setupView];
    self.contentStackView.spacing = 12;
    [self.contentStackView insertArrangedSubview:self.imageCheckBox atIndex:0];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDCleanHistoryCellViewModel class]]) {
        RCNDCleanHistoryCellViewModel *vm = (RCNDCleanHistoryCellViewModel *)viewModel;
        [self.imageViewIcon sd_setImageWithURL:[NSURL URLWithString:vm.imageURL] placeholderImage:RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg")];
        [self refreshState:vm];
    }
}

-  (void)refreshState:(RCNDBaseCellViewModel *)viewModel {
    if ([viewModel isKindOfClass:[RCNDCleanHistoryCellViewModel class]]) {
        RCNDCleanHistoryCellViewModel *vm = (RCNDCleanHistoryCellViewModel *)viewModel;
        if (!vm.selected) {
            [self.imageCheckBox setImage:RCDynamicImage(@"conversation_msg_cell_unselect_img", @"message_cell_unselect")];
        } else {
            [self.imageCheckBox setImage:RCDynamicImage(@"conversation_msg_cell_select_img", @"message_cell_select")];
        }
    }
}
- (UIImageView *)imageCheckBox {
   if (!_imageCheckBox) {
       _imageCheckBox = [[UIImageView alloc] init];
       _imageCheckBox.translatesAutoresizingMaskIntoConstraints = NO;
       [NSLayoutConstraint activateConstraints:@[
        [_imageCheckBox.widthAnchor constraintEqualToConstant:20],
        [_imageCheckBox.heightAnchor constraintEqualToConstant:20]
       ]];
   }
   return _imageCheckBox;
}
@end
