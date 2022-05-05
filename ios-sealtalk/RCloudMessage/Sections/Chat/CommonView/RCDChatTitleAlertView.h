//
//  RCDTitleAlertView.h
//  SealTalk
//
//  Created by lizhipeng on 2022/4/18.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDChatTitleAlertView : UIView

- (instancetype)initWithFrame:(CGRect)frame titleAlertMessage:(NSString *)message ;

- (instancetype)initWithTitleAlertMessage:(NSString *)message ;

@end

NS_ASSUME_NONNULL_END
