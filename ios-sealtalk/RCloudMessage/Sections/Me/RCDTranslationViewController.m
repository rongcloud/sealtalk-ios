//
//  RCDTranslationViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/2/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDTranslationViewController.h"
#import <RongIMKit/RCIM.h>
#import "RCDTranslationLanguageViewController.h"
#import "RCTransationPersistModel.h"
#import <RongIMKit/RCKitTranslationConfig.h>
#import <RongIMKit/RCKitConfig.h>

static NSString * const RCDTranslationCellIdentifier = @"RCDTranslationCellIdentifier";
@interface RCDTranslationViewController ()
@property (nonatomic, strong) NSDictionary *languageInfo;
@property (nonatomic, strong) RCTransationPersistModel *translationConfig;
@end

@implementation RCDTranslationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"translationSetting");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDTranslationCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:RCDTranslationCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    NSString *title = @"None";
    if (indexPath.row == 0) {
        if (self.translationConfig.srcLanguage) {
            title = self.languageInfo[self.translationConfig.srcLanguage] ?: title;
        }
        cell.textLabel.text = RCDLocalizedString(@"SrcLanguage");
        cell.detailTextLabel.text = title;
    } else {
        if (self.translationConfig.targetLanguage) {
            title = self.languageInfo[self.translationConfig.targetLanguage] ?: title;
        }
        cell.textLabel.text = RCDLocalizedString(@"TargetLanguage");
        cell.detailTextLabel.text = title;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self)weakSelf = self;

    if (indexPath.row == 0) {
       
        RCDTranslationLanguageViewController *vc = [[RCDTranslationLanguageViewController alloc] initWithStyle:UITableViewStylePlain                                                                                                      language:self.translationConfig.srcLanguage
                                                                                                 languagesInfo:self.languageInfo
                                                                                                    completion:^(NSString *language) {

            weakSelf.translationConfig.srcLanguage = language;
            [weakSelf.translationConfig save];
            [weakSelf configureTranslation:language
                                            target:weakSelf.translationConfig.targetLanguage];
            [weakSelf.tableView reloadData];
        }];
        vc.title = RCDLocalizedString(@"SrcLanguage");
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        RCDTranslationLanguageViewController *vc = [[RCDTranslationLanguageViewController alloc] initWithStyle:UITableViewStylePlain
                                                                                                      language:self.translationConfig.targetLanguage
                                                                                                 languagesInfo:self.languageInfo
                                                                                                    completion:^(NSString *language) {
            weakSelf.translationConfig.targetLanguage = language;
            [weakSelf.translationConfig save];
            [weakSelf configureTranslation:weakSelf.translationConfig.srcLanguage
                                            target:language];
            [weakSelf.tableView reloadData];
        }];
        vc.title =RCDLocalizedString(@"TargetLanguage");
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/// 配置翻译语言类型
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

/// 语言类型
- (NSDictionary *)languagesSupported {
    NSDictionary *dic = @{
        @"af" : @"南非荷兰语",
        @"sq" : @"阿尔巴尼亚语",
        @"am" : @"阿姆哈拉语",
        @"ar" : @"阿拉伯语",
        @"hy" : @"亚美尼亚语",
        @"az" : @"阿塞拜疆语",
        @"eu" : @"巴斯克语",
        @"be" : @"白俄罗斯语",
        @"bn" : @"孟加拉语",
        @"bs" : @"波斯尼亚语",
        @"bg" : @"保加利亚语",
        @"my" : @"缅甸语",
        @"ca" : @"加泰罗尼亚语",
        @"ceb" : @"宿务语",
        @"zh_CN" : @"中文（简体)",
        @"zh_TW" : @"中文（繁体)",
        @"co" : @"科西嘉语",
        @"hr" : @"克罗地亚语",
        @"cs" : @"捷克语",
        @"da" : @"丹麦语",
        @"nl" : @"荷兰语",
        @"en" : @"英语",
        @"eo" : @"世界语",
        @"et" : @"爱沙尼亚语",
        @"tl" : @"菲律宾语",
        @"fi" : @"芬兰语",
        @"fr_FR" : @"法语（法国)",
        @"fr" : @"法语",
        @"fy" : @"弗里斯兰语",
        @"gl" : @"加利西亚语",
        @"ka" : @"格鲁吉亚语",
        @"de" : @"德语",
        @"el" : @"希腊语",
        @"gu" : @"古吉拉特语",
        @"ht" : @"海地克里奥尔语",
        @"ha" : @"豪萨语",
        @"haw" : @"夏威夷语",
        @"iw" : @"希伯来语",
        @"hi" : @"印地语",
        @"hmn" : @"苗语",
        @"hu" : @"匈牙利语",
        @"is" : @"冰岛语",
        @"ig" : @"伊博语",
        @"id" : @"印度尼西亚语",
        @"ga" : @"爱尔兰语",
        @"it" : @"意大利语",
        @"ja" : @"日语",
        @"jv" : @"爪哇语",
        @"kn" : @"卡纳达语",
        @"kk" : @"哈萨克语",
        @"km" : @"高棉语",
        @"rw" : @"卢旺达语",
        @"ko" : @"韩语",
        @"ku" : @"库尔德语",
        @"ky" : @"吉尔吉斯语",
        @"lo" : @"老挝语",
        @"lv" : @"拉脱维亚语",
        @"lt" : @"立陶宛语",
        @"lb" : @"卢森堡语",
        @"mk" : @"马其顿语",
        @"mg" : @"马尔加什语",
        @"ms" : @"马来语",
        @"ml" : @"马拉雅拉姆语",
        @"mt" : @"马耳他语",
        @"mi" : @"毛利语",
        @"mr" : @"马拉地语",
        @"mn" : @"蒙古语"
    };
    return dic;
}

#pragma mark - Property

- (NSDictionary *)languageInfo {
    if (!_languageInfo) {
        _languageInfo = [self languagesSupported];
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
