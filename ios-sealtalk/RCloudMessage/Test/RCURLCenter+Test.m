//
//  RCURLCenter+Test.m
//  SealTalk
//
//  Created by chinaspx on 2023/8/17.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCURLCenter+Test.h"
#import "RCDCommonString.h"

@implementation RCURLCenter (Test)

- (BOOL)isOpenTest {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL openTest = [[userDefault valueForKey:RCDDebugENABLE_STATICCONF_TEST] boolValue];
    return openTest;
}

@end
