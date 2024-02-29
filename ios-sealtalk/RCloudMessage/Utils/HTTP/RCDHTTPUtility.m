//
//  RCDHTTPUtility.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDHTTPUtility.h"
#import "RCDCommonString.h"
#import <AFNetworking/AFNetworking.h>
#import "RCDCommonDefine.h"
#import "RCDEnvironmentContext.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import <SDWebImage/SDWebImage.h>

#define HTTP_SUCCESS 200

//NSString *const BASE_URL = DEMO_SERVER;

static AFHTTPSessionManager *manager;

@implementation RCDHTTPUtility

+ (AFHTTPSessionManager *)sharedHTTPManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [self resetHTTPManager];
    });
    return manager;
}

+ (void)requestWithHTTPMethod:(HTTPMethod)method
                    URLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                     response:(void (^)(RCDHTTPResult *))responseBlock {
    
    AFHTTPSessionManager *manager = [RCDHTTPUtility sharedHTTPManager];
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *baseURL = [RCDEnvironmentContext serverURL];
    NSString *url = [baseURL stringByAppendingPathComponent:URLString];
    NSString *cookie = [DEFAULTS valueForKey:RCDUserCookiesKey];
    if (cookie && cookie.length > 0) {
        [manager.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
    }
    switch (method) {
    case HTTPMethodGet: {
        [manager GET:url
            parameters:parameters
            headers:nil
            progress:nil
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"GET url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task error:error]);
                }
            }];
        break;
    }

    case HTTPMethodHead: {
        [manager HEAD:url
            parameters:parameters
            headers:nil
            success:^(NSURLSessionDataTask *_Nonnull task) {
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:nil]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"HEAD url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task error:error]);
                }
            }];
        break;
    }

    case HTTPMethodPost: {
        [manager POST:url
            parameters:parameters
            headers:nil
            progress:nil
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                [self saveCookieIfHave:task];
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"POST url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task error:error]);
                }
            }];
        break;
    }

    case HTTPMethodPut: {
        [manager PUT:url
            parameters:parameters
            headers:nil
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"PUT url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task error:error]);
                }
            }];
        break;
    }

    case HTTPMethodDelete: {
        [manager DELETE:url
            parameters:parameters
            headers:nil
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"DELETE url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task error:error]);
                }
            }];
        break;
    }

    default:
        break;
    }
}

+ (RCDHTTPResult *)httpSuccessResult:(NSURLSessionDataTask *)task response:(id)responseObject {
    RCDHTTPResult *result = [[RCDHTTPResult alloc] init];
    result.httpCode = ((NSHTTPURLResponse *)task.response).statusCode;

    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        result.errorCode = [responseObject[@"code"] integerValue];
        result.content = responseObject[@"result"];
        result.success = (result.errorCode == HTTP_SUCCESS);
        if (!result.success) {
            NSLog(@"%@, {%@}", task.currentRequest.URL, result);
        }
    } else {
        result.success = NO;
    }

    return result;
}

+ (RCDHTTPResult *)httpFailureResult:(NSURLSessionDataTask *)task error:(NSError *)error{
    RCDHTTPResult *result = [[RCDHTTPResult alloc] init];
    result.success = NO;
    result.httpCode = ((NSHTTPURLResponse *)task.response).statusCode;
    result.errorCode = result.httpCode;
    NSLog(@"%@, {%@}", task.currentRequest.URL, result);
    
    BOOL isPicVer = [task.currentRequest.URL.absoluteString containsString:@"user/pic_code"];
    
    //权限校验失败(未登录或登录凭证失效)
    if (result.httpCode == 403 && !isPicVer) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                result.errorCode = [dic[@"code"] integerValue];
                result.content = dic[@"msg"];
                if (result.errorCode == 10000) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:RCDLoginCookieExpiredNotification object:nil];
                }
            }
        }
    }
    return result;
}

+ (void)saveCookieIfHave:(NSURLSessionDataTask *)task {
    NSString *cookieString = [[(NSHTTPURLResponse *)task.response allHeaderFields] valueForKey:@"Set-Cookie"];
    NSMutableString *finalCookie = [NSMutableString new];
    NSArray *cookieStrings = [cookieString componentsSeparatedByString:@","];
    for (NSString *temp in cookieStrings) {
        NSArray *tempArr = [temp componentsSeparatedByString:@";"];
        [finalCookie appendString:[NSString stringWithFormat:@"%@;", tempArr[0]]];
    }
    if (finalCookie.length > 0) {
        [DEFAULTS setObject:finalCookie forKey:RCDUserCookiesKey];
        [DEFAULTS synchronize];
        [[RCDHTTPUtility sharedHTTPManager].requestSerializer setValue:finalCookie forHTTPHeaderField:@"Cookie"];
    }
}

+ (NSURLSessionConfiguration *)rcSessionConfiguration {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    RCIMProxy *currentProxy = [[RCCoreClient sharedCoreClient] getCurrentProxy];
    
    if (currentProxy && [currentProxy isValid]) {
        NSString *proxyHost = currentProxy.host;
        NSNumber *proxyPort = @(currentProxy.port);
        NSString *proxyUserName = currentProxy.userName;
        NSString *proxyPassword = currentProxy.password;

        NSDictionary *proxyDict = @{
            (NSString *)kCFStreamPropertySOCKSProxyHost: proxyHost,
            (NSString *)kCFStreamPropertySOCKSProxyPort: proxyPort,
            (NSString *)kCFStreamPropertySOCKSUser : proxyUserName,
            (NSString *)kCFStreamPropertySOCKSPassword: proxyPassword
        };

        sessionConfiguration.connectionProxyDictionary = proxyDict;
    }
    return sessionConfiguration;
}

// 全局配置 SDWebImage， 允许使用代理模式加载图片
+ (void)configProxySDWebImage {
    // 由于单例模式， 需要手动重置代理配置
    [self resetHTTPManager];
    
    SDWebImageDownloaderConfig *config = [SDWebImageDownloaderConfig defaultDownloaderConfig];
    config.sessionConfiguration = [self rcSessionConfiguration];
    SDWebImageDownloader *imageDownloader = [[SDWebImageDownloader alloc] initWithConfig:config];
    SDWebImageManager.defaultImageLoader = imageDownloader;
}

// 重试初始化 AFHTTPSessionManager
+ (void)resetHTTPManager {
    manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[self rcSessionConfiguration]];
    manager.completionQueue = dispatch_queue_create("cn.rongcloud.sealtalk.httpqueue", DISPATCH_QUEUE_SERIAL);
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.validatesDomainName = NO;
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    manager.requestSerializer.HTTPShouldHandleCookies = YES;
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    ((AFJSONResponseSerializer *)manager.responseSerializer).removesKeysWithNullValues = YES;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
}

@end
