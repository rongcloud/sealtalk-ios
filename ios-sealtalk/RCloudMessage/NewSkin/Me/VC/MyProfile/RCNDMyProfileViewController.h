//
//  RCNDMyProfileViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@protocol RCNDMyProfileDelegate <NSObject>

- (void)refreshPortrait:(NSString *)url;

@end
NS_ASSUME_NONNULL_BEGIN

@interface RCNDMyProfileViewController : RCProfileViewController
@property (nonatomic, weak) id<RCNDMyProfileDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
