//
//  RCNDQRForwardGroupCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardGroupCellViewModel.h"

@implementation RCNDQRForwardGroupCellViewModel
- (void)fetchData:(void(^)(void))completion {
    self.title = self.info.groupName;
    self.portraitURL = self.info.portraitUri;
    self.targetID = self.info.groupId;
    self.conversationType = ConversationType_GROUP;
    if (completion) {
        completion();
    }
}
@end
