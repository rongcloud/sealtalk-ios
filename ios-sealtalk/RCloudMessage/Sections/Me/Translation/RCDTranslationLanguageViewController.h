//
//  RCDTranslationLanguageViewController.h
//  SealTalk
//
//  Created by RobinCui on 2022/2/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDTranslationLanguageViewController : UITableViewController
- (instancetype)initWithStyle:(UITableViewStyle)style
                     language:(NSString *)language
                languagesInfo:(NSDictionary *)info
                   completion:(void(^)(NSString *))completion;

@end

NS_ASSUME_NONNULL_END
