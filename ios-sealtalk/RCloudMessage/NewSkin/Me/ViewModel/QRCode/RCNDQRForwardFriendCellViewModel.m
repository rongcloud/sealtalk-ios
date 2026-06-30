//
//  RCNDQRForwardFriendCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardFriendCellViewModel.h"

@implementation RCNDQRForwardFriendCellViewModel
- (void)fetchData:(void(^)(void))completion {
    self.title = self.info.name;
    self.portraitURL = self.info.portraitUri;
    self.targetID = self.info.userId;
    self.conversationType = ConversationType_PRIVATE;
    if (completion) {
        completion();
    }
}
@end
