//
//  RCDebugPushLevelViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDebugComBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, RCDComChatroomOptionCategory) {
    RCDComChatroomOptionCategoryNone,
    RCDComChatroomOptionCategory2_1,
    RCDComChatroomOptionCategory2_2,
    RCDComChatroomOptionCategory2_3,
    RCDComChatroomOptionCategory3_1,
    RCDComChatroomOptionCategory3_2,
    RCDComChatroomOptionCategory3_3,
    RCDComChatroomOptionCategory4_1,
    RCDComChatroomOptionCategory4_2,
    RCDComChatroomOptionCategory4_3,
    RCDComChatroomOptionCategory5_1,
    RCDComChatroomOptionCategory5_2,
    RCDComChatroomOptionCategory5_3,
    RCDComChatroomOptionCategory6_1,
    RCDComChatroomOptionCategory6_2
};
@interface RCDebugPushLevelViewController : RCDebugComBaseViewController


@property (nonatomic, assign) RCDComChatroomOptionCategory category;

@end

NS_ASSUME_NONNULL_END
