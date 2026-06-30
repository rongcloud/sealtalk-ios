//
//  RCNDChatListHeaderView.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/17.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDChatListHeaderView.h"

@interface RCNDChatListHeaderView ()
@property (nonatomic, strong) UIView *innerContainer;
@end

@implementation RCNDChatListHeaderView

/// 完全模仿 RCSearchBarListView.configureSearchBar: 的实现
/// inner 容器的 masksToBounds=YES 和 backgroundColor 会遮挡 searchBar 内部的背景色
- (void)configureSearchBar:(UIView *)bar {
    bar.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat barHeight = 40;
    UIView *inner = [UIView new];
    inner.translatesAutoresizingMaskIntoConstraints = NO;
    inner.layer.cornerRadius = barHeight / 2;
    inner.layer.masksToBounds = YES;
    inner.backgroundColor = RCDynamicColor(@"common_background_color", @"0xFFFFFF", @"0x000000");
    self.innerContainer = inner;
    [self addSubview:inner];
    [inner addSubview:bar];
//     使用 Auto Layout，与 RCSearchBarListView 保持一致
    [NSLayoutConstraint activateConstraints:@[
        [inner.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [inner.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [inner.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [inner.heightAnchor constraintEqualToConstant:barHeight],
        
        [bar.centerYAnchor constraintEqualToAnchor:inner.centerYAnchor],
        [bar.leadingAnchor constraintEqualToAnchor:inner.leadingAnchor],
        [bar.trailingAnchor constraintEqualToAnchor:inner.trailingAnchor],
    ]];
    
    // 在iOS26 上缺省下边的代码, 搜索框会有背景色
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end


