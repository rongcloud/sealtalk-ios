//
//  RCDUltraModel.m
//  SealTalk
//
//  Created by 张改红 on 2022/1/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUltraGroup.h"

@implementation RCDUltraGroup
- (instancetype)initWithJson:(NSDictionary *)json{
    if (self = [super init]) {
        self.groupId = [json objectForKey:@"groupId"];
        self.groupName = [json objectForKey:@"groupName"];
        self.portraitUri = [json objectForKey:@"portraitUri"];
        self.creatorId = [json objectForKey:@"creatorId"];
        self.summary = [json objectForKey:@"summary"];
    }
    return self;
}
@end
