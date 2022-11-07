//
//  RCDProxySettingControllerViewController.m
//  SealTalk
//
//  Created by chinaspx on 2022/9/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDProxySettingControllerViewController.h"
#import <Masonry/Masonry.h>
#import "UIView+MBProgressHUD.h"
#import "RCDUIBarButtonItem.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import <RongRTCLib/RongRTCLib.h>

#define proxy_setting @"proxy_userdefault_setting"
#define proxy_host @"proxy_host"
#define proxy_port @"proxy_port"
#define proxy_username @"proxy_username"
#define proxy_password @"proxy_password"
#define proxy_testhost @"proxy_testhost"

#define TEXTCOLOR RCDDYCOLOR(0x262626, 0xffffff)
#define BGCOLOR RCDDYCOLOR(0xC7CbCe, 0x707070)
#define TEXTFIELD_FONT [UIFont systemFontOfSize:20]
#define PROXY_TESTHOST @"https://nav.cn.ronghub.com"

@interface RCDProxySettingControllerViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITextField *hostTF;

@property (nonatomic, strong) UITextField *portTF;

@property (nonatomic, strong) UITextField *userNameTF;

@property (nonatomic, strong) UITextField *passwordTF;

@property (nonatomic, strong) UITextField *testHostTF;

@property (nonatomic, strong) UIButton *testBtn;

@end

@implementation RCDProxySettingControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setNavi];
    [self addObserver];
    [self getDefaultData];
}

#pragma mark - Private Method
- (void)setupUI {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    
    UILabel *connectLbl = [self createLabelWithText:@"连接"];
    UIView *bgView1 = [self createView];
    [bgView1 addSubview:self.hostTF];
    [bgView1 addSubview:self.portTF];
    [self.contentView addSubview:connectLbl];
    [self.contentView addSubview:bgView1];
    
    UILabel *credentialLbl = [self createLabelWithText:@"认证"];
    UIView *bgView2 = [self createView];
    [bgView2 addSubview:self.userNameTF];
    [bgView2 addSubview:self.passwordTF];
    [self.contentView addSubview:credentialLbl];
    [self.contentView addSubview:bgView2];

    UIView *bgView3 = [self createView];
    [bgView3 addSubview:self.testHostTF];
    [self.contentView addSubview:bgView3];
    
    [self.contentView addSubview:self.testBtn];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.equalTo(self.scrollView);
    }];
    
    [connectLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.right.equalTo(self.contentView).inset(40);
        make.height.offset(40);
    }];
    
    [self.hostTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView1).offset(0);
        make.left.right.equalTo(bgView1).inset(20);
        make.height.equalTo(connectLbl);
    }];

    [self.portTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hostTF.mas_bottom).offset(0);
        make.height.left.right.equalTo(self.hostTF);
        make.bottom.equalTo(bgView1);
    }];

    [bgView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(connectLbl.mas_bottom).offset(0);
        make.left.right.equalTo(self.contentView).inset(20);
    }];
    
    
    [credentialLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView1.mas_bottom).offset(50);
        make.left.right.height.equalTo(connectLbl);
    }];
    
    [self.userNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView2).offset(0);
        make.left.right.equalTo(bgView2).inset(20);
        make.height.equalTo(credentialLbl);
    }];

    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameTF.mas_bottom).offset(0);
        make.height.left.right.equalTo(self.userNameTF);
        make.bottom.equalTo(bgView2);
    }];
    
    [bgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(credentialLbl.mas_bottom).offset(0);
        make.left.right.equalTo(bgView1);
    }];
    
    [self.testHostTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView3);
        make.height.left.right.equalTo(self.passwordTF);
        make.bottom.equalTo(bgView3);
    }];
    
    [bgView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView2.mas_bottom).offset(50);
        make.left.right.equalTo(bgView1);
    }];
    
    [self.testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView3.mas_bottom).offset(20);
        make.left.right.height.equalTo(bgView3);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)setNavi {
    self.navigationItem.title = RCDLocalizedString(@"socks_proxy_setting");
    self.navigationItem.leftBarButtonItems = [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn:)];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"save") style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"socks_proxy_clear") style:UIBarButtonItemStyleDone target:self action:@selector(clear)];
    self.navigationItem.rightBarButtonItems = @[clearButton, saveButton];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void)getDefaultData {
    NSDictionary *proxyDic = [[NSUserDefaults standardUserDefaults] objectForKey:proxy_setting];
    NSString *host = proxyDic[proxy_host];
    NSString *port = proxyDic[proxy_port];
    NSString *username = proxyDic[proxy_username];
    NSString *password = proxyDic[proxy_password];
    NSString *testhost = proxyDic[proxy_testhost];

    self.hostTF.text = host;
    self.portTF.text = port;
    if (username.length > 0) {
        self.userNameTF.text = username;
    }
    if (password.length > 0) {
        self.passwordTF.text = password;
    }
    if (testhost.length <= 0) {
        testhost = PROXY_TESTHOST;
    }
    self.testHostTF.text = testhost;
}

#pragma mark - Action

