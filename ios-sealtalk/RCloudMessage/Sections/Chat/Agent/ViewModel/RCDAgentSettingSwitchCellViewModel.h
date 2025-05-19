//
//  RCDAgentSettingSwitchCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/14.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentSettingCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCDAgentSettingSwitchCellStyle) {
    RCDAgentSettingSwitchCellStyleNone,
    RCDAgentSettingSwitchCellStyleHistory,
    RCDAgentSettingSwitchCellStyleAgent
};

@interface RCDAgentSettingSwitchCellViewModel : RCDAgentSettingCellViewModel
@property (nonatomic, assign) RCDAgentSettingSwitchCellStyle style;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, strong) RCConversationIdentifier *identifier;

- (instancetype)initWithStyle:(RCDAgentSettingSwitchCellStyle)style
                   identifier:(RCConversationIdentifier*)identifier;
- (void)switchValueChanged:(BOOL)value;
@end

NS_ASSUME_NONNULL_END
