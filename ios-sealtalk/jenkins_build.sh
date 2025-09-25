#!/bin/sh

#  build-imdemo.sh
#  RCloudMessage
#
#  Created by xugang on 4/8/15.
#  Copyright (c) 2015 RongCloud. All rights reserved.

TEMP_TIME=$(date +%s)
CONFIGURATION="Release"
BIN_DIR="bin"
BUILD_DIR="build"
ENABLE_COVERAGE="No"
export Need_Extract_Arch="true"

CUR_PATH=$(pwd)

sh before_build.sh

for((options_index = 1; options_index < $#; options_index=$[$options_index+2])) do
params_index=$[$options_index+1]
PFLAG=`echo $@|cut -d ' ' -f ${options_index}`
PPARAM=`echo $@|cut -d ' ' -f ${params_index}`
if [[ $PPARAM =~ ^- ]]; then
    PPARAM=""
    options_index=$[$options_index-1]
fi
if [ $PFLAG == "-configuration" ]
then
CONFIGURATION=$PPARAM
elif [ $PFLAG == "-version" ]
then
VER_FLAG=$PPARAM
elif [ $PFLAG == "-demoversion" ]
then
DEMO_VER_FLAG=$PPARAM
elif [ $PFLAG == "-type" ]
then
RELEASE_FLAG=$PPARAM
elif [ $PFLAG == "-time" ]
then
CUR_TIME=$PPARAM
elif [ $PFLAG == "-appkey" ]
then
DEMO_APPKEY=$PPARAM
elif [ $PFLAG == "-demoserver" ]
then
DEMO_SERVER_URL=$PPARAM
elif [ $PFLAG == "-navi" ]
then
NAVI_SERVER_URL=$PPARAM
elif [ $PFLAG == "-file" ]
then
FILE_SERVER_URL=$PPARAM
elif [ $PFLAG == "-stats" ]
then
STATS_SERVER_URL=$PPARAM
elif [ $PFLAG == "-csid" ]
then
CUSTOMER_SERVICE_ID=$PPARAM
elif [ $PFLAG == "-fraudmode" ]
then
ENABLE_FRAUD_PREVENTION=$PPARAM
elif [ $PFLAG == "-coverage" ]
then
ENABLE_COVERAGE=$PPARAM
fi
done

APP_NAME=${Build_App}

echo "sealtalk copy sdk times: $(($(date +%s) - $TEMP_TIME))"
TEMP_TIME=$(date +%s)

# 更新 pod
pod update --no-repo-update
echo "sealtalk pod update times: $(($(date +%s) - $TEMP_TIME))"
TEMP_TIME=$(date +%s)

echo "build ${APP_NAME}"

#appkey
if [ -n "${DEMO_APPKEY}" ]; then
    sed -i '' -e '/RONGCLOUD_IM_APPKEY/s/@"n19jmcy59f1q9"/@"'$DEMO_APPKEY'"/g' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
fi

#demo 服务器
if [ -n "${DEMO_SERVER_URL}" ]; then
    if [[ $DEMO_SERVER_URL =~ ^http ]]; then
        sed -i '' -e 's?https://sealtalk.rongcloud.cn/server-api?'$DEMO_SERVER_URL'?g' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
    else
        sed -i '' -e 's?https://sealtalk.rongcloud.cn/server-api?http://'$DEMO_SERVER_URL'?g' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
    fi
fi

#导航服务器
if [ -n "${NAVI_SERVER_URL}" ]; then
sed -i "" -e 's?#define RONGCLOUD_NAVI_SERVER @\"\"$?#define RONGCLOUD_NAVI_SERVER @\"'${NAVI_SERVER_URL}'\"?' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
fi

#文件服务器
if [ -n "${FILE_SERVER_URL}" ]; then
sed -i "" -e 's?#define RONGCLOUD_FILE_SERVER @\"\"$?#define RONGCLOUD_FILE_SERVER @\"'${FILE_SERVER_URL}'\"?' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
fi

#统计服务器
if [ -n "${STATS_SERVER_URL}" ]; then
sed -i "" -e 's?#define RONGCLOUD_STATS_SERVER @\"\"$?#define RONGCLOUD_STATS_SERVER @\"'${STATS_SERVER_URL}'\"?' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
fi

if [ -n "${CUSTOMER_SERVICE_ID}" ]; then
    sed -i '' -e '/SERVICE_ID/s/@"service"/@"'$CUSTOMER_SERVICE_ID'"/g' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
fi

if [ ${CONFIGURATION} == "Debug" ]
then
sed -i '' -e '/redirectNSlogToDocumentFolder/s/\/\///g' ./RCloudMessage/AppDelegate.m
sed -i "" -e '/UIFileSharingEnabled/{n;s/false/true/; }' ./RCloudMessage/Supporting\ Files/Info.plist
else
sed -i '' -e '/redirectNSlogToDocumentFolder/s/\/\///g' ./RCloudMessage/AppDelegate.m
sed -i "" -e '/UIFileSharingEnabled/{n;s/false/true/; }' ./RCloudMessage/Supporting\ Files/Info.plist
sed -i '' -e 's/RCDDebugTestFunction 1/\RCDDebugTestFunction 0/g' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
fi

if [ ${ENABLE_FRAUD_PREVENTION} = "1" ]
then
sed -i "" -e 's?^#define RCDDebugFraundPreventionDisable.*$?#define RCDDebugFraundPreventionDisable 0?' ./RCloudMessage/Supporting\ Files/RCDCommonDefine.h
fi

BUILD_APP_PROFILE=""
BUILD_SHARE_PROFILE=""

BUILD_CODE_SIGN_IDENTITY="iPhone Distribution: Beijing Rong Cloud Network Technology CO., LTD"

echo $VER_FLAG

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./RCloudMessage/Supporting\ Files/Info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./RCloudMessage/Supporting\ Files/Info.plist
Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./RCloudMessage/Supporting\ Files/Info.plist)
sed -i ""  -e '/CFBundleVersion/{n;s/'${Bundle_Short_Version}'/'"${CUR_TIME}"'/; }' ./RCloudMessage/Supporting\ Files/Info.plist

Bundle_Demo_Version=$(/usr/libexec/PlistBuddy -c "Print SealTalk\ Version" ./RCloudMessage/Supporting\ Files/Info.plist)
sed -i "" -e '/SealTalk Version/{n;s/'"${Bundle_Demo_Version}"'/'"$DEMO_VER_FLAG"'/; }' ./RCloudMessage/Supporting\ Files/Info.plist

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./融云\ Demo\ WatchKit\ App/Info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./融云\ Demo\ WatchKit\ Extension/Info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./SealTalkShareExtension/Info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./SealTalkShareExtension/Info.plist
Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./SealTalkShareExtension/Info.plist)
sed -i ""  -e '/CFBundleVersion/{n;s/'${Bundle_Short_Version}'/'"${CUR_TIME}"'/; }' ./SealTalkShareExtension/Info.plist

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" .//SealTalkNotificationService/info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' .//SealTalkNotificationService/info.plist
Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./SealTalkNotificationService/Info.plist)
sed -i ""  -e '/CFBundleVersion/{n;s/'${Bundle_Short_Version}'/'"${CUR_TIME}"'/; }' ./SealTalkNotificationService/Info.plist

