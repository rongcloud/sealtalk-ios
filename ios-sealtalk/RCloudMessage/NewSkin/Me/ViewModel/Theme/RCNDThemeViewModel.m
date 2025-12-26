//
//  RCNDThemeViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDThemeViewModel.h"
#import "RCNDRadioCellViewModel.h"
#import "RCDThemesContext.h"


@interface RCNDThemeViewModel()
@property (nonatomic, copy) void(^themeSavedBlock)(NSString *);
@property (nonatomic, copy) NSString *language;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) RCDThemesCategory selectedCategory;
@property (nonatomic, strong) RCNDRadioCellViewModel *vmTradition;
@property (nonatomic, strong) RCNDRadioCellViewModel *vmLively;
@end

@implementation RCNDThemeViewModel
- (instancetype)initWithBlock:(void(^)(NSString *) )themeSavedBlock {
    self = [super init];
    if (self) {
        self.themeSavedBlock = themeSavedBlock;
    }
    return self;
}

+ (NSString *)currentThemeTitle {
    return [RCDThemesContext currentThemeTitle];
}

- (void)ready {
    [super ready];
    
    self.selectedCategory = [RCDThemesContext currentCategory];
    __weak typeof(self) weakSelf = self;

    RCNDRadioCellViewModel *vmTradition = [[RCNDRadioCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        [weakSelf reloadData:RCDThemesCategoryTraditional];
    }];
    vmTradition.title = RCDLocalizedString(@"TraditionThemes");
    vmTradition.selected = (self.selectedCategory == RCDThemesCategoryTraditional);
    self.vmTradition = vmTradition;
    
    RCNDRadioCellViewModel *vmLively = [[RCNDRadioCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        [weakSelf reloadData:RCDThemesCategoryLively];
    }];
    vmLively.title = RCDLocalizedString(@"LivelyThemes");
    vmLively.selected = (self.selectedCategory == RCDThemesCategoryLively);
    self.vmLively = vmLively;
    self.dataSource = @[vmTradition, vmLively];
    [self removeSeparatorLineIfNeed:@[self.dataSource]];
}

- (void)save {
    [RCDThemesContext changeThemTo:self.selectedCategory];
    if (self.themeSavedBlock) {
        self.themeSavedBlock(self.language);
    }
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDRadioCell class]
      forCellReuseIdentifier:RCNDRadioCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

- (void)reloadData:(RCDThemesCategory)category {
    self.selectedCategory = category;
    self.vmTradition.selected = category == RCDThemesCategoryTraditional;
    self.vmLively.selected = category == RCDThemesCategoryLively;
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
}

@end
