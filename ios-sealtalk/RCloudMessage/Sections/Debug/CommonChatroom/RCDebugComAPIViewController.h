//
//  RCDebugComAPIViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/4/11.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN


@interface RCDebugComAPIViewController : UITableViewController
@property (nonatomic, strong) NSString *targetId;

@property (nonatomic, strong) NSString *channelId;

@property (nonatomic, assign) RCConversationType type;
@end

NS_ASSUME_NONNULL_END
