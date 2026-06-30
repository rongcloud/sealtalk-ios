//
//  RCNDLanguageSupportedViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDLanguageSupportedViewModel.h"
#import "RCNDRadioCellViewModel.h"

@interface RCNDLanguageSupportedViewModel()
@property (nonatomic, copy) RCNDLanguageSupportedViewModelBlock block;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSDictionary *languagesInfo;
@property (nonatomic, strong) RCNDRadioCellViewModel *currentVM;
@end

@implementation RCNDLanguageSupportedViewModel

- (instancetype)initWithLanguage:(NSString *)language
                           block:(RCNDLanguageSupportedViewModelBlock)block
{
    self = [super init];
    if (self) {
        self.language = language;
        self.block = block;
        [self dataReady];
    }
    return self;
}

- (void)ready {
    [super ready];
    self.languagesInfo = [[self class] languagesSupported];
    self.keys = [self.languagesInfo allKeys];
}

- (void)dataReady {
    NSMutableArray *tmp = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    for (NSString *key in self.keys) {
        RCNDRadioCellViewModel *vm = [[RCNDRadioCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
            [weakSelf reloadData:key];
        }];
        vm.title = self.languagesInfo[key];
        BOOL ret = [key isEqualToString:self.language];
        vm.selected = ret;
        if (ret) {
            self.currentVM = vm;
        }
        [tmp addObject:vm];
    }
    self.dataSource = tmp;
    [self removeSeparatorLineIfNeed:@[self.dataSource]];
}

- (void)save {
    if (self.block) {
        self.block(self.language);
    }
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
    self.language = lan;
    NSInteger index = [self.keys indexOfObject:lan];
    self.currentVM.selected = NO;
    self.currentVM = self.dataSource[index];
    self.currentVM.selected = YES;
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
}


/// 语言类型
+ (NSDictionary *)languagesSupported {
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

@end
