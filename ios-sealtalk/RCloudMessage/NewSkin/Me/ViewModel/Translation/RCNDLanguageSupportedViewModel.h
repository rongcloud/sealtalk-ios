//
//  RCNDLanguageSupportedViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
typedef void (^RCNDLanguageSupportedViewModelBlock)(NSString * _Nonnull language);

NS_ASSUME_NONNULL_BEGIN

@interface RCNDLanguageSupportedViewModel : RCNDBaseListViewModel

- (instancetype)initWithLanguage:(NSString *)language
                           block:(RCNDLanguageSupportedViewModelBlock)block;

- (void)save;

+ (NSDictionary *)languagesSupported;
@end

NS_ASSUME_NONNULL_END
