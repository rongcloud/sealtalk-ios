//
//  RCDDebugMessageAuditInfoViewController.m
//  SealTalk
//
//  Created by Lang on 2023/7/14.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDDebugMessageAuditInfoViewController.h"
#import <Masonry/Masonry.h>
#import "RCDCommonString.h"

@interface RCDDebugMessageAuditInfoViewController ()

@property (nonatomic, strong) UIButton *enableAuditButton;
@property (nonatomic, strong) UITextField *projectTextField;
@property (nonatomic, strong) UITextField *strategyTextField;

@end

@implementation RCDDebugMessageAuditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavi];
    [self setupUI];
    [self loadData];
}

- (void)setNavi {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)setupUI {
    [self.view addSubview:self.enableAuditButton];
    [self.view addSubview:self.projectTextField];
    [self.view addSubview:self.strategyTextField];
    
    [self.enableAuditButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.right.equalTo(self.view).inset(20);
        make.height.offset(30);
    }];
    
    [self.projectTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.enableAuditButton.mas_bottom).offset(20);
        make.height.left.right.equalTo(self.enableAuditButton);
    }];
    
    [self.strategyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.projectTextField.mas_bottom).offset(20);
        make.height.left.right.equalTo(self.enableAuditButton);
    }];
}

- (void)loadData {
    BOOL enableAudit = [DEFAULTS boolForKey:RCDDebugMessageAuditTypeKey];
    NSString *project = [DEFAULTS stringForKey:RCDDebugMessageAuditProjectKey];
    NSString *strategy = [DEFAULTS stringForKey:RCDDebugMessageAuditStrategyKey];
    
    self.enableAuditButton.selected = enableAudit;
    self.projectTextField.text = project;
    self.strategyTextField.text = strategy;
}

- (void)enableAuditAction:(UIButton *)button {
    button.selected = !button.selected;
}

- (void)saveAction {
    [DEFAULTS setBool:self.enableAuditButton.selected forKey:RCDDebugMessageAuditTypeKey];
    
    NSString *projectStr = [self.projectTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (projectStr.length > 0) {
        [DEFAULTS setObject:projectStr forKey:RCDDebugMessageAuditProjectKey];
    }
    
    NSString *strategyStr = [self.strategyTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strategyStr.length > 0) {
        [DEFAULTS setObject:strategyStr forKey:RCDDebugMessageAuditStrategyKey];
    }
    [DEFAULTS synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.view endEditing:YES];
}

- (UIButton *)enableAuditButton {
    if (!_enableAuditButton) {
        _enableAuditButton = [[UIButton alloc] init];
        [_enableAuditButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_enableAuditButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_enableAuditButton setTitle:@"□ 是否开启消息审核" forState:UIControlStateNormal];
        [_enableAuditButton setTitle:@"✅ 是否开启消息审核" forState:UIControlStateSelected];
        [_enableAuditButton addTarget:self action:@selector(enableAuditAction:) forControlEvents:UIControlEventTouchUpInside];
        _enableAuditButton.layer.borderWidth = 1;
        _enableAuditButton.layer.cornerRadius = 8;
    }
    return _enableAuditButton;
}

- (UITextField *)projectTextField {
    if (!_projectTextField) {
        _projectTextField = [[UITextField alloc] init];
        _projectTextField.placeholder = @"项目标识";
        _projectTextField.layer.borderWidth = 1;
    }
    return _projectTextField;
}

- (UITextField *)strategyTextField {
    if (!_strategyTextField) {
        _strategyTextField = [[UITextField alloc] init];
        _strategyTextField.placeholder = @"审核策略";
        _strategyTextField.layer.borderWidth = 1;
    }
    return _strategyTextField;
}

@end
