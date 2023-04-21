//
//  RCDLoginManager.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDLoginManager.h"
#import "RCDDBManager.h"
#import "RCDCommonString.h"
#import "RCDCountry.h"

static NSString *const RongCloud = @"RongCloud";
static NSString *const DBName = @"SealTalkDB";

@implementation RCDLoginManager
+ (void)loginWithPhone:(NSString *)phone
      verificationCode:(NSString *)verificationCode
                region:(NSString *)region
               success:(void (^)(NSString *token, NSString *userId, NSString *nickName))successBlock
                 error:(void (^)(RCDLoginErrorCode errorCode))errorBlock{
    [RCDLoginAPI loginWithPhone:phone verificationCode:verificationCode region:region success:^(NSString *token, NSString *userId, NSString *nickName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openDB:userId];
        });
        if (successBlock) {
            successBlock(token, userId, nickName);
        }
    } error:errorBlock];
}

+ (void)logout:(void (^)(BOOL))completeBlock {
    [RCDLoginAPI logout:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RCDDBManager closeDB];
            });
        }
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}

+ (void)removeAccount:(void (^)(BOOL success))completeBlock{
    [RCDLoginAPI removeAccount:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeDB];
            });
        }
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}

+ (BOOL)openDB:(NSString *)currentUserId {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:RongCloud]
        stringByAppendingPathComponent:currentUserId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }

    dbPath = [dbPath stringByAppendingPathComponent:DBName];
    return [RCDDBManager openDB:dbPath];
}

+ (BOOL)removeDB{
    NSString *currentUserId = [RCCoreClient sharedCoreClient].currentUserInfo.userId;
    if (!currentUserId) {
        return NO;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:RongCloud]
        stringByAppendingPathComponent:currentUserId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    }
    return YES;
}

+ (void)getPictureVerificationCode:(void (^)(NSString *base64String, NSString *codeId))successBlock
                             error:(void (^)(RCDLoginErrorCode code))errorBlock{
    [RCDLoginAPI getPictureVerificationCode:successBlock error:errorBlock];
}

+ (void)getVerificationCode:(NSString *)phoneCode
                phoneNumber:(NSString *)phoneNumber
                pictureCode:(nonnull NSString *)pictureCode
              pictureCodeId:(nonnull NSString *)pictureCodeId
                    success:(nonnull void (^)(BOOL))successBlock
                      error:(nonnull void (^)(RCDLoginErrorCode, NSString * _Nonnull))errorBlock{
    [RCDLoginAPI getVerificationCode:phoneCode phoneNumber:phoneNumber pictureCode:pictureCode pictureCodeId:pictureCodeId success:successBlock error:errorBlock];
}

+ (void)verifyVerificationCode:(NSString *)phoneCode
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(BOOL, NSString *_Nonnull))successBlock
                         error:(void (^)(RCDLoginErrorCode))errorBlock {

    [RCDLoginAPI verifyVerificationCode:phoneCode
                            phoneNumber:phoneNumber
                       verificationCode:verificationCode
                                success:successBlock
                                  error:errorBlock];
}

+ (void)getRegionlist:(void (^)(NSArray *_Nonnull))completeBlock {
    [RCDLoginAPI getRegionlist:^(NSArray *regionArray) {
        if (completeBlock) {
            NSMutableArray *countryArray = [NSMutableArray arrayWithCapacity:regionArray.count];
            for (NSDictionary *dict in regionArray) {
                RCDCountry *country = [[RCDCountry alloc] initWithDict:dict];
                [countryArray addObject:country];
            }
            completeBlock(countryArray);
        }
    }];
}

+ (void)getToken:(void (^)(BOOL, NSString *_Nonnull, NSString *_Nonnull))completeBlock {
    [RCDLoginAPI getToken:completeBlock];
}

@end
