//
//  RCDUGSelectListViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/8/2.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDUltraGroupManager.h"
NS_ASSUME_NONNULL_BEGIN

@protocol RCDUGSelectListViewControllerDelegate <NSObject>

- (void)userDidSelected:(NSString *)conversationName
               targetID:(NSString *)targetID
            channelName:(NSString *)channelName
              channelID:(NSString *)channelID;

@end

@interface RCDUGSelectListViewController : UIViewController
@property (nonatomic, weak) id<RCDUGSelectListViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
