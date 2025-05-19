//
//  RCDAgentSettingSwitchCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/14.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentSettingSwitchCellViewModel.h"
#import "RCDAgentContext.h"

@implementation RCDAgentSettingSwitchCellViewModel
- (CGFloat)cellHeight {
    return 70;
}

- (instancetype)initWithStyle:(RCDAgentSettingSwitchCellStyle)style
                   identifier:(RCConversationIdentifier*)identifier
{
    self = [super init];
    if (self) {
        self.style = style;
        self.identifier = identifier;
        [self fetchStatus];
    }
    return self;
}

- (void)fetchStatus {
    NSString *key = nil;
    if (self.style == RCDAgentSettingSwitchCellStyleAgent) {
        key = RCDAgentEnableKey;
    } else if (self.style == RCDAgentSettingSwitchCellStyleHistory) {
        key = RCDAgentMessageAuthKey;
    }
    BOOL ret = [RCDAgentContext isAbilityValidForKey:key];
    self.enable = ret;
}

- (void)switchValueChanged:(BOOL)value {
    NSString *key = nil;
    if (self.style == RCDAgentSettingSwitchCellStyleAgent) {
        key = RCDAgentEnableKey;
    } else if (self.style == RCDAgentSettingSwitchCellStyleHistory) {
        key = RCDAgentMessageAuthKey;
    }
    [RCDAgentContext updateAbilityFor:key result:value];
}

- (NSString *)title {
    if (!_title) {
        if (self.style == RCDAgentSettingSwitchCellStyleHistory) {
            _title = RCDLocalizedString(@"agent_message_access_auth");
        } else {
            _title = RCDLocalizedString(@"agent_switch");
        }
    }
    return _title;
}

- (NSString *)subtitle {
    if (!_subtitle) {
        if (self.style == RCDAgentSettingSwitchCellStyleHistory) {
            _subtitle = RCDLocalizedString(@"agent_message_access_auth_tips");
        } else {
            _subtitle = RCDLocalizedString(@"agent_switch_tips");
        }
    }
    return _subtitle;
}
@end
