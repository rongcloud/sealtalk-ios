//
//  RCDOpenClawCreateBotViewModel.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawCreateBotViewModel.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotAPI.h"
#import "RCDOpenClawBotManager.h"
#import "RCDUploadManager.h"

@interface RCDOpenClawCreateBotViewModel ()

@property (nonatomic, copy) NSString *portraitUri;

@end

@implementation RCDOpenClawCreateBotViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _portraitUri = [RCDOpenClawBotManager defaultPortraitUri];
    }
    return self;
}

- (NSString *)defaultPortraitUri {
    return [RCDOpenClawBotManager defaultPortraitUri];
}

- (void)useDefaultPortrait {
    self.portraitUri = [self defaultPortraitUri];
}

- (BOOL)isValidName:(NSString *)name {
    NSString *normalizedName = [self normalizedName:name];
    return normalizedName.length >= 2 && normalizedName.length <= 10;
}

- (NSString *)normalizedName:(NSString *)name {
    return [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"";
}

- (void)uploadAvatarImage:(UIImage *)image
                  success:(void (^)(NSString *portraitUri))success
                  failure:(void (^)(NSString *message))failure {
    NSData *data = UIImageJPEGRepresentation(image, 0.75);
    [RCDUploadManager uploadImage:data complete:^(NSString *url) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (url.length > 0) {
                self.portraitUri = url;
                if (success) {
                    success(url);
                }
            } else {
                [self useDefaultPortrait];
                if (failure) {
                    failure(RCDLocalizedString(@"OpenClawUploadAvatarFailedDefault"));
                }
            }
        });
    }];
}

- (void)createBotWithName:(NSString *)name
                  success:(RCDOpenClawBotViewModelSuccessBlock)success
                    error:(RCDOpenClawViewModelErrorBlock)error {
    NSString *normalizedName = [self normalizedName:name];
    [RCDOpenClawBotAPI createBotWithName:normalizedName portraitUri:self.portraitUri success:^(RCDOpenClawBot *bot) {
        [RCDOpenClawBotManager cacheBot:bot];
        if (success) {
            success(bot);
        }
    } error:error];
}

@end
