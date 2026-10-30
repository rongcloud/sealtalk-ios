//
//  RCNDSearchFriendResultCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchFriendResultCell.h"
#import "RCNDSearchFriendCellViewModel.h"

NSString  * const RCNDSearchFriendResultCellIdentifier = @"RCNDSearchFriendResultCellIdentifier";

@implementation RCNDSearchFriendResultCell


- (void)setupView {
    [super setupView];
    [self.rightStackView addArrangedSubview:self.labelRemark];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDSearchFriendCellViewModel class]]) {
        RCNDSearchFriendCellViewModel *vm = (RCNDSearchFriendCellViewModel *)viewModel;
        self.labelTitle.attributedText = vm.title;
        self.labelTitle.lineBreakMode = vm.lineBreakMode;
        self.labelRemark.text = vm.remark;
        self.labelRemark.hidden = [vm shouldShowRemark];
        self.hideSeparatorLine = vm.hideSeparatorLine;
        NSURL *url = [NSURL URLWithString:vm.info.portraitUri];
        [self.imageViewPortrait sd_setImageWithURL:url placeholderImage:RCDynamicImage(@"conversation-list_cell_portrait_msg_img",@"default_portrait_msg")];
    }
}

- (UILabel *)labelRemark {
    if (!_labelRemark) {
        _labelRemark = [[UILabel alloc] init];
        _labelRemark.textColor = RCDynamicColor(@"text_secondary_color", @"0x7C838E", @"0x7C838E");
        _labelRemark.font = [UIFont systemFontOfSize:14];
        _labelRemark.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelRemark setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_labelRemark setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                        forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _labelRemark;
}

@end
