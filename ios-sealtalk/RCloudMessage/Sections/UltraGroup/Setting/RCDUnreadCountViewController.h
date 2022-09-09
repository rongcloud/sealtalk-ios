//
//  RCDUnreadCountViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/8/2.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDUnreadCountViewController : UIViewController
@property (nonatomic, assign, getter=isUltraGroup) BOOL ultraGroup;
@property (nonatomic, assign, getter=isMentioned) BOOL mentioned;

@end

NS_ASSUME_NONNULL_END
