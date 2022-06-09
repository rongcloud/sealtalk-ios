//
//  Copyright © 2017年 shumei. All rights reserved.
//  Pingshun Wei<weipingshun@ishumei.com>
//

#ifndef SM_ANTI_FRAUD_H
#define SM_ANTI_FRAUD_H

#import <Foundation/Foundation.h>

//typedef void (^OnServerIdReceive)(NSString*);

#define ERROR_NO_NETWORK     -1
#define ERROR_NO_RESPONSE    -2
#define ERROR_SERVER_RESPONSE    -3
#define ERROR_UNKNOW    -4

//area
typedef NS_ENUM(NSUInteger, SmAntiFraudArea){
    AREA_BJ =  0,
    AREA_XJP = 1,
    AREA_FJNY = 2
};
// 回调类
@protocol  ServerSmidProtocol <NSObject>
/**
 * 成功回调函数
 */
@required - (void)smOnSuccess:(NSString*) serverId;

/**
 * 异常回调函数
 */
@required - (void)smOnError:(NSInteger) errorCode;
@end

// 数美反欺诈SDK配置类
@interface SmOption : NSObject {
    NSString *_organization;
    NSString *_privKey;
    NSString *_channel;
    BOOL _transport;
    BOOL _cloudConf;
    NSString *_url;               // 上传设备数据接口
    NSString *_confUrl;
//    OnServerIdReceive _callback;
    NSString *_appId;
    __weak id<ServerSmidProtocol> _delegate;
//    BOOL _encrypt;
    BOOL _useHttps;
    NSString *_publicKey;
    NSArray *_notCollect;
    SmAntiFraudArea _area;
}

@property(readwrite) NSString *organization;
@property(readwrite) NSString *privKey;
@property(readwrite) NSString *channel;
@property(readwrite) BOOL transport;
@property(readwrite) BOOL cloudConf;
@property(readwrite) NSString *url;
@property(readwrite) NSString *confUrl;
//@property(readwrite, copy) OnServerIdReceive callback;
@property(readwrite) NSString *appId;
@property(readwrite, weak) id<ServerSmidProtocol> delegate;
//@property(readwrite) BOOL encrypt;
@property(readwrite) BOOL useHttps;
@property(readwrite) NSString *publicKey;
@property(readwrite) NSArray *notCollect;
@property(readwrite) SmAntiFraudArea area;
@end



// 错误码
#define SM_AF_SUCCESS                  0
#define SM_AF_ERROR_OPTION_NULL        1
#define SM_AF_ERROR_ORIGNATION_BLANK   2
#define SM_AF_ERROR_ID_COLLECTOR       3
#define SM_AF_ERROR_SEQ_COLLECTOR      4
#define SM_AF_ERROR_BASE_COLLECTOR     5
#define SM_AF_ERROR_FINANCE_COLLECTOR  6
#define SM_AF_ERROR_TRACKER            7
#define SM_AF_ERROR_UNINIT             8
#define SM_AF_ERROR_SPEC_COLLECTOR     9
#define SM_AF_ERROR_CORE_COLLECTOR    10
#define SM_AF_ERROR_SENSOR_COLLECTOR    11


// 处理模式
#define SM_AF_SYN_MODE  0     // 同步模式
#define SM_AF_ASYN_MODE 1    // 异步模式

// 用户可见的version
#define SDK_VERSION 226

// 数美反欺诈SDK主类
@interface SmAntiFraud : NSObject {
    __weak id<ServerSmidProtocol> _idDelegate;
}
@property(readwrite, weak) id<ServerSmidProtocol> idDelegate;

/**
 * 单例模式
 * 优点: 
 * 1. 只需要初始化一次，任意任意调用。
 * 2. 不用传递SmAntiFraud对象。
 */
+(instancetype) shareInstance;

/**
 * 获取SDK版本信息
 */
+(NSString*) getSDKVersion;

/**
 * 初始化接口
 */
-(void) create:(SmOption*) opt;

- (long) getCost;

/**
 * 获取设备ID
 *
 * 返回值：成功：返回deviceId，失败：返回空字符串
 */
-(NSString*) getDeviceId;
/**
 * 注册callback，当 server id 的获取后回调通知app
 */
-(void) registerServerIdCallback:(id<ServerSmidProtocol>) delegate;

-(BOOL) setCloudConfigWithStr:(NSString*)detail;

-(SmOption *) getOption;


@end
#endif
