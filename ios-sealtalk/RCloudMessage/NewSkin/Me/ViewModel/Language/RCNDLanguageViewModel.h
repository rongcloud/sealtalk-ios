//
//  RCNDLanguageViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCNDLanguageViewModel : RCNDBaseListViewModel
- (instancetype)initWithBlock:(void(^)(NSString *))languageSavedBlock;

+ (NSString *)currentLanguage;
+ (NSDictionary *)languageInfo;
- (void)saveLanguage:(void(^)(RCPushLanguage lan, BOOL ret))completion;
@end

NS_ASSUME_NONNULL_END
