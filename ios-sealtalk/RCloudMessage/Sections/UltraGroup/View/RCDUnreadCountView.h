//
//  RCDUnreadCountView.h
//  SealTalk
//
//  Created by RobinCui on 2022/8/2.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDUnreadCountView : UIView
@property (nonatomic, strong, readonly) UIButton *btnQuery;

- (void)showCount:(NSInteger)count;
- (void)showTypes:(NSString *)text;
- (void)showLevels:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
