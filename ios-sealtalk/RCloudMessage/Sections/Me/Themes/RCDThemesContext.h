//
//  RCDThemesContext.h
//  SealTalk
//
//  Created by RobinCui on 2025/10/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,RCDThemesCategory) {
    RCDThemesCategoryTraditional,
    RCDThemesCategoryLively,
    RCDThemesCategoryCustomTradition,
    RCDThemesCategoryCustomLively
};
@interface RCDThemesContext : NSObject
+ (RCDThemesCategory)currentCategory;
+ (void)changeThemTo:(RCDThemesCategory)category;
+ (NSString *)currentThemeTitle;
+ (void)applyThemes;
@end

NS_ASSUME_NONNULL_END
