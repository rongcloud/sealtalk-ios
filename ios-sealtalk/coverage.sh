#!/bin/sh
ENABLE_COVERAGE="No"
for((options_index = 1; options_index < $#; options_index=$[$options_index+2])) do
params_index=$[$options_index+1]
PFLAG=`echo $@|cut -d ' ' -f ${options_index}`
PPARAM=`echo $@|cut -d ' ' -f ${params_index}`
if [[ $PPARAM =~ ^- ]]; then
    PPARAM=""
    options_index=$[$options_index-1]
fi
if [ $PFLAG == "-coverage" ]
then
ENABLE_COVERAGE=$PPARAM
fi
done

if [ ${ENABLE_COVERAGE} == "No" ]; then
    exit 0
fi

sed -i '' '1i\
#include <dlfcn.h>\
' RCloudMessage/AppDelegate.m

sed -i '' '/@implementation AppDelegate/a\
- (void)startCoverageCollectionInBackground{\
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{\
        @autoreleasepool {\
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(collectCoverageData) userInfo:nil repeats:YES];\
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];\
            [[NSRunLoop currentRunLoop] run];\
        }\
    });\
}\
\
- (bool) runGcovDump:(NSString*) framework name:(NSString*) name {\
    NSString *frameworkPath = [NSString stringWithFormat:@"%@/Frameworks/%@/%@", [[NSBundle mainBundle] bundlePath],framework,name];\
    void *handle = dlopen([frameworkPath UTF8String], RTLD_NOW);\
    if (handle) {\
        NSLog(@"Successfully loaded %@ from %@", framework, frameworkPath);\
        void (*gcov_dump)(void) = (void (*)(void))dlsym(handle, "__gcov_dump");\
        if (gcov_dump) {\
            gcov_dump();\
            NSLog(@"Called __gcov_dump from %@", framework);\
            return true;\
        }\
        dlclose(handle);\
    } else {\
        NSLog(@"Failed to load %@",framework);\
        return false;\
    }\
    return false;\
}\
\
- (void) collectCoverageData{\
    NSString *fileCovPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/coverage_file"];\
    setenv("GCOV_PREFIX", [fileCovPath cStringUsingEncoding:NSUTF8StringEncoding], 1);\
    setenv("GCOV_PREFIX_STRIP", "1", 1);\
    [self runGcovDump:@"RongIMLibCore.framework" name:@"RongIMLibCore"];\
    [self runGcovDump:@"RongChatRoom.framework" name:@"RongChatRoom"];\
}
' RCloudMessage/AppDelegate.m

sed -i '' '/- (BOOL)application:(UIApplication \*)application didFinishLaunchingWithOptions:(NSDictionary \*)launchOptions {/a\
    [self startCoverageCollectionInBackground];\
' RCloudMessage/AppDelegate.m
