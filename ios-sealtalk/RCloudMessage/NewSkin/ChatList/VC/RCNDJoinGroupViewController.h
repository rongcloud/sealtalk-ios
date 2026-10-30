//
//  RCNDJoinGroupViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewController.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCNDJoinGroupViewController : RCNDBaseViewController
- (instancetype)initWithGroupInfo:(RCGroupInfo *)info;
@end

NS_ASSUME_NONNULL_END
