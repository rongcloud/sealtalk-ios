//
//  RCDUltraGroupNotificationMessage.h
//  SealTalk
//
//  Created by 张改红 on 2022/1/26.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

NSString * const RCDUltraGroupDismiss = @"Dismiss";

#define RCDUltraGroupNotificationMessageIdentifier @"ST:UltraGrpNtf"


@interface RCDUltraGroupNotificationMessage : RCMessageContent
@property (nonatomic, copy) NSString *operation;
@end

