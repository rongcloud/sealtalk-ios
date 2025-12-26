//
//  RCNDCountryViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCountryViewModel.h"
#import "RCDCommonString.h"
#import <RongIMKit/RongIMKit.h>
#import "RCNDCountryCellViewModel.h"
#import "RCDLoginManager.h"
#import "RCDUtilities.h"

@interface RCNDCountryViewModel()<RCSearchBarViewModelDelegate>
@property (nonatomic, copy) void(^countrySelectionBlock)(RCDCountry *country);

@property (nonatomic, strong) RCSearchBarViewModel *searchBarVM;
@property (nonatomic, strong) NSMutableArray *matchedItems;
@property (nonatomic, strong) NSMutableArray *allItems;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) NSDictionary *allCountryDic;
@property (nonatomic, strong) NSArray *sectionIndexTitles;
@end
@implementation RCNDCountryViewModel

- (instancetype)initWithBlock:(void (^)(RCDCountry * _Nonnull))completion {
    self = [super init];
    if (self) {
        self.countrySelectionBlock = completion;
    }
    return self;
}


- (void)ready {
    [super ready];
    self.searchBarVM = [RCSearchBarViewModel new];
    self.searchBarVM.delegate = self;
    self.allItems = [NSMutableArray array];
    self.matchedItems = [NSMutableArray array];
}

- (void)countryDidSelected:(RCDCountry *)country {
    if (self.countrySelectionBlock) {
        self.countrySelectionBlock(country);
    }
}

- (void)fetchAllData {
    __weak typeof(self) weakSelf = self;
    [RCDLoginManager getRegionlist:^(NSArray *_Nonnull countryArray) {
        for (RCDCountry *country in countryArray) {
            RCNDCountryCellViewModel *vm = [[RCNDCountryCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
                [weakSelf countryDidSelected:country];
            }];
            vm.hideArrow = YES;
            vm.title = [NSString stringWithFormat:@"+%@  %@", country.phoneCode, country.countryName];
            vm.country = country;
            [weakSelf.allItems addObject:vm];
        }
        [weakSelf groupItemsAndReload:weakSelf.allItems];
    }];
}
     
- (void)groupItemsAndReload:(NSArray *)countryArray {
    NSDictionary *resultDic = [self sortedArrayWithPinYinDic:countryArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sectionIndexTitles = resultDic[@"allKeys"] ;
        self.allCountryDic = resultDic[@"infoDic"];
        [self reloadData];
    });
    
}

- (void)reloadData {
    [self removeSeparatorWitArray:self.items];
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:self.sectionIndexTitles.count == 0];
    }
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDCommonCell class] forCellReuseIdentifier:RCNDCommonCellIdentifier];
}


- (UIView *)searchBar {
    return self.searchBarVM.searchBar;
}

- (void)endEditingState {
    [self.matchedItems removeAllObjects];
    [self.searchBarVM endEditingState];
    [self reloadData];
}


- (void)filterItemsWithKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }

    NSString *pre = [NSString stringWithFormat:@"country.countryName CONTAINS '%@'",key];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:pre];
    NSArray *array = [self.allItems filteredArrayUsingPredicate:predicate];
    [self.matchedItems addObjectsFromArray:array];
    [self groupItemsAndReload:array];
}

- (void)removeSeparatorWitArray:(NSArray *)array {
    for (RCNDCountryCellViewModel *vm in array) {
        vm.hideSeparatorLine = NO;
    }
    if (array.count) {
        [self removeSeparatorLineIfNeed:[self.allCountryDic allValues]];
    }
}

#pragma mark - RCSearchBarViewModelDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.matchedItems removeAllObjects];
    if (searchText.length == 0) {
    } else {
        [self filterItemsWithKey:self.searchBarVM.searchBar.text];

    }
    [self groupItemsAndReload:self.items];;
}

- (void)searchBar:(UISearchBar *)searchBar editingStateChanged:(BOOL)inSearching {
    if (!inSearching) {
        [self endEditingState];
    }
    
//    [self removeSeparatorWitArray:self.allItems];
}

#pragma mark - Table

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self sectionIndexTitles];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionIndexTitles.count;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return self.sectionIndexTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.sectionIndexTitles[section];
    NSArray *array = self.allCountryDic[key];
    return array.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.sectionIndexTitles[indexPath.section];
    NSArray *array = self.allCountryDic[key];
    return array[indexPath.row];
}

- (NSArray *)items {
    if (self.searchBarVM.searchBar.text.length > 0) {
        return self.matchedItems;
    }
    return self.allItems;
}

+ (RCDCountry *)currentRegion; {
    RCDCountry *obj = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];
    return obj;
}

- (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)countryList {
    if (!countryList)
        return nil;
    NSArray *_keys = @[
        @"A",
        @"B",
        @"C",
        @"D",
        @"E",
        @"F",
        @"G",
        @"H",
        @"I",
        @"J",
        @"K",
        @"L",
        @"M",
        @"N",
        @"O",
        @"P",
        @"Q",
        @"R",
        @"S",
        @"T",
        @"U",
        @"V",
        @"W",
        @"X",
        @"Y",
        @"Z",
        @"#"
    ];
    NSMutableArray *mutableList = [countryList mutableCopy];

    NSMutableDictionary *infoDic = [NSMutableDictionary new];

    for (RCNDCountryCellViewModel *model in mutableList) {
        NSString *firstLetter;
        if (model.country.countryName.length > 0 && ![model.country.countryName isEqualToString:@""]) {
            firstLetter = [RCDUtilities getFirstUpperLetter:model.country.countryName];
        } else {
            firstLetter = [RCDUtilities getFirstUpperLetter:model.country.countryName];
        }
        if ([_keys containsObject:firstLetter]) {
            NSMutableArray *array = infoDic[firstLetter];
            if (array) {
                [array addObject:model];
                [infoDic setObject:array forKey:firstLetter];
            } else {
                [infoDic setObject:@[ model ].mutableCopy forKey:firstLetter];
            }
        } else {
            NSMutableArray *array = infoDic[@"#"];
            if (array) {
                [array addObject:model];
                [infoDic setObject:array forKey:@"#"];
            } else {
                [infoDic setObject:@[ model ].mutableCopy forKey:@"#"];
            }
        }
    }
    NSArray *keys = [[infoDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:keys];

    NSMutableDictionary *resultDic = [NSMutableDictionary new];
    [resultDic setObject:infoDic forKey:@"infoDic"];
    [resultDic setObject:allKeys forKey:@"allKeys"];
    return resultDic;
}
@end

