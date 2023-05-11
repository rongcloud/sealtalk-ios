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
@property(nonatomic, strong) RCDownloadItem *item;
@property(nonatomic, assign) bool loadable;
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
    UIButton *btnLoad = [self buttonWith:@"加载[False:无效链接, True: 有效链接]" selector:@selector(loadFileURL)];
    UIButton *btnReload = [self buttonWith:@"恢复" selector:@selector(reloadURL)];

    UIButton *btnSuspend = [self buttonWith:@"休眠" selector:@selector(itemSuspend)];
    UIButton *btnSwitch = [self buttonWith:@"切换[False]" selector:@selector(redirect:)];
    UIButton *btnCancel = [self buttonWith:@"取消" selector:@selector(itemCancel)];

    [view addSubview:btnLoad];
    [view addSubview:btnReload];
    [view addSubview:btnSuspend];
    [view addSubview:btnSwitch];
    [view addSubview:btnCancel];
  
    [btnLoad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view).mas_offset(40);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnReload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnLoad.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnSuspend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnReload.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnSuspend.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(view);
        make.width.mas_equalTo(300);
    }];
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnSwitch.mas_bottom).mas_offset(20);
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

- (void)downloadItem:(RCDownloadItem *)item state:(RCDownloadItemState)state {
    NSLog(@"[DD] state: %d", state);
}

/**
下载进度上报时调用

@param item 下载任务
@param progress 下载进度
*/
- (void)downloadItem:(RCDownloadItem *)item progress:(float)progress {
    NSLog(@"[DD] progress: %f", progress);
}

/**
任务结束时调用

@param item 下载任务
@param error 错误信息对象，成功时为 nil
@param path 下载完成后文件的路径，此路径为相对路径，相对于沙盒根目录 NSHomeDirectory
*/
- (void)downloadItem:(RCDownloadItem *)item didCompleteWithError:(nullable NSError *)error filePath:(nullable NSString *)path {
    NSLog(@"[DD] error: %@", [error localizedDescription]);
}
static int indexCount = 0;

- (void)loadFileURL {
    indexCount++;
    NSString *identify = [NSString stringWithFormat: @"identify-%d", indexCount];
    NSString *url = @"";
    if (self.loadable) {
        url= @"http://qapm-1253358381.cosgz.myqcloud.com/QAPM_SDK_Outer_v3.0.3.zip";
    }
    NSLog(@"[DD] url: %@", url);
    RCResumeableDownloader *downloader = [RCResumeableDownloader defaultInstance];
    self.item =
        [downloader itemWithIdentify:identify
                                 url:url
                            fileName:@"identify"];
    self.item.delegate = self;
    [self.item downLoad];
}


- (void)reloadURL {
    NSLog(@"[DD] resume: %d", [self.item resumable]);

    [self.item resume];
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

- (void)itemSuspend {
    [self.item suspend];
    NSLog(@"[DD] : suspend");
}

- (void)redirect:(UIButton *)btn {
    self.loadable = !self.loadable;
    if (self.loadable) {
        [btn setTitle:@"切换[True]" forState:UIControlStateNormal];
    } else {
        [btn setTitle:@"切换[False]" forState:UIControlStateNormal];
    }
}

- (void)itemCancel {
    [self.item cancel];
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
