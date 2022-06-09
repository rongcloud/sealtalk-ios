//
//  UIButton+AlertActionHandler.h
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RCDAlertAction ;

@interface UIButton (AlertAction)

@property(nonatomic, strong)RCDAlertAction *action  ;

@end

NS_ASSUME_NONNULL_END
