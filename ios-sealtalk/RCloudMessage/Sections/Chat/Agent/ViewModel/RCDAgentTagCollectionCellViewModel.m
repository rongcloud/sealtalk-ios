//
//  RCDAgentTagCollectionCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/14.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentTagCollectionCellViewModel.h"


@interface RCDAgentTagCollectionCellViewModel()
@end

@implementation RCDAgentTagCollectionCellViewModel

- (instancetype)initWithTag:(RCDAgentTag *)tag
{
    self = [super init];
    if (self) {
        self.tag = tag;
    }
    return self;
}

@end
