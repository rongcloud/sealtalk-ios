//
//  RCDOpenClawCreateBotViewModel.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCDOpenClawViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDOpenClawCreateBotViewModel : NSObject

@property (nonatomic, copy, readonly) NSString *portraitUri;

- (NSString *)defaultPortraitUri;
- (void)useDefaultPortrait;
- (BOOL)isValidName:(NSString *)name;
- (NSString *)normalizedName:(NSString *)name;
- (void)uploadAvatarImage:(UIImage *)image
                  success:(void (^)(NSString *portraitUri))success
                  failure:(void (^)(NSString *message))failure;
- (void)createBotWithName:(NSString *)name
                  success:(RCDOpenClawBotViewModelSuccessBlock)success
                    error:(RCDOpenClawViewModelErrorBlock)error;

@end

NS_ASSUME_NONNULL_END
