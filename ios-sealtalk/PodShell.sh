#!/bin/bash
#!/usr/bin/php

# 流程
# 1. 修改 Frameworks 文件夹路径
# 2. 删除敏感信息
# 2. 处理 所有本地库
# 3. 处理 Podfile

# 获取 project.pbxproj 路径，并修改权限
Project="RCloudMessage.xcodeproj/project.pbxproj"
chmod 777 ${Project}

# 1.修改 Frameworks 文件夹路径
sed -i '' -e '/path = RongCloudTests;/d' ${Project}

# 删除脚本 sh xcodebuild.sh
sed -i '' -e "/\/\* ShellScript \*\/ = {/,/};/d" ${Project}

# 2.1 删除敏感信息
sed -i "" -e 's?^#define DORAEMON_APPID.*$?#define DORAEMON_APPID @\"\"?' RCloudMessage/AppDelegate.m
sed -i "" -e 's?^#define BUGLY_APPID.*$?#define BUGLY_APPID @\"\"?' RCloudMessage/AppDelegate.m
sed -i "" -e 's?^#define UMENG_APPKEY.*$?#define UMENG_APPKEY @\"\"?' RCloudMessage/AppDelegate.m
sed -i "" -e 's?^#define IFLY_APPKEY.*$?#define IFLY_APPKEY @\"\"?' RCloudMessage/AppDelegate.m
# 2.2 修改<翻译 SDK>条件编译宏为0
sed -i "" -e 's?^#define RCDTranslationEnable.*$?#define RCDTranslationEnable 0?' RCloudMessage/Supporting\ Files/RCDCommonDefine.h
# 2.3 删除 SmAntiFraud 敏感信息
sed -i "" -e 's?^static NSString \*const ORGANIZATION = .*$?static NSString \*const ORGANIZATION = @\"\";?' RCloudMessage/Utils/SMHelper/RCDSMSDKHelper.m
sed -i "" -e 's?^static NSString \*const APP_ID = .*$?static NSString \*const APP_ID = @\"\";?' RCloudMessage/Utils/SMHelper/RCDSMSDKHelper.m
sed -i "" -e 's?^static NSString \*const PUBLICK_KEY = .*$?static NSString \*const PUBLICK_KEY = @\"\";?' RCloudMessage/Utils/SMHelper/RCDSMSDKHelper.m
sed -i "" -e 's?^#define RCDDebugFraundPreventionDisable.*$?#define RCDDebugFraundPreventionDisable 1?' RCloudMessage/Supporting\ Files/RCDCommonDefine.h
sed -i "" -e 's?^NSString\* const RCDTestAppKey = .*$?NSString\* const RCDTestAppKey = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m
sed -i "" -e 's?^NSString\* const RCDTestServerURL = .*$?NSString\* const RCDTestServerURL = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m
sed -i "" -e 's?^NSString\* const RCDTestNavServer = .*$?NSString\* const RCDTestNavServer = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m
sed -i "" -e 's?^NSString\* const RCDTestStatsServer = .*$?NSString\* const RCDTestStatsServer = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m

sed -i "" -e 's?^NSString\* const RCDSigaporeAppKey = .*$?NSString\* const RCDSigaporeAppKey = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m
sed -i "" -e 's?^NSString\* const RCDSigaporevServerURL = .*$?NSString\* const RCDSigaporevServerURL = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m
sed -i "" -e 's?^NSString\* const RCDSigaporeNavServer = .*$?NSString\* const RCDSigaporeNavServer = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m
sed -i "" -e 's?^NSString\* const RCDSigaporeStatsServer = .*$?NSString\* const RCDSigaporeStatsServer = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m

sed -i "" -e 's?^NSString\* const RCDNorthAmericanAppKey = .*$?NSString\* const RCDNorthAmericanAppKey = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m
sed -i "" -e 's?^NSString\* const RCDNorthAmericanServerURL = .*$?NSString\* const RCDNorthAmericanServerURL = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m
sed -i "" -e 's?^NSString\* const RCDNorthAmericanNavServer = .*$?NSString\* const RCDNorthAmericanNavServer = @\"\";?' RCloudMessage/Environment/RCDEnvironmentModel.m


# 3. 处理所有本地库


sed -i '' -e "/Emoji.plist/d"  ${Project}
sed -i '' -e "/GPUImage.framework/d"  ${Project}

sed -i '' -e "/\/\* ifly \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/RongiFlyKit.framework/d"  ${Project}
sed -i '' -e "/iflyMSC.framework/d"  ${Project}
sed -i '' -e "/RongCloudiFly.bundle/d"  ${Project}

