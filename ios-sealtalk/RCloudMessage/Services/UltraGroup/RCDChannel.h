//
//  RCDChannel.h
//  SealTalk
//
//  Created by 张改红 on 2022/1/26.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDChannel : NSObject

@property (nonatomic, copy) NSString *channelId;

@property (nonatomic, copy) NSString *channelName;

@property (nonatomic, assign) NSInteger type;
@end

NS_ASSUME_NONNULL_END
