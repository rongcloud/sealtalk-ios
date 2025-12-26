//
//  RCNDCountryCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCommonCellViewModel.h"
#import "RCDCountry.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDCountryCellViewModel : RCNDCommonCellViewModel
@property (nonatomic, strong) RCDCountry *country;
@end

NS_ASSUME_NONNULL_END
