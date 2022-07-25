#!/bin/sh

#  jenkins_appstore_build.sh
#  RCloudMessage
#
#  Created by chinaspx on 3/4/22.
#  Copyright (c) 2022 RongCloud. All rights reserved.

TEMP_TIME=$(date +%s)
CONFIGURATION="AppStoreRelease"
CUR_PATH=$(pwd)
export Need_Extract_Arch="true"

# 读取外部输入参数
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
elif [ $PFLAG == "-profile" ]
then
PROFILE_FLAG=$PPARAM
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
fi
done

APP_NAME="融云 IM"


echo "build ${APP_NAME}"

echo $VER_FLAG

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./RCloudMessage/Supporting\ Files/Info.plist)
Bundle_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./RCloudMessage/Supporting\ Files/Info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./RCloudMessage/Supporting\ Files/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/'"${Bundle_Version}"'/'"$CUR_TIME"'/; }' ./RCloudMessage/Supporting\ Files/Info.plist

Bundle_Demo_Version=$(/usr/libexec/PlistBuddy -c "Print SealTalk\ Version" ./RCloudMessage/Supporting\ Files/Info.plist)
sed -i "" -e '/SealTalk\ Version/{n;s/'"${Bundle_Demo_Version}"'/'"$DEMO_VER_FLAG"'/; }' ./RCloudMessage/Supporting\ Files/Info.plist


#上架AppStore 需要删除voip能力
sed -i '' -e 's?<string>voip</string>?''?g' ./RCloudMessage/Supporting\ Files/info.plist
#上架AppStore 需要打开 数美SDK能力
sed -i "" -e 's?^#define RCDDebugFraundPreventionDisable.*$?#define RCDDebugFraundPreventionDisable 0?' RCloudMessage/Supporting\ Files/RCDCommonDefine.h

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./融云\ Demo\ WatchKit\ App/Info.plist)
Bundle_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./融云\ Demo\ WatchKit\ App/Info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/'"${Bundle_Version}"'/'"$CUR_TIME"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./融云\ Demo\ WatchKit\ Extension/Info.plist)
Bundle_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./融云\ Demo\ WatchKit\ Extension/Info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/'"${Bundle_Version}"'/'"$CUR_TIME"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./SealTalkShareExtension/Info.plist)
Bundle_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./SealTalkShareExtension/Info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./SealTalkShareExtension/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/'"${Bundle_Version}"'/'"$CUR_TIME"'/; }' ./SealTalkShareExtension/Info.plist

Bundle_Short_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./SealTalkNotificationService/info.plist)
Bundle_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./SealTalkNotificationService/info.plist)
sed -i ""  -e '/CFBundleShortVersionString/{n;s/'"${Bundle_Short_Version}"'/'"$VER_FLAG"\ "$RELEASE_FLAG"'/; }' ./SealTalkNotificationService/info.plist
sed -i "" -e '/CFBundleVersion/{n;s/'"${Bundle_Version}"'/'"$CUR_TIME"'/; }' ./SealTalkNotificationService/info.plist

echo "sealtalk modify parameters times: $(($(date +%s) - $TEMP_TIME))"
TEMP_TIME=$(date +%s)


BIN_DIR="bin"
BUILD_DIR="build"
targetName="SealTalk"
WORKSPACE="RCloudMessage.xcworkspace"
ARCHIVEPATH="./${BUILD_DIR}/${targetName}.xcarchive"
EXPORTOPTIONSPLIST="appStoreArchive.plist"


rm -rf "$BIN_DIR"
rm -rf "$BUILD_DIR"

xcodebuild clean -alltargets

echo "sealtalk clean env times: $(($(date +%s) - $TEMP_TIME))"
TEMP_TIME=$(date +%s)

echo "***开始build iphoneos文件***"


# 执行 Archive
xcodebuild  archive \
            -workspace "${WORKSPACE}" \
            -scheme "${CONFIGURATION}" \
            -archivePath "${ARCHIVEPATH}"

  
echo "sealtalk archive times: $(($(date +%s) - $TEMP_TIME))"
TEMP_TIME=$(date +%s)
  
# 导出相应文件
xcodebuild  -exportArchive \
            -archivePath "${ARCHIVEPATH}" \
            -exportPath "./${BIN_DIR}" \
            -exportOptionsPlist "${EXPORTOPTIONSPLIST}"

  
echo "sealtalk export times: $(($(date +%s) - $TEMP_TIME))"
TEMP_TIME=$(date +%s)
  
# rename
mv ./${BIN_DIR}/*.ipa ${CUR_PATH}/${BIN_DIR}/RCIM_v${DEMO_VER_FLAG}_${CONFIGURATION}_${CUR_TIME}.ipa
cp -af ./${BUILD_DIR}/${targetName}.xcarchive/dSYMs/${targetName}.app.dSYM ${CUR_PATH}/${BIN_DIR}/RCIM_v${DEMO_VER_FLAG}_${CONFIGURATION}_${CUR_TIME}.app.dSYM


    
echo "sealtalk output times: $(($(date +%s) - $TEMP_TIME))"
echo "***编译结束***"

