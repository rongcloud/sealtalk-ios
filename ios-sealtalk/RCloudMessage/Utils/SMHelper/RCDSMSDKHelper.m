//
//  RCLSMSDKHelper.m
//  SealTalk
//
//  Created by lizhipeng on 2022/4/19.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDSMSDKHelper.h"

#if !RCDDebugFraundPreventionDisable
#import "SmAntiFraud.h"
#endif

#import "RCDSMSDKDelegate.h"

static NSString *const ORGANIZATION = @"";
static NSString *const APP_ID = @"";
static NSString *const PUBLICK_KEY = @"";

@interface RCDSMSDKHelper ()

@end

@implementation RCDSMSDKHelper

+ (void)setupSMSDK {
#if !RCDDebugFraundPreventionDisable
    RCDSMSDKDelegate *delegate1 = [[RCDSMSDKDelegate alloc]init] ;
    
    SmOption *option = [[SmOption alloc] init];
    [option setOrganization: ORGANIZATION]; //必填，组织标识，邮件中 organization 项
    [option setAppId:APP_ID]; //必填，应用标识，登录数美后台应用管理查看，没有合适值，可以写 default
    [option setPublicKey:PUBLICK_KEY]; //SDK 版本高于 2.5.0 时必填，加密 KEY，邮件中 ios_public_key 附件内容

    [option setArea:AREA_BJ];
    NSString* host = @"http://fp-it-acc.fengkongcloud.com";
    [option setUrl:[host stringByAppendingString:@"/deviceprofile/v4"]];
    [option setConfUrl:[host stringByAppendingString:@"/v3/cloudconf"]];
    [option setDelegate:delegate1];
    
    [[SmAntiFraud shareInstance] create:option];
#endif
}

+ (NSString *)getDeviceId {
#if RCDDebugFraundPreventionDisable
    return @"0000-0000-0000-0000" ;
#else
    return [[SmAntiFraud shareInstance] getDeviceId] ;
#endif
}





@end
