//
//  RCNDMemberRemoveCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMemberRemoveCell.h"
#import "RCNDMemberRemoveCellViewModel.h"
#import <SDWebImage/SDWebImage.h>
NSString  * const RCNDMemberRemoveCellIdentifier = @"RCNDImageCellIdentifier";

@implementation RCNDMemberRemoveCell

- (void)setupView {
    [super setupView];
    [self.contentStackView addArrangedSubview:self.actionButton];
}

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDMemberRemoveCellViewModel class]]) {
        RCNDMemberRemoveCellViewModel *vm = (RCNDMemberRemoveCellViewModel *)viewModel;
       
    }
}

- (void)actionButtonDidTap {
    if ([self.viewModel isKindOfClass:[RCNDMemberRemoveCellViewModel class]]) {
        RCNDMemberRemoveCellViewModel *vm = (RCNDMemberRemoveCellViewModel *)self.viewModel;
        [vm actonButtonClick];
    }
}

- (RCButton *)actionButton {
    if (!_actionButton) {
        RCButton *btn = [RCButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:RCDynamicImage(@"group_follow_remove_btn_img", @"group_follow_remove_btn")
             forState:UIControlStateNormal];
        [btn addTarget:self
                action:@selector(actionButtonDidTap)
      forControlEvents:UIControlEventTouchUpInside];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        _actionButton = btn;
    }
    return _actionButton;
}

@end
