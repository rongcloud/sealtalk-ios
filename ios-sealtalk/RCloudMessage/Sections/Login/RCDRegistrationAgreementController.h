//
//  RCDRegistrationAgreementController.h
//  SealTalk
//
//  Created by 张改红 on 2021/3/30.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDRegistrationAgreementController : UIViewController
@property (nonatomic, strong) NSURL * url;
@property (nonatomic, copy) NSString * webViewTitle;
@property (nonatomic, assign)  BOOL needInjectJSFontSize;
@end

NS_ASSUME_NONNULL_END
