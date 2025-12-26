//
//  RCNDLanguageViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDLanguageViewModel.h"
#import "RCNDRadioCellViewModel.h"
#import "RCDLanguageManager.h"

@interface RCNDLanguageViewModel()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, copy) NSString *targetLanguage;
@property (nonatomic, copy) void(^languageSavedBlock)(NSString *);

@end

@implementation RCNDLanguageViewModel
- (instancetype)initWithBlock:(void(^)(NSString *) )languageSavedBlock {
    self = [super init];
    if (self) {
        self.languageSavedBlock = languageSavedBlock;
    }
    return self;
}

- (void)ready {
    NSDictionary *dic = [[self class] languageInfo];
    self.targetLanguage = [[self class] currentLanguage];
    self.keys = [dic allKeys];
    NSMutableArray * array = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    for (NSString *lan in self.keys) {
        RCNDRadioCellViewModel *vm = [[RCNDRadioCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
            [weakSelf reloadData:lan];
        }];
        vm.title = dic[lan];
        vm.selected = [self.targetLanguage isEqualToString:lan];
        [array addObject:vm];
    }
    self.dataSource = array;
    [self removeSeparatorLineIfNeed:@[self.dataSource]];

}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDRadioCell class]
      forCellReuseIdentifier:RCNDRadioCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.keys.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

- (void)reloadData:(NSString *)lan {
    self.targetLanguage = lan;
    NSInteger index = [self.keys indexOfObject:lan];
    for (int i = 0; i<self.dataSource.count; i++) {
        RCNDRadioCellViewModel *vm = self.dataSource[i];
        vm.selected = i == index;
    }
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
}

+ (NSDictionary *)languageInfo {
   return @{ @"en" : @"English", @"zh-Hans" : @"简体中文", @"ar" : @"العربية"};
}

+ (NSString *)currentLanguage {
    NSString * language = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
    return language;
}

- (void)saveLanguage:(void(^)(RCPushLanguage lan, BOOL ret))completion {
    NSString *languageString = self.targetLanguage;
    RCPushLanguage language = RCPushLanguage_EN_US;
    if ([languageString isEqualToString:@"ar"]) {
        language = RCPushLanguage_AR_SA;
    } else if ([languageString isEqualToString:@"zh-Hans"]) {
        language = RCPushLanguage_ZH_CN;
    } else {
        language = RCPushLanguage_EN_US;
    }
    
    [[RCCoreClient sharedCoreClient].pushProfile setPushLauguage:language success:^{
        //设置当前语言
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:languageString];
        if (self.languageSavedBlock) {
            self.languageSavedBlock(languageString);
        }
        if (completion) {
            completion(language, YES);
        }
        
    } error:^(RCErrorCode status) {
        if (completion) {
            completion(language, NO);
        }
        
    }];
}
@end
