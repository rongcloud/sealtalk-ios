//
//  RCNDSearchGroupResultCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchGroupResultCell.h"
#import "RCNDSearchGroupCellViewModel.h"


NSString  * const RCNDSearchGroupResultCellIdentifier = @"RCNDSearchGroupResultCellIdentifier";

@implementation RCNDSearchGroupResultCell

- (void)updateWithViewModel:(RCNDBaseCellViewModel *)viewModel {
    [super updateWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[RCNDSearchGroupCellViewModel class]]) {
        RCNDSearchGroupCellViewModel *vm = (RCNDSearchGroupCellViewModel *)viewModel;
        self.labelTitle.attributedText = vm.title;
        self.labelTitle.lineBreakMode = vm.lineBreakMode;

        self.hideSeparatorLine = vm.hideSeparatorLine;
        NSURL *url = [NSURL URLWithString:vm.info.portraitUri];
        [self.imageViewPortrait sd_setImageWithURL:url placeholderImage:RCDynamicImage(@"conversation-list_cell_group_portrait_img", @"default_group_portrait")];
    }
}

@end
