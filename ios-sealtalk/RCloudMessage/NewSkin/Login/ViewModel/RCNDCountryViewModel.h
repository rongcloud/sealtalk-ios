//
//  RCNDCountryViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import "RCDCountry.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDCountryViewModel : RCNDBaseListViewModel
- (instancetype)initWithBlock:(void(^)(RCDCountry *country))completion;

+ (RCDCountry *)currentRegion;

- (void)fetchAllData;

- (NSString *)titleForHeaderInSection:(NSInteger)section;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;
- (UIView *)searchBar;
@end

NS_ASSUME_NONNULL_END
