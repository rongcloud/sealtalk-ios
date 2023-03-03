//
//  RCDUserGroupMemberInfo.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupMemberInfo : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *portrait;
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, copy) NSString *channelID;

@property(nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
