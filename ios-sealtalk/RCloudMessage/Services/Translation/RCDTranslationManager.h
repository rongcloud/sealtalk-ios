//
//  RCDTranslationManager.h
//  SealTalk
//
//  Created by RobinCui on 2022/2/22.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDTranslationManager : NSObject
+ (void)requestTranslationTokenUserID:(NSString *)userID
                            success:(void(^)(NSString *))success
                            failure:(void(^)(NSInteger))failure;
@end

NS_ASSUME_NONNULL_END