echo "sealtalk modify parameters times: $(($(date +%s) - $TEMP_TIME))"
TEMP_TIME=$(date +%s)

PROJECT_NAME="RCloudMessage.xcodeproj"
targetName="SealTalk"
TARGET_DECIVE="iphoneos"

rm -rf DerivedData
rm -rf "$BIN_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$BUILD_DIR"
xcodebuild clean -alltargets

echo "sealtalk clean env times: $(($(date +%s) - $TEMP_TIME))"
TEMP_TIME=$(date +%s)

sh coverage.sh -coverage ${ENABLE_COVERAGE}

echo "***开始build iphoneos文件***"
[ -d "framework" ] && rm -rf framework
  if [ ${ENABLE_COVERAGE} == "Yes" ]; then
  xcodebuild -scheme "${targetName}" archive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -configuration ${CONFIGURATION} APP_PROFILE="${BUILD_APP_PROFILE}" SHARE_PROFILE="${BUILD_SHARE_PROFILE}" GCC_GENERATE_TEST_COVERAGE_FILES=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES
  else
  xcodebuild -scheme "${targetName}" archive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -configuration ${CONFIGURATION} APP_PROFILE="${BUILD_APP_PROFILE}" SHARE_PROFILE="${BUILD_SHARE_PROFILE}"
  fi

  echo "sealtalk archive times: $(($(date +%s) - $TEMP_TIME))"
  TEMP_TIME=$(date +%s)
  
  xcodebuild -exportArchive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -exportOptionsPlist "adHocArchive.plist" -exportPath "./${BIN_DIR}" -allowProvisioningUpdates
  
  echo "sealtalk export times: $(($(date +%s) - $TEMP_TIME))"
  TEMP_TIME=$(date +%s)
  
  mv ./${BIN_DIR}/*.ipa ${CUR_PATH}/${BIN_DIR}/RCIM_v${VER_FLAG}_${CONFIGURATION}_${CUR_TIME}.ipa
  cp -af ./${BUILD_DIR}/${targetName}.xcarchive/dSYMs/${targetName}.app.dSYM ${CUR_PATH}/${BIN_DIR}/RCIM_v${VER_FLAG}_${CONFIGURATION}_${CUR_TIME}.app.dSYM
    
  echo "sealtalk output times: $(($(date +%s) - $TEMP_TIME))"
echo "***编译结束***"

