//
//  RCNDLoginViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol RCNDLoginViewModelDelegate <NSObject>

- (void)showTips:(NSString *)tips;

@end
@interface RCNDLoginViewModel : RCNDBaseViewModel
@property (nonatomic, weak) id<RCNDLoginViewModelDelegate> delegate;
- (void)refreshPictureVerificationCode:(void(^)(BOOL ret, UIImage * __nullable  image))completion;

- (void)getVerifyCode:(NSString *)phoneCode
          phoneNumber:(NSString *)phoneNumber
            photoCode:(NSString *)photoCode
           completion:(void(^)(BOOL ret))completion;

- (void)loginRongCloud:(NSString *)phone
            verifyCode:(NSString *)verifyCode
            regionCode:(NSString *)regionCode
            completion:(void(^)(BOOL))completion;

- (NSString *)currentPhoneNumber;
@end

NS_ASSUME_NONNULL_END
