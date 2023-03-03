//
//  RCDUserGroupInfo.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupInfo : NSObject
@property(nonatomic, copy) NSString *userGroupID;
@property(nonatomic, copy) NSString *groupID;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) NSInteger count;
@end

NS_ASSUME_NONNULL_END
