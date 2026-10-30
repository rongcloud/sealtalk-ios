//
//  RCNDBaseCollectionViewCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCollectionViewCell.h"

@implementation RCNDBaseCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setupConstraints];
    }
    return self;
}

- (void)setupView {
}

- (void)setupConstraints {
    
}

- (void)updateWithViewModel:(RCBaseCellViewModel *)viewModel {

}
@end
