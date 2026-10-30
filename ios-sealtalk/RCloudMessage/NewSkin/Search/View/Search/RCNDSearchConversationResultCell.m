//
//  RCNDSearchConversationResultCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchConversationResultCell.h"
#import "RCNDSearchConversationCellViewModel.h"

NSString  * const RCNDSearchConversationResultCellIdentifier = @"RCNDSearchConversationResultCellIdentifier";

@interface RCNDSearchConversationResultCell()<RCNDSearchConversationCellViewModelDelegate>

@end

@implementation RCNDSearchConversationResultCell

- (void)setupView {
    [super setupView];
    [self.rightStackView addArrangedSubview:self.labelSubtitle];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDSearchConversationCellViewModel class]]) {
        RCNDSearchConversationCellViewModel *vm = (RCNDSearchConversationCellViewModel *)viewModel;
        vm.cellDelegate = self;
        self.labelTitle.text = vm.title;
        self.labelSubtitle.attributedText = vm.subtitle;
        self.hideSeparatorLine = vm.hideSeparatorLine;
        self.labelSubtitle.lineBreakMode = vm.lineBreakMode;
        if (!vm.portraitURI) {
            return;
        }
        NSURL *url = [NSURL URLWithString:vm.portraitURI];
        BOOL ret = vm.info.conversation.conversationType == ConversationType_GROUP ;
        UIImage * placeholderImage = ret ? RCDynamicImage(@"conversation-list_cell_group_portrait_img", @"default_group_portrait") :RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg");
        [self.imageViewPortrait sd_setImageWithURL:url placeholderImage:placeholderImage];
    }
}

- (void)refreshCellWith:(RCNDSearchConversationCellViewModel *)viewModel {
    if (viewModel == self.viewModel) {
        self.labelTitle.text = viewModel.title;
        self.labelSubtitle.attributedText = viewModel.subtitle;
        self.labelSubtitle.lineBreakMode = viewModel.lineBreakMode;
        BOOL ret = viewModel.info.conversation.conversationType == ConversationType_GROUP ;
        UIImage *placeholderImage = ret ? RCDynamicImage(@"conversation-list_cell_group_portrait_img", @"default_group_portrait") :RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg");
        if (!viewModel.portraitURI) {
            [self.imageViewPortrait setImage:placeholderImage];
            return;
        }
        NSURL *url = [NSURL URLWithString:viewModel.portraitURI];        
        [self.imageViewPortrait sd_setImageWithURL:url placeholderImage:placeholderImage];
    }
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
@end
