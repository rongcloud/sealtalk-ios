//
//  UIButton+AlertActionHandler.m
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "UIButton+AlertAction.h"
#import <objc/runtime.h>
#import "RCDAlertAction.h"

static const void *UtilityKey = &UtilityKey ;

@implementation UIButton (AlertAction)

@dynamic action ;

- (RCDAlertAction *)action {
    return objc_getAssociatedObject(self, UtilityKey);
}

- (void)setAction:(RCDAlertAction *)action {
    objc_setAssociatedObject(self, UtilityKey, action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
