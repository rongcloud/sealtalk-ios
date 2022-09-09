//
//  RCDebugComAPIViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCDebugPushLevelViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SelectedItemBlock)(RCDComChatroomOptionCategory category);

@interface RCDebugComAPIViewController : UITableViewController

@property (nonatomic, copy) SelectedItemBlock selectedBlock;
@property (nonatomic, strong) NSString *targetId;

@property (nonatomic, strong) NSString *channelId;

@property (nonatomic, assign) RCConversationType type;
@end

NS_ASSUME_NONNULL_END
