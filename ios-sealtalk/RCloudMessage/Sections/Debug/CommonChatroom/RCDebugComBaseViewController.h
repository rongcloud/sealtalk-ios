//
//  RCDebugComBaseViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/4/12.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import <Masonry/Masonry.h>
#import <GCDWebServer/GCDWebUploader.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCDebugComBaseViewController : UIViewController
@property (nonatomic, strong) NSString *targetId;

@property (nonatomic, strong) NSString *channelId;

@property (nonatomic, assign) RCConversationType type;
- (void)showLoading;
- (void)loadingFinished;
@end

NS_ASSUME_NONNULL_END
