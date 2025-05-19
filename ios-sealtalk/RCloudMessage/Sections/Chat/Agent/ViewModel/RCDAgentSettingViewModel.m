//
//  RCDAgentSettingViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/14.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentSettingViewModel.h"
#import "RCDAgentSettingSwitchCellViewModel.h"
#import "RCDAgentTagCollectionViewModel.h"

@implementation RCDAgentSettingViewModel

- (instancetype)initWithIdentifier:(RCConversationIdentifier*)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        [self fetchData:identifier];
    }
    return self;
}

- (void)fetchData:(RCConversationIdentifier*)identifier {
    RCDAgentTagCollectionViewModel *tagVM = [[RCDAgentTagCollectionViewModel alloc] initWithIdentifier:identifier];
    
    RCDAgentSettingSwitchCellViewModel *msgVM = [[RCDAgentSettingSwitchCellViewModel alloc] initWithStyle:RCDAgentSettingSwitchCellStyleHistory
                                                                                               identifier:self.identifier];
    
    RCDAgentSettingSwitchCellViewModel *agentVM = [[RCDAgentSettingSwitchCellViewModel alloc] initWithStyle:RCDAgentSettingSwitchCellStyleAgent
                                                                                                 identifier:self.identifier];
    self.dataSource = @[@[tagVM], @[msgVM, agentVM]];
}
@end
