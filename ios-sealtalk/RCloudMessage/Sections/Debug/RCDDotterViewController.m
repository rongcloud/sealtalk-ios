//
//  RCDDotterViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/9/26.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDDotterViewController.h"
#import <Masonry/Masonry.h>
#import "UIView+MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDDotterViewController ()
@end

@implementation RCDDotterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (void)loadView {
    self.view = [self dotterView];
}


- (UIView *)dotterView {
    UIView *view = [UIView new];
    UIButton *btnSwitch = [self buttonWith:@"异步判断HackDNS(弃用)" selector:@selector(networkSwitched)];
    UIButton *btnDNS = [self buttonWith:@"同步判断HackDNS(弃用)" selector:@selector(dnsCheckSwitched)];

    UIButton *btnFore = [self buttonWith:@"标记进入前台(弃用)" selector:@selector(enterForeground)];
    UIButton *btnRedirect = [self buttonWith:@"重定向" selector:@selector(redirect)];
    UIButton *btnHeart = [self buttonWith:@"心跳超时(进入后台返回)" selector:@selector(heartBeateTimeout)];
    UIButton *btnTimeout = [self buttonWith:@"两小时超时" selector:@selector(timeoutIn2Hours)];
    UIButton *btnRequest = [self buttonWith:@"App 连接" selector:@selector(request)];

    UIButton *btnRTCRequest = [self buttonWith:@"RTC重连" selector:@selector(rtcReconnect)];

    UIButton *btnRTCFetch = [self buttonWith:@"RTC刷新Navi" selector:@selector(refetch)];
    UIButton *btnVoIP = [self buttonWith:@"VOIP重连" selector:@selector(voipReconnect)];
    UIButton *btnDeviceToken = [self buttonWith:@"DeviceToken重连" selector:@selector(deviceTokenReconnect)];

    [view addSubview:btnSwitch];
    [view addSubview:btnFore];
    [view addSubview:btnRedirect];
    [view addSubview:btnHeart];
    [view addSubview:btnTimeout];
    [view addSubview:btnDNS];
    
    [view addSubview:btnRTCRequest];
    [view addSubview:btnRTCFetch];
    [view addSubview:btnVoIP];
    [view addSubview:btnDeviceToken];
    
    
    [view addSubview:btnRequest];
    
    [btnSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view).mas_offset(40);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnFore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnSwitch.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnRedirect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnFore.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnHeart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnRedirect.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnTimeout mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnHeart.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnDNS mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnTimeout.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    [btnRequest mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnDNS.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    [btnRTCRequest mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnRequest.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    [btnRTCFetch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnRTCRequest.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    [btnVoIP mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnRTCFetch.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    [btnDeviceToken mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnVoIP.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
 
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (UIButton *)buttonWith:(NSString *)title selector:(SEL)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor darkGrayColor]];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
- (void)showTips:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:msg];
    });
}
- (void)networkSwitched {
    Class cls2 =  NSClassFromString(@"RCNaviThread");
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [cls2 performSelector:@selector(checkLocalDNSHijackedWithUrl:) withObject:url];
    });
    [self showTips:@"异步验证DNS"];

}
- (void)dnsCheckSwitched {
  
}

- (void)request {
    Class cls =  NSClassFromString(@"RCConnectionService");
    id instance = [cls performSelector:@selector(sharedInstance)];
    SEL sel = NSSelectorFromString(@"startRetry:");
    NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSInteger reason = 0;
    [invocation setArgument:&reason atIndex:2];
    invocation.selector = sel;
    invocation.target = instance;
    [invocation invoke];
    
}

- (void)enterForeground {
    
}

- (void)redirect {
    Class cls =  NSClassFromString(@"RCConnectionService");
    id instance = [cls performSelector:@selector(sharedInstance)];
    SEL sel = NSSelectorFromString(@"startRetry:");
    NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSInteger reason = 3;
    [invocation setArgument:&reason atIndex:2];
    invocation.selector = sel;
    invocation.target = instance;
    [invocation invoke];
    [self showTips:@"重定向已发出"];
}

- (void)heartBeateTimeout {
    Class cls =  NSClassFromString(@"RCConnectionService");
    id instance = [cls performSelector:@selector(sharedInstance)];
    SEL sel = NSSelectorFromString(@"startRetry:");
    NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSInteger reason = 4;
    [invocation setArgument:&reason atIndex:2];
    invocation.selector = sel;
    invocation.target = instance;
    [invocation invoke];
    
    [self showTips:@"心跳已超时"];
}

- (void)refetch {
    Class cls =  NSClassFromString(@"RCConnectionService");
    id instance = [cls performSelector:@selector(sharedInstance)];
    SEL sel = NSSelectorFromString(@"refetchNavidataSuccess:failure:");
    NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = sel;
    invocation.target = instance;
    [invocation invoke];
    [self showTips:@"RTC fetch Navi"];
}

- (void)rtcReconnect {
    [[RCCoreClient sharedCoreClient] performSelector:@selector(reconnect)];
    [self showTips:@"RTC Reconnect"];
}

- (void)voipReconnect {
    [[RCCoreClient sharedCoreClient] performSelector:@selector(startRetryForVoIPPush)];
    [self showTips:@"startRetryForVoIPPush"];
}

- (void)deviceTokenReconnect {
    Class cls =  NSClassFromString(@"RCKernel");
    id instance = [cls performSelector:@selector(sharedInstance)];
    SEL sel = NSSelectorFromString(@"reconnectAfterDeviceTokenConfigured");
    [instance performSelector:sel];
    [self showTips:@"reconnectAfterDeviceTokenConfigured"];
}
- (void)timeoutIn2Hours {
    NSString *key = @"RC_NAVIDATAINFO_TIMESTAMP";
    long nowTimestamp = [[NSDate date] timeIntervalSince1970] - [[NSTimeZone systemTimeZone] secondsFromGMT] - 8000;
    [[NSUserDefaults standardUserDefaults] setInteger:nowTimestamp forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showTips:@"navi 时间已过期"];
    [self request];
}
@end
