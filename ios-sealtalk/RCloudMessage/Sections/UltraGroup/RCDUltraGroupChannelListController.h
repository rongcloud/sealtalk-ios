//
//  RCDUltraGroupChannelListController.h
//  SealTalk
//
//  Created by 张改红 on 2022/1/18.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RCDUltraGroupManager.h"
#define RCDLeftSpace 66

@interface RCDUltraGroupChannelListController : RCConversationListViewController
@property (nonatomic, strong) RCDUltraGroup *ultraGroup;
- (void)refreshChannelView:(RCDUltraGroup *)group;
@end

