//
//  RCDReceiptDetailsMessageView.h
//  SealTalk
//
//  Created by Lang on 10/16/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RCBaseView.h>
#import <RongIMKit/RCMessageModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDReceiptDetailsMessageView : RCBaseView

@property (nonatomic, strong) RCMessageModel *message;

@end

NS_ASSUME_NONNULL_END
