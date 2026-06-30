//
//  RCNDLoginViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDLoginViewModel.h"
#import "RCDLoginManager.h"
#import "RCDCommonString.h"
#import "RCDUserInfoManager.h"
#import "AppDelegate.h"
#import "RCDBuglyManager.h"
#import "RCDRCIMDataSource.h"

@interface RCNDLoginViewModel()
@property (nonatomic, copy) NSString *codeID;
@end
@implementation RCNDLoginViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self ready];
    }
    return self;
}

- (void)ready {
    
}

- (NSString *)currentPhoneNumber {
    NSString *string = [DEFAULTS objectForKey:RCDPhoneKey];
    return string;
}

- (void)getVerifyCode:(NSString *)phoneCode
          phoneNumber:(NSString *)phoneNumber
            photoCode:(NSString *)photoCode
           completion:(void(^)(BOOL ret))completion
{
    RCNetworkStatus status = [[RCCoreClient sharedCoreClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        [self showTips:RCDLocalizedString(@"network_can_not_use_please_check")];
        if (completion) {
            completion(NO);
        }
        return;
    }
    [RCDLoginManager getVerificationCode:phoneCode phoneNumber:phoneNumber
     pictureCode:[photoCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] pictureCodeId:self.codeID success:^(BOOL success) {
            rcd_dispatch_main_async_safe(^{
                if (completion) {
                    completion(YES);
                }
            });
        }
        error:^(RCDLoginErrorCode errorCode, NSString *_Nonnull errorMsg) {
        if (completion) {
            completion(NO);
        }
            rcd_dispatch_main_async_safe(^{
                if (errorCode == RCDLoginErrorCodeParameterError) {
                    [self showTips:RCDLocalizedString(@"phone_number_type_error")];
                } else if (errorCode == RCDLoginErrorCodeVerificationCodeFrequencyTransfinite){
                    [self showTips:RCDLocalizedString(@"verification_code_send_over_limit")];
                } else if (errorCode == RCDLoginErrorCodeVerificationCodeError) {
                    [self showTips:RCDLocalizedString(@"picture_code_expired")];
                } else if(errorMsg){
                    [self showTips:errorMsg];
                } else{
                    [self showTips:RCDLocalizedString(@"failed")];
                }
            });
        }];
}

- (void)showTips:(NSString *)tips {
    if ([self.delegate respondsToSelector:@selector(showTips:)]) {
        [self.delegate showTips:tips];
    }
}

- (void)loginRongCloud:(NSString *)phone
            verifyCode:(NSString *)verifyCode
            regionCode:(NSString *)regionCode
            completion:(void(^)(BOOL))completion {
    [DEFAULTS removeObjectForKey:RCDUserCookiesKey];
    __weak typeof(self) weakSelf = self;
    [RCDLoginManager loginWithPhone:phone
                   verificationCode:verifyCode
                             region:regionCode
                            success:^(NSString * _Nonnull token, NSString * _Nonnull userId, NSString * _Nonnull nickName) {
        [weakSelf loginRongCloud:phone
                        userName:nickName
                          userId:userId
                           token:token
                      completion:^{
            if (completion) {
                completion(YES);
            }
        }];
    } error:^(RCDLoginErrorCode errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCode == RCDLoginErrorCodeVerificationCodeError) {
                [self showTips:RCDLocalizedString(@"verification_code_error")];
            }else if(errorCode == RCDLoginErrorCodeVerificationCodeExpired){
                [self showTips:RCDLocalizedString(@"captcha_overdue")];
            }else{
                [self showTips:[NSString stringWithFormat:@"%@ : %ld",RCDLocalizedString(@"Login_fail"),(long)errorCode]];
            }
            if (completion) {
                completion(NO);
            }
        });
    }];
}

- (void)loginRongCloud:(NSString *)phone
              userName:(NSString *)userName
                userId:(NSString *)userId
                 token:(NSString *)token
            completion:(void(^)(void)) completion {
    [self saveLoginData:phone
                 userId:userId
               userName:userName
                  token:token
             completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([appDelegate respondsToSelector:@selector(configureIMAndEnterHomeIfNeed)]) {
                [appDelegate performSelector:@selector(configureIMAndEnterHomeIfNeed)];
            }
            if (completion) {
                completion();
            }
        });
    }];
}


- (void)saveLoginData:(NSString *)phone
               userId:(NSString *)userId
             userName:(NSString *)userName
                token:(NSString *)token
           completion:(void(^)(void)) completion {
    //保存默认用户
    [DEFAULTS setObject:phone forKey:RCDPhoneKey];
    [DEFAULTS setObject:token forKey:RCDIMTokenKey];
    [DEFAULTS setObject:userId forKey:RCDUserIdKey];
    [RCDNotificationServiceDefaults setValue:token forKey:RCDIMTokenKey];
    [DEFAULTS synchronize];
    
    [RCDUserInfoManager
        getUserInfoFromServer:userId
                     complete:^(RCDUserInfo *userInfo) {
                         [RCDBuglyManager
                             setUserIdentifier:[NSString stringWithFormat:@"%@ - %@", userInfo.userId, userInfo.name]];
                         [RCIM sharedRCIM].currentUserInfo = userInfo;
                         [DEFAULTS setObject:userInfo.portraitUri forKey:RCDUserPortraitUriKey];
                         [DEFAULTS setObject:userInfo.name forKey:RCDUserNickNameKey];
                         [DEFAULTS setObject:userInfo.stAccount forKey:RCDSealTalkNumberKey];
                         [DEFAULTS setObject:userInfo.gender forKey:RCDUserGenderKey];
                         [DEFAULTS synchronize];
        if (completion) {
            completion();
        }
                     }];
    //同步群组
    [RCDDataSource syncAllData];
}

- (void)refreshPictureVerificationCode:(void(^)(BOOL ret, UIImage * __nullable  image))completion {
    __weak typeof(self) weakSelf = self;

    [RCDLoginManager getPictureVerificationCode:^(NSString * _Nonnull base64String, NSString * _Nonnull codeId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *img = [weakSelf getImageVerification:base64String];;
            weakSelf.codeID = codeId;
            if (completion) {
                completion(YES, img);
            }
        });
    } error:^(RCDLoginErrorCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(NO, nil);
            }
            weakSelf.codeID = @"";
        });
    }];
}

- (UIImage *)getImageVerification:(NSString *)base64String{
    if (base64String) {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String
                                                            options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [UIImage imageWithData:imageData];
    }
    return nil;
}

@end
