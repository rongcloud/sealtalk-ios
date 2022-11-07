//
//  RCDAllConversationViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/9/23.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDConversationItem : NSObject
@property (nonatomic, assign) RCConversationType type;
@property (nonatomic, copy) NSString *targetID;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, copy) NSString *title;

@end


@protocol RCDConversationSelectorDelegate <NSObject>

- (void)conversationDidSelected:(RCDConversationItem *)item;

@end
@interface RCDAllConversationViewController : UIViewController
@property (nonatomic, weak) id<RCDConversationSelectorDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
