//
//  RCNDMeViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMeViewController.h"
#import "RCDCommonString.h"
#import "RCNDMeHeaderView.h"
#import "RCNDFooterView.h"
#import "RCNDMyQRViewController.h"
#import "RCNDLoginViewController.h"
#import "RCNDMeView.h"
#import "RCNDMyProfileViewController.h"

@interface RCNDMeViewController()<RCNDBaseListViewModelDelegate,RCNDMyProfileDelegate>
@property (nonatomic, strong) RCNDMeView *meView;
@property (nonatomic, strong) RCNDMeHeaderView *headerView;
@end

@implementation RCNDMeViewController

- (instancetype)initWithViewModel:(RCNDBaseListViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.listView = self.meView;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 进入页面时设置透明
    [self configureTransparentNavigationBar];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 离开页面时恢复默认样式
    [self restoreDefaultNavigationBarAppearance];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = RCDLocalizedString(@"me");
    [self configureTransparentNavigationBar];
}

- (void)setupView {
    [super setupView];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    RCNDMeHeaderView *headerView = [[RCNDMeHeaderView alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
    headerView.nameLabel.text = [DEFAULTS stringForKey:RCDUserNickNameKey];
    NSString *portraitUrl = [DEFAULTS stringForKey:RCDUserPortraitUriKey];
    [headerView showPortrait:portraitUrl];
    [RCNDMeViewModel fetchMyProfile:^(RCUserProfile * _Nullable userProfile) {
        if (userProfile) {
            NSString *portraitUrl = userProfile.portraitUri;
            NSString *idString = [NSString stringWithFormat:@"%@: %@", RCDLocalizedString(@"MyProfileAccount"), userProfile.uniqueId];
            if (userProfile.name) {
                [DEFAULTS setValue:userProfile.name forKey:RCDUserNickNameKey];
            }
            if (portraitUrl) {
                [DEFAULTS setValue:portraitUrl forKey:RCDUserPortraitUriKey];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                headerView.nameLabel.text = userProfile.name;
                [headerView showPortrait:portraitUrl];
                headerView.remarkLabel.text = idString;
            });
        }
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(showUserProfile)];
    [headerView addGestureRecognizer:tap];
    self.headerView = headerView;
    self.listView.tableView.tableHeaderView = headerView;
    

    RCNDFooterView *footer = [[RCNDFooterView alloc] initWithFrame:CGRectMake(0, 0, width, 82)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:RCDLocalizedString(@"logout") forState:UIControlStateNormal];
    [btn setBackgroundColor:RCDynamicColor(@"common_background_color", @"0xffffff", @"0x2d2d2d")];
    [btn setTitleColor:RCDynamicColor(@"hint_color", @"0xF74D43", @"0xFF5047")
              forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 6;
    [btn addTarget:self
                 action:@selector(logout)
       forControlEvents:UIControlEventTouchUpInside];
    [btn setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [footer.contentStackView addArrangedSubview:btn];
    self.listView.tableView.tableFooterView = footer;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"navi_qr_code"]
                                 forState:UIControlStateNormal];
    [rightBtn addTarget:self
                 action:@selector(showQRCode)
       forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)showUserProfile {
    RCMyProfileViewModel *vm = [[RCMyProfileViewModel alloc] init];
    RCNDMyProfileViewController *vc = [[RCNDMyProfileViewController alloc] initWithViewModel:vm];
    vc.delegate = self;
    [self pushViewController:vc];
}

#pragma mark - RCNDMyProfileDelegate

- (void)refreshPortrait:(NSString *)url {
    [DEFAULTS setObject:url forKey:RCDUserPortraitUriKey];
    [self.headerView showPortrait:url];
}

- (RCNDMeViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDMeViewModel class]]) {
        RCNDMeViewModel *vm = (RCNDMeViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}



- (void)logout {
    //退出登录
    [RCAlertView showAlertController:nil message:RCDLocalizedString(@"logout_alert") actionTitles:nil cancelTitle:RCDLocalizedString(@"cancel") confirmTitle:RCDLocalizedString(@"confirm") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:nil confirmBlock:^{
        [[self currentViewModel] clearAccountInfo];
        [self gotLogin];
    } inViewController:self];
  
}

- (void)gotLogin {
    RCNDLoginViewController *loginVC = [[RCNDLoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.view.window.rootViewController = navi;
}

- (void)showQRCode {
    RCNDMyQRViewController *vc = [RCNDMyQRViewController new];
    [self pushViewController:vc];
}

- (RCNDMeView *)meView {
    if (!_meView) {
        _meView = [RCNDMeView new];
        _meView.tableView.delegate = self;
        _meView.tableView.dataSource = self;
    }
    return _meView;
}
@end
