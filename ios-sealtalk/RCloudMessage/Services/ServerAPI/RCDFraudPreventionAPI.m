//
//  RCDFraudPreventionAPI.m
//  SealTalk
//
//  Created by lizhipeng on 2022/5/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDFraudPreventionAPI.h"
#import "RCDHTTPUtility.h"

@implementation RCDFraudPreventionAPI

+ (void)fraudPreventionStatusSuccess:(void (^)(BOOL))successBlock error:(void (^)(NSInteger))errorBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"shumei/status"
                               parameters:nil
                                 response:^(RCDHTTPResult *_Nonnull result) {
        if (result.success) {
            BOOL openEnable = result.content[@"openEnable"] ;
            if (successBlock) {
                successBlock(openEnable);
            }
        } else {
            if (errorBlock) {
                errorBlock(result.errorCode);
            }
        }
    }];
}

+ (void)fraudPreventionVerifyWithPhone:(NSString *)phone
                                region:(NSString *)region
                              deviceId:(NSString *)deviceId
                               success:(void (^)(RCDFraudPreventionRiskLevelCode code))successBlock
                                 error:(void (^)(NSInteger code))errorBlock {
    NSDictionary *params = @{ @"region" : region,
                              @"phone" : phone,
                              @"deviceId" : deviceId,
                              @"os": @"ios" };
    
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"/shumei/verify"
                               parameters:params
                                 response:^(RCDHTTPResult *_Nonnull result) {
        if (result.success) {
            NSString *riskLevelString = result.content[@"riskLevel"] ;
            RCDFraudPreventionRiskLevelCode code ;
            if ([riskLevelString isEqualToString:@"PASS"])
                code = RCDFraudPreventionRiskLevelCodePASS;
            else if ([riskLevelString isEqualToString:@"REVIEW"])
                code = RCDFraudPreventionRiskLevelCodeREVIEW;
            else if ([riskLevelString isEqualToString:@"REJECT"])
                code = RCDFraudPreventionRiskLevelCodeREJECT;
            else if ([riskLevelString isEqualToString:@"VERIFY"])
                code = RCDFraudPreventionRiskLevelCodeVERIFY;
            else
                code = RCDFraudPreventionRiskLevelCodeUnknown;
            if (successBlock) {
                successBlock(code);
            }
        } else {
            if (errorBlock) {
                errorBlock(result.errorCode);
            }
        }
    }];
}

@end
