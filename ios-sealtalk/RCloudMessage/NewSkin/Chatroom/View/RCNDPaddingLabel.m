//
//  RCNDPaddingLabel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDPaddingLabel.h"

@implementation RCNDPaddingLabel

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认内边距
        _textInsets = UIEdgeInsetsMake(4, 8, 4, 8);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    // 应用内边距后绘制文字
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

- (CGSize)intrinsicContentSize {
    // 计算包含内边距的内容尺寸
    CGSize size = [super intrinsicContentSize];
    size.width += self.textInsets.left + self.textInsets.right;
    size.height += self.textInsets.top + self.textInsets.bottom;
    return size;
}

- (CGSize)sizeThatFits:(CGSize)size {
    // 计算包含内边距的适合尺寸
    CGSize adjustedSize = CGSizeMake(
        size.width - self.textInsets.left - self.textInsets.right,
        size.height - self.textInsets.top - self.textInsets.bottom
    );
    CGSize textSize = [super sizeThatFits:adjustedSize];
    return CGSizeMake(
        textSize.width + self.textInsets.left + self.textInsets.right,
        textSize.height + self.textInsets.top + self.textInsets.bottom
    );
}

@end
