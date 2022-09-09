//
//  RCDMentionedView.h
//  SealTalk
//
//  Created by RobinCui on 2022/8/3.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDMentionedView : UIView
@property (nonatomic, strong, readonly) UIButton *btnQuery;
@property (nonatomic, strong, readonly) UITextField *txtTargetID;
@property (nonatomic, strong, readonly) UITextField *txtChannelID;
@property (nonatomic, strong, readonly) UITextField *txtTime;
@property (nonatomic, strong, readonly) UITextField *txtCount;
@property (nonatomic, strong, readonly) UITableView *tableView;

- (void)showResult:(BOOL)show;
- (void)showTips:(NSString *)tips;
- (void)cleanTips;
@end

NS_ASSUME_NONNULL_END
