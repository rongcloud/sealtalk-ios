//
//  RCDThemesContext.m
//  SealTalk
//
//  Created by RobinCui on 2025/10/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDThemesContext.h"
#import <RongIMKit/RongIMKit.h>

static NSString *const kRCDThemesCategoryKey = @"RCDThemesCategoryKey";

@implementation RCDThemesContext

+ (RCDThemesCategory)currentCategory {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger category = [defaults integerForKey:kRCDThemesCategoryKey];
    return (RCDThemesCategory)category;
}

+ (void)changeThemTo:(RCDThemesCategory)category {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:category forKey:kRCDThemesCategoryKey];
    [defaults synchronize];
    [self applyThemesWithCategory:category];
}

+ (NSString *)currentThemeTitle {
    RCDThemesCategory category = [self currentCategory];
    NSString *title = RCDLocalizedString(@"TraditionThemes");

    switch (category) {
        case RCDThemesCategoryLively:
            title = RCDLocalizedString(@"LivelyThemes");
            break;
        case RCDThemesCategoryCustomTradition:
            title = RCDLocalizedString(@"ThemeBaseOnTradition");
            break;
        case RCDThemesCategoryCustomLively:
            title = RCDLocalizedString(@"ThemeBaseOnLively");
            break;
        default:
            break;
    }
    return title;
}

+ (void)applyThemes {
    RCDThemesCategory category = [self currentCategory];
    [self applyThemesWithCategory:category];
}


+ (void)applyThemesWithCategory:(RCDThemesCategory)category {
    switch (category) {
        case RCDThemesCategoryLively:
            [RCIMKitThemeManager changeCustomTheme:nil
                                  baseOnTheme:RCIMKitInnerThemesTypeLively];
            break;
        case RCDThemesCategoryCustomTradition: {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *path = [bundle pathForResource:@"EveningSky" ofType:@"bundle"];
            RCIMKitTheme *theme = [[RCIMKitTheme alloc] initWithThemePath:path];
            [RCIMKitThemeManager changeCustomTheme:theme
                                  baseOnTheme:RCIMKitInnerThemesTypeTradition];
        }
            break;
        case RCDThemesCategoryCustomLively:{
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *path = [bundle pathForResource:@"LakeAndSky" ofType:@"bundle"];
            RCIMKitTheme *theme = [[RCIMKitTheme alloc] initWithThemePath:path];
            [RCIMKitThemeManager changeCustomTheme:theme
                                  baseOnTheme:RCIMKitInnerThemesTypeLively];
        }
            break;
        default:
            [RCIMKitThemeManager changeCustomTheme:nil
                                  baseOnTheme:RCIMKitInnerThemesTypeTradition];
            break;
    }
}
@end
