//
//  RCNDMeViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMeViewModel.h"
#import "RCNDImageCellViewModel.h"
#import "RCDLanguageManager.h"
#import "RCDThemesContext.h"
#import "RCNDMeHeaderView.h"
#import "RCNDAccountSettingViewController.h"
#import "RCNDLanguageViewController.h"
#import "RCNDTranslationViewController.h"
#import "RCNDThemeViewController.h"
#import <RongCustomerService/RongCustomerService.h>
#import "RCDEnvironmentContext.h"
#import "RCDCustomerServiceViewController.h"
#import "RCNDAboutViewController.h"


@interface RCNDMeViewModel()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSDictionary *languageDic;
@property (nonatomic, strong) RCNDImageCellViewModel *theme;
@property (nonatomic, strong) RCNDImageCellViewModel *language;
@end


@implementation RCNDMeViewModel

- (void)ready {
    [super ready];
    self.languageDic = [RCNDLanguageViewModel languageInfo];

    __weak typeof(self) weakSelf = self;

    RCNDImageCellViewModel *account = [[RCNDImageCellViewModel alloc] initWithTapBlock:^(UIViewController * vc) {
        RCNDAccountSettingViewModel *vm = [RCNDAccountSettingViewModel new];
        RCNDAccountSettingViewController *controller = [[RCNDAccountSettingViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    account.imageName = @"icon_account";
    account.title = RCDLocalizedString(@"account_setting");
    [self.dataSource addObject:account];
    
    RCNDImageCellViewModel *language = [[RCNDImageCellViewModel alloc] initWithTapBlock:^(UIViewController * vc) {
        RCNDLanguageViewModel *vm = [[RCNDLanguageViewModel alloc] initWithBlock:^(NSString * string) {
            [weakSelf refreshLanguageCell:string];
        }];
        RCNDLanguageViewController *controller = [[RCNDLanguageViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    language.imageName = @"icon_language";
    language.title = RCDLocalizedString(@"language");
    
    NSString *currentLanguage = [RCNDLanguageViewModel currentLanguage];
    NSString *currentLanguageString = self.languageDic[currentLanguage];
    NSString *rightString = currentLanguageString ? currentLanguageString : RCDLocalizedString(@"language");
    language.subtitle = rightString;
    self.language = language;
    [self.dataSource addObject:language];
    
    RCNDImageCellViewModel *translation = [[RCNDImageCellViewModel alloc] initWithTapBlock:^(UIViewController * vc) {
        RCNDTranslationViewModel *vm = [RCNDTranslationViewModel new];
        RCNDTranslationViewController *controller = [[RCNDTranslationViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    translation.imageName = @"icon_translation";
    translation.title = RCDLocalizedString(@"translationSetting");
    [self.dataSource addObject:translation];
    
    RCNDImageCellViewModel *theme = [[RCNDImageCellViewModel alloc] initWithTapBlock:^(UIViewController * vc) {
        RCNDThemeViewModel *vm = [[RCNDThemeViewModel alloc] initWithBlock:^(NSString * themeString) {
            [weakSelf refreshThemeCell:themeString];
        }];
        RCNDThemeViewController *controller = [[RCNDThemeViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    theme.imageName = @"icon_theme";
    theme.title = RCDLocalizedString(@"Themes");
    theme.subtitle = [RCNDThemeViewModel currentThemeTitle];
    self.theme = theme;
    [self.dataSource addObject:theme];
    
    RCNDImageCellViewModel *feedback = [[RCNDImageCellViewModel alloc] initWithTapBlock:^(UIViewController * vc) {
        [weakSelf chatWithCustomerService:vc];
    }];
    feedback.imageName = @"icon_feedback";
    feedback.title = RCDLocalizedString(@"feedback");
    [self.dataSource addObject:feedback];
//    
//    RCNDImageCellViewModel *privacy = [[RCNDImageCellViewModel alloc] initWithTapBlock:^(UIViewController * vc) {
//        
//    }];
//    privacy.imageName = @"icon_privacy";
//    privacy.title = RCDLocalizedString(@"Privacy_Policy");
//    [self.dataSource addObject:privacy];
    
    RCNDImageCellViewModel *about = [[RCNDImageCellViewModel alloc] initWithTapBlock:^(UIViewController * vc) {
        RCNDAboutViewModel *vm = [RCNDAboutViewModel new];
        RCNDAboutViewController *controller = [[RCNDAboutViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    about.imageName = @"icon_abount";
    about.title = RCDLocalizedString(@"about_st");
    about.hideSeparatorLine = YES;
    [self.dataSource addObject:about];
}

- (void)refreshLanguageCell:(NSString *)language {
    self.language.subtitle = language;
    [self reloadData];
}

- (void)refreshThemeCell:(NSString *)theme {
    self.theme.subtitle = theme;
    [self reloadData];
}

- (void)reloadData {
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDImageCell class]
      forCellReuseIdentifier:RCNDImageCellIdentifier];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}


- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}



- (void)chatWithCustomerService:(UIViewController *)controller {
    NSString *serviceID = [RCDEnvironmentContext serviceID];

    RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];

    // live800  KEFU146227005669524   live800的客服ID
    // zhichi   KEFU146001495753714   智齿的客服ID
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;

    chatService.targetId = serviceID;

    //上传用户信息，nickname是必须要填写的
    RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
    csInfo.userId = [RCCoreClient sharedCoreClient].currentUserInfo.userId;
    csInfo.nickName = RCDLocalizedString(@"nickname");
    csInfo.loginName = @"登录名称";
    csInfo.name = [RCCoreClient sharedCoreClient].currentUserInfo.name;
    csInfo.grade = @"11级";
    csInfo.gender = @"男";
    csInfo.birthday = @"2016.5.1";
    csInfo.age = @"36";
    csInfo.profession = @"software engineer";
    csInfo.portraitUrl = [RCCoreClient sharedCoreClient].currentUserInfo.portraitUri;
    csInfo.province = @"beijing";
    csInfo.city = @"beijing";
    csInfo.memo = @"这是一个好顾客!";

    csInfo.mobileNo = @"13800000000";
    csInfo.email = @"test@example.com";
    csInfo.address = @"北京市北苑路北泰岳大厦";
    csInfo.QQ = @"88888888";
    csInfo.weibo = @"my weibo account";
    csInfo.weixin = @"myweixin";

    csInfo.page = @"卖化妆品的页面来的";
    csInfo.referrer = @"10001";
    csInfo.enterUrl = @"testurl";
    csInfo.skillId = @"技能组";
    csInfo.listUrl = @[ @"用户浏览的第一个商品Url", @"用户浏览的第二个商品Url" ];
    csInfo.define = @"自定义信息";

    chatService.csInfo = csInfo;
    chatService.title = RCDLocalizedString(@"feedback");

    [controller.navigationController pushViewController:chatService animated:YES];
}

- (void)clearAccountInfo {
    [RCNDAccountSettingViewModel clearAccountInfo];
}

+ (void)fetchMyProfile:(void(^)(RCUserProfile * _Nullable userProfile))completion {
    [[RCCoreClient sharedCoreClient] getMyUserProfile:^(RCUserProfile * _Nonnull userProfile) {
        if (completion) {
            completion(userProfile);
        }
    } error:^(RCErrorCode errorCode) {
        if (completion) {
            completion(nil);
        }
    }];
}
@end
