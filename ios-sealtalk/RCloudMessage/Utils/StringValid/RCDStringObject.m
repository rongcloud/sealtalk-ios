//
//  RCDStringObject.m
//  SealTalk
//
//  Created by lizhipeng on 2022/6/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDStringObject.h"

BOOL rc_str_Is_Valid(NSString *str);
BOOL rc_value_valid(id object);
BOOL rc_objc_iskindClass_valid(id object, Class aClass);

inline NSString *rc_str_protect(NSString *str)
{
    return rc_str_Is_Valid(str) ? str : @"";
}

inline BOOL rc_str_Is_Valid(NSString *str)
{
    if (rc_objc_iskindClass_valid(str, [NSString class]) &&
        str.length > 0)
    {
        return YES;
    }
    
    return NO;
}

inline BOOL rc_objc_iskindClass_valid(id object, Class aClass)
{
    if (rc_value_valid(object) &&
        [object isKindOfClass:aClass])
    {
        return YES;
    }
    
    return NO;
}

inline BOOL rc_value_valid(id object)
{
    if (object != nil &&
        (NSNull *)object != [NSNull null])
    {
        return YES;
    }
    
    return NO;
}



