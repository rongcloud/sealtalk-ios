//
//  RCDAlertAction.h
//  SealTalk
//
//  Created by lizhipeng on 2022/5/9.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDAlertAction : NSObject

@property(nonatomic, strong) NSString *title ;

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^ __nullable)(RCDAlertAction *action))handler;

@end

NS_ASSUME_NONNULL_END
