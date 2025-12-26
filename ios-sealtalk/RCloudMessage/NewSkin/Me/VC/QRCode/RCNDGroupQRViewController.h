//
//  RCNDGroupQRViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRCodeViewController.h"
#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCNDGroupQRViewController : RCNDQRCodeViewController
- (instancetype)initWithGroupID:(NSString *)groupId;
@end

NS_ASSUME_NONNULL_END