- (void)save {
    NSString *host = self.hostTF.text;
    NSString *port = self.portTF.text;
    NSString *username = self.userNameTF.text;
    NSString *password = self.passwordTF.text;
    NSString *testhost = self.testHostTF.text;
    if (host.length <= 0) {
        [self.view showHUDMessage:RCDLocalizedString(@"socks_proxy_hostaddr_notice")];
        return;
    }
    if (port.length <= 0 || port.intValue <= 0) {
        [self.view showHUDMessage:RCDLocalizedString(@"socks_proxy_port_notice")];
        return;
    }
    
    NSDictionary *proxyDic = @{
        proxy_host: host,
        proxy_port: port,
        proxy_username: username,
        proxy_password: password,
        proxy_testhost: testhost
    };
    [[NSUserDefaults standardUserDefaults] setObject:proxyDic forKey:proxy_setting];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view endEditing:YES];
    if (self.saveCallback) {
        self.saveCallback();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clear {
    [self.view endEditing:YES];
    self.hostTF.text = nil;
    self.portTF.text = nil;
    self.userNameTF.text = nil;
    self.passwordTF.text = nil;
    self.testHostTF.text = PROXY_TESTHOST;
    
    NSDictionary *proxyDic = [[NSDictionary alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:proxyDic forKey:proxy_setting];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.saveCallback) {
        self.saveCallback();
    }
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)testProxyClicked:(id)sender {
    NSString *host = self.hostTF.text;
    NSString *port = self.portTF.text;
    NSString *username = self.userNameTF.text;
    NSString *password = self.passwordTF.text;
    NSString *testhost = self.testHostTF.text;
    if (host.length <= 0) {
        [self.view showHUDMessage:RCDLocalizedString(@"socks_proxy_hostaddr_notice")];
        return;
    }
    if (port.length <= 0 || port.intValue <= 0) {
        [self.view showHUDMessage:RCDLocalizedString(@"socks_proxy_port_notice")];
        return;
    }
    if (testhost.length <= 0) {
        [self.view showHUDMessage:RCDLocalizedString(@"socks_proxy_testhost_notice")];
        return;
    }
    
    RCIMProxy *currentProxy = [[RCIMProxy alloc] initWithHost:host port:port.intValue userName:username password:password];

    [[RCCoreClient sharedCoreClient] testProxy:currentProxy testHost:testhost successBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view showHUDMessage:@"代理服务可用"];
        });
    } errorBlock:^(RCErrorCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view showHUDMessage:@"代理服务不可用，请重新输入代理参数"];
        });
    }];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardBounds = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-keyboardBounds.size.height);//.offset(-350)
        }];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self.view);
        }];
    } completion:nil];
}

#pragma mark - Setter && Getter
- (UIView *)createView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BGCOLOR;
    view.layer.cornerRadius = 8.0;
    return view;
}

- (UILabel *)createLabelWithText:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textColor = TEXTCOLOR;
    lbl.text = text;
    lbl.font = [UIFont boldSystemFontOfSize:18];
    return lbl;
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UITextField *)hostTF {
    if (!_hostTF) {
        _hostTF = [[UITextField alloc] init];
        _hostTF.textColor = TEXTCOLOR;
        _hostTF.placeholder = @"Server";
        _hostTF.font = TEXTFIELD_FONT;
    }
    return _hostTF;
}

- (UITextField *)portTF {
    if (!_portTF) {
        _portTF = [[UITextField alloc] init];
        _portTF.textColor = TEXTCOLOR;
        _portTF.font = TEXTFIELD_FONT;
        _portTF.placeholder = @"Port";
    }
    return _portTF;
}

- (UITextField *)userNameTF {
    if (!_userNameTF) {
        _userNameTF = [[UITextField alloc] init];
        _userNameTF.textColor = TEXTCOLOR;
        _userNameTF.placeholder = @"Username";
        _userNameTF.font = TEXTFIELD_FONT;
    }
    return _userNameTF;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] init];
        _passwordTF.textColor = TEXTCOLOR;
        _passwordTF.placeholder = @"Password";
        _passwordTF.font = TEXTFIELD_FONT;
    }
    return _passwordTF;
}

- (UITextField *)testHostTF {
    if (!_testHostTF) {
        _testHostTF = [[UITextField alloc] init];
        _testHostTF.textColor = TEXTCOLOR;
        _testHostTF.placeholder = @"Testhost";
        _testHostTF.font = TEXTFIELD_FONT;
    }
    return _testHostTF;
}

- (UIButton *)testBtn {
    if (!_testBtn) {
        _testBtn = [[UIButton alloc] init];
        _testBtn.backgroundColor = BGCOLOR;
        [_testBtn setTitle:@"测试代理" forState:UIControlStateNormal];
        [_testBtn setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
        [_testBtn addTarget:self action:@selector(testProxyClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testBtn;
}

+ (RCIMProxy *)currentAPPSettingIMProxy {
    NSDictionary *proxyDic = [[NSUserDefaults standardUserDefaults] objectForKey:proxy_setting];
    NSString *host = proxyDic[proxy_host];
    NSString *port = proxyDic[proxy_port];
    NSString *username = proxyDic[proxy_username];
    NSString *password = proxyDic[proxy_password];

    RCIMProxy *currentProxy = nil;
    if (host.length > 0 && port.length > 0) {
        currentProxy = [[RCIMProxy alloc] initWithHost:host port:port.intValue userName:username password:password];
    }
    return currentProxy;
}

+ (RCRTCProxy *)currentAPPSettingRTCProxy {
    RCIMProxy *currentIMProxy = [self currentAPPSettingIMProxy];
    RCRTCProxy *rtcProxy = nil;
    if (currentIMProxy && [currentIMProxy isValid]) {
        rtcProxy = [[RCRTCProxy alloc] init];
        rtcProxy.host = currentIMProxy.host;
        rtcProxy.port = currentIMProxy.port;
        rtcProxy.userName = currentIMProxy.userName;
        rtcProxy.password = currentIMProxy.password;
    }
    return rtcProxy;
}

@end
