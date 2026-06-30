//
//  RCNDTranslationViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDTranslationViewModel.h"
#import "RCNDCommonCellViewModel.h"
#import <RongIMKit/RCKitTranslationConfig.h>
#import <RongIMKit/RCKitConfig.h>
#import "RCNDLanguageSupportedViewController.h"
#import <RongIMKit/RCIM.h>
#import "RCTransationPersistModel.h"

@interface RCNDTranslationViewModel()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) RCNDCommonCellViewModel *sourceVM;
@property (nonatomic, strong) RCNDCommonCellViewModel *targetVM;
@property (nonatomic, strong) NSDictionary *languageInfo;
@property (nonatomic, strong) RCTransationPersistModel *translationConfig;
@end

@implementation RCNDTranslationViewModel

- (void)ready {
    [super ready];
    __weak typeof(self) weakSelf = self;

    NSString *srcLan = self.languageInfo[self.translationConfig.srcLanguage];
    RCNDCommonCellViewModel *sourceVM = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        [weakSelf showLanguageList:YES
                          language:weakSelf.translationConfig.srcLanguage
                        controller:vc];
    }];
    sourceVM.title = RCDLocalizedString(@"SrcLanguage");
    sourceVM.subtitle = srcLan;

    NSString *targetLan = self.languageInfo[self.translationConfig.targetLanguage];
    RCNDCommonCellViewModel *targetVM = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        [weakSelf showLanguageList:NO
                          language:weakSelf.translationConfig.targetLanguage
                        controller:vc];
    }];
    targetVM.title = RCDLocalizedString(@"TargetLanguage");
    targetVM.subtitle = targetLan;

    self.dataSource = @[sourceVM,targetVM];
    [self removeSeparatorLineIfNeed:@[self.dataSource]];
    self.sourceVM = sourceVM;
    self.targetVM = targetVM;
}

- (void)showLanguageList:(BOOL)isSrc language:(NSString *)language  controller:(UIViewController *)vc {
    RCNDLanguageSupportedViewModel *vm = [[RCNDLanguageSupportedViewModel alloc] initWithLanguage:language block:^(NSString * _Nonnull language) {
        [self saveLanguages:language isSource:isSrc];
    }];
    RCNDLanguageSupportedViewController *controller = [[RCNDLanguageSupportedViewController alloc] initWithViewModel:vm];
    if (isSrc) {
        controller.title = RCDLocalizedString(@"SrcLanguage");
    } else {
        controller.title = RCDLocalizedString(@"TargetLanguage");
    }
    [self showViewController:controller byViewController:vc];
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDCommonCell class]
      forCellReuseIdentifier:RCNDCommonCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}


- (void)saveLanguages:(NSString *)language isSource:(BOOL)isSource {
    if (!language.length) {
        return;
    }
    if (isSource) {
        self.sourceVM.subtitle = self.languageInfo[language];
        self.translationConfig.srcLanguage = language;
    } else {
        self.targetVM.subtitle = self.languageInfo[language];
        self.translationConfig.targetLanguage = language;
    }
    
    [self.translationConfig save];
    [self configureTranslation:self.translationConfig.srcLanguage target:self.translationConfig.targetLanguage];
}

// 配置翻译语言类型
/// @param srcLanguage 源语言类型
/// @param targetLanguage 目标语言类型
- (BOOL)configureTranslation:(NSString *)srcLanguage target:(NSString *)targetLanguage {
    if ([srcLanguage isKindOfClass:[NSString class]]
        && [targetLanguage isKindOfClass:[NSString class]]) {
        RCKitTranslationConfig *translationConfig = [[RCKitTranslationConfig alloc] initWithSrcLanguage:srcLanguage targetLanguage:targetLanguage];
        [RCKitConfig defaultConfig].message.translationConfig = translationConfig;
        return YES;
    }
    return NO;
}

#pragma mark - Property

- (NSDictionary *)languageInfo {
    if (!_languageInfo) {
        _languageInfo = [RCNDLanguageSupportedViewModel languagesSupported];
    }
    return _languageInfo;
}
- (RCTransationPersistModel *)translationConfig {
    if (!_translationConfig) {
        _translationConfig = [RCTransationPersistModel loadTranslationConfig];
    }
    return _translationConfig;
}

@end