sed -i "" -e 's?\[RCiFlyKit?//\[RCiFlyKit?' RCloudMessage/AppDelegate.m
sed -i "" -e 's?^#import <RongiFlyKit?//#import <RongiFlyKit?' RCloudMessage/AppDelegate.m


# im start

sed -i '' -e "/RongIMLibCore.framework/d"  ${Project}
sed -i '' -e "/RongChatRoom.framework/d"  ${Project}
sed -i '' -e "/RongCustomerService.framework/d"  ${Project}
sed -i '' -e "/RongPublicService.framework/d"  ${Project}
sed -i '' -e "/RongLocation.framework/d"  ${Project}
sed -i '' -e "/RongDiscussion.framework/d"  ${Project}

sed -i '' -e "/RongIMLib.framework/d"  ${Project}

sed -i '' -e "/RongIMKit.framework/d"  ${Project}

sed -i '' -e "/RCConfig.plist/d"  ${Project}

sed -i '' -e "/RongCloud.bundle/d"  ${Project}
sed -i '' -e "/RongCloudKit.strings in Resources/d"  ${Project}
sed -i '' -e "/RCColor.plist/d"  ${Project}

sed -i '' -e "/libopencore-amrnb.a/d"  ${Project}
sed -i '' -e "/libopencore-amrwb.a/d"  ${Project}
sed -i '' -e "/libvo-amrwbenc.a/d"  ${Project}
# im end

# rtc start
sed -i '' -e "/Blink.framework/d"  ${Project}
sed -i '' -e "/RongCallKit.framework/d"  ${Project}
sed -i '' -e "/RongCallLib.framework/d"  ${Project}
sed -i '' -e "/RongRTCLib.framework/d"  ${Project}
sed -i '' -e "/RongCallKit.strings in Resources/d"  ${Project}
sed -i '' -e "/RongCallKit.bundle in Resources/d"  ${Project}
# rtc end


sed -i '' -e "/\/\* RCSticker \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/RongSticker.framework/d"  ${Project}
sed -i '' -e "/RongSticker.framework in Frameworks/d"  ${Project}
sed -i '' -e "/RongSticker.bundle in Resources/d"  ${Project}
sed -i '' -e "/RongSticker.strings in Resources/d"  ${Project}

sed -i '' -e "/RongSight.framework/d"  ${Project}
sed -i '' -e "/RongContactCard.framework/d"  ${Project}
sed -i '' -e "/RongTranslation.framework/d"  ${Project}
sed -i '' -e "/RongLocationKit.framework/d"  ${Project}
sed -i '' -e "/RCNotificationServicePlugin.h/d"  ${Project}
sed -i '' -e "/RCNotificationServicePlugin.m/d"  ${Project}
sed -i '' -e "/RCNotificationServiceAppPlugin.h/d"  ${Project}
sed -i '' -e "/RCNotificationServiceAppPlugin.m/d"  ${Project}


# app extention 不支持手动引入 XCFramework；pod 1.11.2 不支持 app 与 extension 导入同一 SDK start
#sed -i '' -e "/RongIMLibCore/d" ./SealTalkNotificationService/NotificationService.m
#sed -i '' -e "/RCCoreClient/d" ./SealTalkNotificationService/NotificationService.m
# app extention 不支持手动引入 XCFramework，pod 1.11.2 不支持 app 与 extension 导入同一 SDK end

# SmAntiFraud
sed -i '' -e "/libSmAntiFraud.a/d"  ${Project}
rm -rf ./RCloudMessage/sdk/smsdk

# 移除本地使用的库 framework 文件夹被忽略 以下注释掉了
# rm -rf ./framework/RongIMLib
# rm -rf ./framework/RongIMKit
# rm -rf ./framework/RongSticker
# rm -rf ./framework/RongSight
# rm -rf ./framework/RongCallLib
# rm -rf ./framework/RongCallKit
# rm -rf ./framework/RongRTCLib
# rm -rf ./framework/RongiFlyKit
# rm -rf ./framework/RongContactCard
# rm -rf ./framework/RongCustomerService
# rm -rf ./framework/RongChatRoom
# rm -rf ./framework/RongDiscussion
# rm -rf ./framework/RongIMLibCore
# rm -rf ./framework/RongLocation
# rm -rf ./framework/RongPublicService
# 移除本地使用的库 framework 文件夹被忽略 以上注释掉了


# 变量和=间不能有空格
pwd
sed -i '' -e 's/#/''/g'  Podfile
sed -i '' -e '/RongCloud/s/5.2.3/'${Version}'/g' Podfile
#pod update

num=0
while ((num<10))
do
    num+=1
    pod install --repo-update
    [ $? -eq 0 ] && num=10
done

xcodebuild -sdk iphoneos -workspace RCloudMessage.xcworkspace -scheme SealTalk

[ $? -ne 0 ] && exit 1
