//
//  RCDTranslationManager.m
//  SealTalk
//
//  Created by RobinCui on 2022/2/22.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDTranslationManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "RCDEnvironmentContext.h"
#import "RCDHTTPUtility.h"

static NSString * const RCDTranslationKeyCode = @"code";
static NSString * const RCDTranslationKeyToken = @"token";
NSInteger const RCDTranslationKeySuccess = 200;
@implementation RCDTranslationManager

+ (void)requestTranslationTokenUserID:(NSString *)userID
                            success:(void(^)(NSString *))success
                            failure:(void(^)(NSInteger))failure
{
    if (!userID) {
        if (failure) {
            failure(-1);
        }
        return;
    }
    NSString *baseURL = [RCDEnvironmentContext serverURL];
    NSString *urlString = [NSString stringWithFormat:@"user/getJwtToken?userId=%@", userID];
    urlString = [baseURL stringByAppendingPathComponent:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    NSURLSessionConfiguration *config = [RCDHTTPUtility rcSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue currentQueue]];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self analyzeData:data error:error success:success failure:failure];
    }];
    [task resume];
}

+ (void)analyzeData:(NSData *)data
              error:(NSError *)error
            success:(void(^)(NSString *))success
            failure:(void(^)(NSInteger))failure {
    if (error) {
        if (failure) {
            failure(error.code);
        }
        return;
    }
    
    NSError *err;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) { // 服务器数据序列化失败
        if (failure) {
            failure(err.code);
        }
        return;
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)obj;
        NSInteger code = [dic[RCDTranslationKeyCode] integerValue];
        if (code == RCDTranslationKeySuccess) {
            NSString *text = dic[RCDTranslationKeyToken];
            if (success) { // 成功
                success(text);
            }
        } else {
            if (failure) { // 失败
                failure(code);
            }
        }
    } else { // 服务器数据不是字典
        if (failure) {
            failure(-1);
        }
    }
}

@end
