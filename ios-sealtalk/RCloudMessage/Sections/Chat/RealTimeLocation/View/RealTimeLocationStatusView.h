//
//  RealTimeLocationStatusView.h
//  LocationSharer
//
//  Created by litao on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <RongLocation/RongLocation.h>
#import <RongIMKit/RongIMKit.h>

@protocol RealTimeLocationStatusViewDelegate <NSObject>

- (void)onJoin;
- (void)onShowRealTimeLocationView;
- (RCRealTimeLocationStatus)getStatus;
@end

@interface RealTimeLocationStatusView : RCBaseView
@property (nonatomic, weak) id<RealTimeLocationStatusViewDelegate> delegate;
- (void)updateText:(NSString *)statusText;
- (void)updateRealTimeLocationStatus;
@end
