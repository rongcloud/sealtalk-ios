//
//  RCDDebugSliceResumeDownloadVC.h
//  SealTalk
//
//  Created by Lang on 2023/9/7.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDDebugSliceResumeDownloadVC : RCDViewController

@property (nonatomic, strong) RCMessageModel *messageModel;
@property (nonatomic, copy) void (^playAction)(RCMessageModel *model);

@end

NS_ASSUME_NONNULL_END
