//
//  RCNDLoginViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDLoginViewController.h"
#import "RCNDLoginView.h"
#import "RCDLanguageManager.h"
#import "RCNDCountryViewController.h"
#import "RCNDDataCenterViewController.h"
#import "RCNDLoginViewModel.h"
#import "RCDRegistrationAgreementController.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface RCNDLoginViewController ()<RCNDLoginViewModelDelegate,UITextFieldDelegate>
@property (nonatomic, strong) RCNDLoginView *loginView;
@property (nonatomic, strong) RCNDLoginViewModel *viewModel;
@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) int seconds;
@end

@implementation RCNDLoginViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [RCNDLoginViewModel new];
        self.viewModel.delegate = self;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.loginView.labelDataCenter.text = [RCNDDataCenterViewModel currentDataCenter];
    [self refreshPictureVerificationCode];
}

- (void)loadView {
    self.view = self.loginView;
}

- (void)setupView {
    [super setupView];
    NSString *language = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
    if ([language isEqualToString:@"en"]) {
        [self.loginView.buttonLanguage setTitle:@"简体中文" forState:(UIControlStateNormal)];
    } else if ([language isEqualToString:@"zh-Hans"]) {
        [self.loginView.buttonLanguage setTitle:@"EN" forState:(UIControlStateNormal)];
    }
    self.loginView.txtPhoneNum.text = [self.viewModel currentPhoneNumber];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(didTapDataCenter)];
    [self.loginView.labelDataCenter addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(didLongPressDataCenter:)];
    [self.loginView.labelDataCenter addGestureRecognizer:longGesture];
    
    self.loginView.labelDataCenter.text = [RCNDDataCenterViewModel currentDataCenter];
    RCDCountry *currentRegion = [RCNDCountryViewModel currentRegion];
    self.loginView.labelCountryCode.text = [NSString stringWithFormat:@"+%@", currentRegion.phoneCode];
    self.loginView.labelArea.text = currentRegion.countryName;
    
    UITapGestureRecognizer *tapCountry =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(didTapCountryList)];
    [self.loginView.labelArea addGestureRecognizer:tapCountry];
}


