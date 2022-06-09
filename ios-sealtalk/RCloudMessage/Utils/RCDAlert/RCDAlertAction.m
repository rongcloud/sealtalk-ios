//
//  RCDAlertAction.m
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDAlertAction.h"
#import "RCDAlertAction+Handler.h"

@implementation RCDAlertAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(RCDAlertAction * _Nonnull))handler {
    RCDAlertAction *action = [[RCDAlertAction alloc]init];
    action.title = title ;
    action.handler = handler ;
    return action ;
}

@end
