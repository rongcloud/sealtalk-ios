//
//  RCDChannelUserInfoCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2022/6/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDChannelUserInfo.h"
NS_ASSUME_NONNULL_BEGIN
@protocol RCDChannelUserInfoCellViewModelDelegate <NSObject>

- (void)channelUserInfoDidChanged:(RCDChannelUserInfo *)userInfo isSuccess:(BOOL)success;

@end

@interface RCDChannelUserInfoCellViewModel : NSObject
@property (nonatomic, strong, readonly) RCDChannelUserInfo *userInfo;
@property (nonatomic, weak) id<RCDChannelUserInfoCellViewModelDelegate> delegate;
- (instancetype)initWith:(RCDChannelUserInfo *)userInfo;
- (void)changeUserStatus;
@end

NS_ASSUME_NONNULL_END
