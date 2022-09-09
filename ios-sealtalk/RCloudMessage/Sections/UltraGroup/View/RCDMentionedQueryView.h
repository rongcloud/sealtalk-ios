//
//  RCDMentionedQueryView.h
//  SealTalk
//
//  Created by RobinCui on 2022/8/3.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDMentionedQueryView : UIView
@property (nonatomic, strong, readonly) UIButton *btnQuery;
@property (nonatomic, strong, readonly) UITextField *txtTargetID;
@property (nonatomic, strong, readonly) UITextField *txtChannelID;
@property (nonatomic, strong, readonly) UITextField *txtTime;
@property (nonatomic, strong, readonly) UITextField *txtCount;
@property (nonatomic, strong, readonly) UILabel *labTips;

- (void)hideKeyboardIfNeed;
@end

NS_ASSUME_NONNULL_END