- (void)refreshPictureVerificationCode {
    RCNetworkStatus status = [[RCCoreClient sharedCoreClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        [self.view showHUDMessage:RCDLocalizedString(@"network_can_not_use_please_check")];
        [self.loginView.buttonPhotoVerify setImage:nil forState:(UIControlStateNormal)];
        return;
    }
    [self.viewModel refreshPictureVerificationCode:^(BOOL ret, UIImage * _Nullable image) {
        if(ret) {
            [self.loginView.buttonPhotoVerify setImage:image forState:(UIControlStateNormal)];

        } else {
            [self.loginView.buttonPhotoVerify setImage:nil forState:(UIControlStateNormal)];
        }
    }];
   
}

- (void)didTapCountryList {
    __weak typeof(self) weakSelf = self;

    RCNDCountryViewModel *vm = [[RCNDCountryViewModel alloc] initWithBlock:^(RCDCountry * _Nonnull country) {
        weakSelf.loginView.labelArea.text = country.countryName;
        weakSelf.loginView.labelCountryCode.text = [NSString stringWithFormat:@"+%@", country.phoneCode];
    }];
    RCNDCountryViewController *vc = [[RCNDCountryViewController alloc] initWithViewModel:vm];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapDataCenter {
    __weak typeof(self) weakSelf = self;
    RCNDDataCenterViewModel *vm = [[RCNDDataCenterViewModel alloc] initWithBlock:^(NSString * _Nonnull name) {
        weakSelf.loginView.labelDataCenter.text = name;
    }];
    RCNDDataCenterViewController *vc = [[RCNDDataCenterViewController alloc] initWithViewModel:vm];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didLongPressDataCenter:(UIGestureRecognizer *)gesture{
    if (gesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    [RCNDDataCenterViewModel refreshEnvironmentStatus];
}


- (void)didTapSwitchLanguage:(UIButton *)sender {
    NSString *currentLanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
    if ([currentLanguage isEqualToString:@"en"]) {
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:@"zh-Hans"];
    } else if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:@"en"];
    }
    RCNDLoginViewController *temp = [[RCNDLoginViewController alloc] init];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;        //可更改为其他方式
    transition.subtype = kCATransitionFromLeft; //可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:temp animated:NO];
}

- (void)sendVerifyCode {
    NSString *phoneNumber = self.loginView.txtPhoneNum.text;
    if (phoneNumber.length == 0) {
        [self showTips:RCDLocalizedString(@"phone_number_type_error")];
        return;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [userDefault valueForKey:@"RCDDebugUltraGroupEnable"];
    if(![value boolValue]) {
        NSString *picCode = [self.loginView.txtPhotoVerifyCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (picCode.length == 0) {
            [self showTips:RCDLocalizedString(@"picture_verification_code_null")];
            return;
        }
    }
    RCDCountry *currentRegion = [RCNDCountryViewModel currentRegion];
    [self.viewModel getVerifyCode:currentRegion.phoneCode
                      phoneNumber:phoneNumber
                        photoCode:self.loginView.txtPhotoVerifyCode.text completion:^(BOOL ret) {
        if (ret) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self countDown:60];
            });
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - action
- (BOOL)checkContent {
    NSString *vCode = self.loginView.txtVerifyCode.text;
    if (vCode.length == 0) {
        [self showTips:RCDLocalizedString(@"verification_code_can_not_nil")];
        return NO;
    }
    NSString *phone = self.loginView.txtPhoneNum.text;
    if (phone.length == 0) {
        [self showTips:RCDLocalizedString(@"mobile_number_error")];
        return NO;
    }
    return YES;
}

- (void)didTapLoginButtonClicked:(UIButton *)sender{
    RCNetworkStatus status = [[RCCoreClient sharedCoreClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        [self showTips:RCDLocalizedString(@"network_can_not_use_please_check")];
        return;
    }
    
    if (![self checkContent]){
        return;
    }

    NSString *phone = self.loginView.txtPhoneNum.text;
    NSString *verifyCode = self.loginView.txtVerifyCode.text;
    [self showLoading];
    RCDCountry *currentRegion = [RCNDCountryViewModel currentRegion];

    [self.viewModel loginRongCloud:phone
                        verifyCode:verifyCode
                        regionCode:currentRegion.phoneCode completion:^(BOOL ret) {
        [self hideLoading];
    }];
}

#pragma mark - Timer

- (void)countDown:(int)seconds {
    self.seconds = seconds;
    [self startCountDownTimer];
    self.loginView.buttonVerify.enabled = NO;

}
- (void)timeFireMethod {
    self.seconds--;
    NSString *title = [NSString stringWithFormat:RCDLocalizedString(@"after_x_seconds_send"), self.seconds];
    if (self.seconds == 0) {
        [self stopCountDownTimerIfNeed];
        self.loginView.buttonVerify.enabled = YES;
        title = RCDLocalizedString(@"send_verification_code");
    }
    [self.loginView.buttonVerify setTitle:title forState:UIControlStateNormal];

}

- (void)dealloc
{
    
}
- (void)startCountDownTimer {
    [self stopCountDownTimerIfNeed];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(timeFireMethod)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)stopCountDownTimerIfNeed {
    if (self.countDownTimer && self.countDownTimer.isValid) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
    self.loginView.buttonVerify.enabled = YES;
    [self.loginView.buttonVerify setTitle:RCDLocalizedString(@"send_verification_code") forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == self.loginView.txtPhoneNum) {
        self.loginView.buttonVerify.enabled = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"registrationterms"]) {
        //《注册条款》点击事件
        RCDRegistrationAgreementController *vc = [[RCDRegistrationAgreementController alloc] init];
        // 创建URL
        NSURL * url = [NSURL URLWithString:@"https://www.wegenmi.com/terms-of-service"];
        vc.url = url;
        vc.webViewTitle = RCDLocalizedString(@"Registration_Terms");
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    else if ([[URL scheme] isEqualToString:@"privacypolicy"]) {
        //《隐私政策》点击事件
        RCDRegistrationAgreementController *vc = [[RCDRegistrationAgreementController alloc] init];
        // 创建URL
        NSString *urlStr = [NSString stringWithFormat:RCDLocalizedString(@"Privacy_Policy_URL_Format"), @"https://www.wegenmi.com"];
        vc.url = [NSURL URLWithString:urlStr];
        vc.webViewTitle = RCDLocalizedString(@"Privacy_Policy");
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}


- (RCNDLoginView *)loginView {
    if (!_loginView) {
        _loginView = [RCNDLoginView new];

        [_loginView.buttonLanguage addTarget:self
                           action:@selector(didTapSwitchLanguage:)
                 forControlEvents:(UIControlEventTouchUpInside)];
        [_loginView.buttonLogin addTarget:self action:@selector(didTapLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_loginView.buttonPhotoVerify addTarget:self
                                         action:@selector(refreshPictureVerificationCode)
                               forControlEvents:UIControlEventTouchUpInside];
        [_loginView.buttonVerify addTarget:self
                                         action:@selector(sendVerifyCode)
                               forControlEvents:UIControlEventTouchUpInside];
        
        [_loginView.txtPhoneNum addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    }
    return _loginView;
}

@end
