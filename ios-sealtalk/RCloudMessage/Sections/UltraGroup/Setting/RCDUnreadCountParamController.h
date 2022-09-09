//
//  RCDUnreadCountParamController.h
//  SealTalk
//
//  Created by RobinCui on 2022/8/2.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol RCDUnreadCountParamControllerDelegate <NSObject>

- (void)userDidSelected:(NSArray<NSNumber *> *)conversationTypes
             typeString:(NSString *)typeString
                 levels:(NSArray<NSNumber *> *)levels
            levelString:(NSString *)levelString;

@end

@interface RCDUnreadCountParamController : UIViewController
@property (nonatomic, weak) id<RCDUnreadCountParamControllerDelegate> delegate;
@property (nonatomic, assign, getter=isUltraGroup) BOOL ultraGroup;
- (instancetype)initWithConversationTypes:(NSArray *)types
                                   levels:(NSArray *)levels;
@end

NS_ASSUME_NONNULL_END
