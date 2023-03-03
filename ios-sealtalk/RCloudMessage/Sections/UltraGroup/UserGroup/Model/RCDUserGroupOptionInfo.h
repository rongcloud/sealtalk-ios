//
//  RCDUserGroupOptionInfo.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/12.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupOptionInfo : NSObject
@property(nonatomic, strong) RCDUserGroupInfo *userGroup;
@property(nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
