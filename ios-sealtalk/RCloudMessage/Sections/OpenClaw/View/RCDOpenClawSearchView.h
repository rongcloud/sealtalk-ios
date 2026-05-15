//
//  RCDOpenClawSearchView.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/9.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RCDOpenClawSearchTextChangedBlock)(NSString *text);

@interface RCDOpenClawSearchView : UIView

@property (nonatomic, copy, nullable) RCDOpenClawSearchTextChangedBlock textChangedBlock;

- (void)resignSearchFirstResponder;

@end

NS_ASSUME_NONNULL_END
