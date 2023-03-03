//
//  RCDUserGroupBaseView.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupBaseView.h"

@implementation RCDUserGroupBaseView

- (instancetype)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
}
@end
