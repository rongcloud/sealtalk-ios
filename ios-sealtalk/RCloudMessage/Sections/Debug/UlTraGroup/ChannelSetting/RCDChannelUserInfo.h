//
//  RCDChannelUserInfo.h
//  SealTalk
//
//  Created by RobinCui on 2022/6/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDChannelUserInfo : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *portrait;
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, assign) BOOL isInWhiteList;
@property (nonatomic, copy) NSString *userID;
@end

NS_ASSUME_NONNULL_END
