//
//  RCNDMeView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/28.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMeView.h"

@implementation RCNDMeView

- (void)setupView {
    [super setupView];
    self.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    UIImage *img = [UIImage imageNamed:@"sealtalk_background"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:imageView belowSubview:self.contentStackView];
    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
}

@end
