//
//  RCDFraudPreventionManager.m
//  SealTalk
//
//  Created by lizhipeng on 2022/5/18.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDFraudPreventionManager.h"
#import "RCDFraudPreventionAPI.h"
#import "RCDSMSDKHelper.h"

@interface RCDFraudPreventionManager ()

@property (nonatomic, assign)RCDFraudPreventionRiskLevelCode code ;
@property (nonatomic, assign)BOOL openEnable ;

@end

static RCDFraudPreventionManager *_manager ;
@implementation RCDFraudPreventionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[RCDFraudPreventionManager alloc] init];
    });
    return _manager ;
}

// 外层业务处理，此接口只处理是否为拒绝状态。
- (void)reqestFrandPreventionRiskLevelREJECTWithPhone:(NSString *)phone withRegion:(NSString *)region complate:(void (^)(BOOL reject))complate {
    [self reqestFrandPreventionRiskLevelWithPhone:phone withRegion:region complate:^(BOOL openEnable, RCDFraudPreventionRiskLevelCode code) {
        BOOL preject = NO ;
        if (code == RCDFraudPreventionRiskLevelCodeREJECT) {
            preject = YES ;
        }
        complate(preject) ;
    }];
}

// 按照业务组装接口，返回需要的结果。
- (void)reqestFrandPreventionRiskLevelWithPhone:(NSString *)phone withRegion:(NSString *)region complate:(nonnull void (^)(BOOL, RCDFraudPreventionRiskLevelCode))complate {
    [self openFrandPreventionComplate:^(BOOL openEnable) {
        if (openEnable) {
            [self getFrandPreventionRiskLevelWithPhone:phone withRegion:region success:^(RCDFraudPreventionRiskLevelCode code) {
                complate(openEnable,code) ;
            } error:^(NSInteger code) {
                complate(openEnable,RCDFraudPreventionRiskLevelCodeUnknown) ;
            }];
        } else {
            complate(openEnable,RCDFraudPreventionRiskLevelCodeUnknown) ;
        }
    }];
}

// 判断登录时是否使用了天美验证系统
- (void)openFrandPreventionComplate:(void (^)(BOOL openEnable))complate {
    
    // 如果已经验证过当前为开启状态直接返回开启。
    if (self.openEnable) {
        complate(true) ;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [RCDFraudPreventionAPI fraudPreventionStatusSuccess:^(BOOL openEnable) {
        weakSelf.openEnable = openEnable ;
        if (openEnable) {
            [RCDSMSDKHelper setupSMSDK] ;
        }
        complate(openEnable) ;
    } error:^(NSInteger code) {
        weakSelf.openEnable = false ;
        complate(false);
    }];
}

// 返回当前用户的风险等级接口
- (void)getFrandPreventionRiskLevelWithPhone:(NSString *)phone withRegion:(NSString *)region success:(void (^)(RCDFraudPreventionRiskLevelCode code))successBlock error:(void (^)(NSInteger code))errorBlock{
    __weak typeof(self) weakSelf = self;
    [RCDFraudPreventionAPI fraudPreventionVerifyWithPhone:phone region:region deviceId:[RCDSMSDKHelper getDeviceId] success:^(RCDFraudPreventionRiskLevelCode code) {
        weakSelf.code = code ;
        successBlock(code) ;
    } error:^(NSInteger code) {
        weakSelf.code = RCDFraudPreventionRiskLevelCodeUnknown ;
        errorBlock(RCDFraudPreventionRiskLevelCodeUnknown);
    }];
}


@end
