//
//  RCDRegistrationAgreementController.m
//  SealTalk
//
//  Created by 张改红 on 2021/3/30.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDRegistrationAgreementController.h"
#import <WebKit/WebKit.h>
@interface RCDRegistrationAgreementController ()<WKNavigationDelegate>
@property (nonatomic, strong)  WKWebView *webView;
@property (nonatomic, assign)  BOOL isInjected;
@end

@implementation RCDRegistrationAgreementController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = self.webViewTitle;
    self.view.backgroundColor = HEXCOLOR(0xffffff);
    [self.view addSubview:self.webView];
    
    // 创建NSURLRequest
    NSURLRequest * request = [NSURLRequest requestWithURL:self.url];
    // 加载
    [self.webView loadRequest:request];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.needInjectJSFontSize == NO) {
        return;
    }
    if (self.isInjected == YES) {
        return;
    }
    self.isInjected = YES;
    NSString *js = @"document.body.outerHTML";
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable html, NSError * _Nullable error) {
        NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header>";
        [webView loadHTMLString:[headerString stringByAppendingString:(NSString *)html] baseURL:nil];
    }];
}


#pragma mark - getter

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
        _webView.backgroundColor = [UIColor colorWithRed:242.f / 255.f green:242.f / 255.f blue:243.f / 255.f alpha:1.f];
        
        _webView.navigationDelegate = self;
    }
    return _webView;
}


@end
