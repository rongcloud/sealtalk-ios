//
//  RCNDSearchResultCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchResultCellViewModel : RCNDBaseCellViewModel
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
- (NSMutableAttributedString *)attributedTextWith:(NSString *)textString
                                  highlightedText:(NSString *)highlightedText;
@end

NS_ASSUME_NONNULL_END
