//
//  RCDLanguageSettingViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/2/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDLanguageSettingViewController.h"
#import "AppDelegate.h"
#import "RCDLanguageManager.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "UIColor+RCColor.h"
#import "RCDLanguageSettingTableViewCell.h"
#import "RCDTableView.h"
#import "UIView+MBProgressHUD.h"
@interface RCDLanguageSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *currentLanguage;
@property (nonatomic, strong) NSDictionary *languageDic;

@end

@implementation RCDLanguageSettingViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"language");

    self.languageDic = @{ @"en" : @"English", @"zh-Hans" : @"简体中文", @"ar" : @"العربية"};
    self.language = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
    self.currentLanguage = self.language;

    [self setNavigationBar];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.bounds;
    [self.tableView reloadData];
}

#pragma mark - Target action
- (void)save {
    RCPushLauguage lauguage = RCPushLauguage_EN_US;
    if ([self.language isEqualToString:@"ar"]) {
        lauguage = RCPushLauguage_AR_SA;
    } else if ([self.language isEqualToString:@"zh-Hans"]) {
        lauguage = RCPushLauguage_ZH_CN;
    } else {
        lauguage = RCPushLauguage_EN_US;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[RCCoreClient sharedCoreClient].pushProfile setPushLauguage:lauguage success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIWindow *keyWindow;
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                if ([window isKeyWindow]) {
                    keyWindow = window;
                }
            }
            //重置vc堆栈
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if (lauguage== RCPushLauguage_AR_SA) {
                [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
                keyWindow.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
                app.window.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
            } else {
                [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
                keyWindow.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
                app.window.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
            }
        
            //设置当前语言
            [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:self.language];
           
            RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
            RCDNavigationViewController *nav = [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
            mainTabBarVC.selectedIndex = 3;
            app.window.rootViewController = nav;
         
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.view showHUDMessage:[NSString stringWithFormat:@"%@ %ld", RCDLocalizedString(@"Failed"), (long)status]];
        });
    }];
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"current language %@", self.languageDic.allValues[indexPath.row]);

    self.language = self.languageDic.allKeys[indexPath.row];

    if ([self.language containsString:self.currentLanguage]) {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithHexString:@"3A91F3" alpha:0.4]];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    return view;
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languageDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCELanguageSettingViewControllerCell";
    RCDLanguageSettingTableViewCell *cell =
        [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDLanguageSettingTableViewCell alloc] init];
    }
    NSString *key = self.languageDic.allKeys[indexPath.row];
    cell.leftLabel.text = [self.languageDic valueForKey:key];
    cell.rightImageView.image = [key containsString:self.language] ? [UIImage imageNamed:@"select"] : nil;
    return cell;
}

- (void)setNavigationBar {
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"save")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Getters and setters
- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        }
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            _tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
        }
    }
    return _tableView;
}

@end
