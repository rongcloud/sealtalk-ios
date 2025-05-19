//
//  RCDAgentTag.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentTag.h"

@implementation RCDAgentTag

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.name = dic[@"name"];
        self.agentID = dic[@"agentId"];
    }
    return self;
}

- (NSDictionary *)dictionaryInfo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"name"] = self.name;
    dic[@"agentId"] = self.agentID;
    return dic;
}
@end
