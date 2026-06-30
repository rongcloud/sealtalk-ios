//
//  RCDContactCardMessageCellReferenceContentView.h
//  RCloudMessage
//
//  Created by RongCloud on 2026/6/15.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@class RCContactCardMessage;

@interface RCDContactCardMessageCellReferenceContentView : RCMessageCellReferenceContentView

@end

@interface RCDContactCardInputReferenceView : RCReferenceInputBarView

@property (nonatomic, copy) void (^cancelHandler)(void);

- (void)setContactCardMessage:(RCContactCardMessage *)message;

@end
