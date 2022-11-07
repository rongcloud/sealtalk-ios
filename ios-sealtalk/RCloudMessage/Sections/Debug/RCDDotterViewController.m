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
    UIButton *btnSwitch = [self buttonWith:@"异步判断HackDNS" selector:@selector(networkSwitched)];
    UIButton *btnDNS = [self buttonWith:@"同步判断HackDNS" selector:@selector(dnsCheckSwitched)];

    UIButton *btnFore = [self buttonWith:@"标记进入前台(返回发起请求)" selector:@selector(enterForeground)];
    UIButton *btnRedirect = [self buttonWith:@"重定向" selector:@selector(redirect)];
    UIButton *btnHeart = [self buttonWith:@"心跳超时(进入后台返回)" selector:@selector(heartBeateTimeout)];
    UIButton *btnTimeout = [self buttonWith:@"两小时超时(+发起请求)" selector:@selector(timeoutIn2Hours)];
    UIButton *btnRequest = [self buttonWith:@"发起请求" selector:@selector(request)];

    [view addSubview:btnSwitch];
    [view addSubview:btnFore];
    [view addSubview:btnRedirect];
    [view addSubview:btnHeart];
    [view addSubview:btnTimeout];
    [view addSubview:btnDNS];
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
    Class cls2 =  NSClassFromString(@"RCNaviThread");
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    [cls2 performSelector:@selector(checkLocalDNSHijackedWithUrl:) withObject:url];
    [self showTips:@"同步验证DNS"];
}

- (void)request {
    Class cls =  NSClassFromString(@"RCConnectionService");
    id instance = [cls performSelector:@selector(sharedInstance)];
    BOOL ret = YES;
    SEL sel = NSSelectorFromString(@"updateCmp:retry:");
 
    NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setArgument:&ret atIndex:2];
    [invocation setArgument:&ret atIndex:3];

    invocation.selector = sel;
    invocation.target = instance;
    [invocation invoke];
    
}

- (void)enterForeground {
    Class cls =  NSClassFromString(@"RCConnectionService");
    id instance = [cls performSelector:@selector(sharedInstance)];
    int num = 1;
    id state = [instance performSelector:@selector(globalConnectionState)];
    SEL sel = NSSelectorFromString(@"updateCurrentStatus:");
    NSMethodSignature *signature = [state methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setArgument:&num atIndex:2];
//    [invocation setArgument:&ret atIndex:3];

    invocation.selector = sel;
    invocation.target = state;
    [invocation invoke];
    
    [self showTips:@"回到前台请求Navi已标记"];
}

- (void)redirect {
    Class cls =  NSClassFromString(@"RCConnectionService");
    id instance = [cls performSelector:@selector(sharedInstance)];
    BOOL ret = YES;
    SEL sel = NSSelectorFromString(@"setIsConnRedirected:");
    NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setArgument:&ret atIndex:2];
    invocation.selector = sel;
    invocation.target = instance;
    [invocation invoke];
    
    sel = NSSelectorFromString(@"connect:");
    ret = NO;
    signature = [instance methodSignatureForSelector:sel];
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setArgument:&ret atIndex:2];
    invocation.selector = sel;
    invocation.target = instance;
    [invocation invoke];
  

    [self showTips:@"重定向已标记"];
}

- (void)heartBeateTimeout {
    Class cls =  NSClassFromString(@"RCConnectionService");
    id instance = [cls performSelector:@selector(sharedInstance)];
    long long currentTime = (long long)([[NSDate date] timeIntervalSince1970] * 1000) ;
    long long expired = currentTime - 500 * 1000;
    SEL sel = NSSelectorFromString(@"setSuspendTime:");
    NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setArgument:&expired atIndex:2];
    invocation.selector = sel;
    invocation.target = instance;
    [invocation invoke];
    
    [self showTips:@"心跳已超时"];
}

- (void)timeoutIn2Hours {
    NSString *key = @"RC_NAVIDATAINFO_TIMESTAMP";
    long nowTimestamp = [[NSDate date] timeIntervalSince1970] - [[NSTimeZone systemTimeZone] secondsFromGMT] - 8000;
    [[NSUserDefaults standardUserDefaults] setInteger:nowTimestamp forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showTips:@"navi 时间已过期"];
}
@end
