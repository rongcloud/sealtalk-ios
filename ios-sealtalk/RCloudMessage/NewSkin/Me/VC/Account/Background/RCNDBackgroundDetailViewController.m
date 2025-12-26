//
//  RCNDBackgroundDetailViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBackgroundDetailViewController.h"
#import "RCNDBackgroundDetailView.h"
#import "RCDCommonString.h"


@interface RCNDBackgroundDetailViewController ()
@property (nonatomic, strong) RCNDPreinstallPhotoCellViewModel *viewModel;
@property (nonatomic, strong) RCNDBackgroundDetailView *detailView;
@property (nonatomic, strong) UIImage *image;
@end

@implementation RCNDBackgroundDetailViewController

- (instancetype)initWithViewModel:(RCNDPreinstallPhotoCellViewModel *)viewModel {
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)loadView {
    self.view = self.detailView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.viewModel) {
        self.detailView.imageContent.image = [UIImage imageNamed:[self.viewModel detailImageName]];

    } else if(self.image) {
        self.detailView.imageContent.image = self.image;
    }
}

- (void)setupView {
    [super setupView];
    self.title = RCDLocalizedString(@"ChatBackground");
    [self configureLeftBackButton];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:RCDLocalizedString(@"confirm") forState:UIControlStateNormal];
    [btn setTitleColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x007acc")
              forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(confirm)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)confirm {
    if (self.image) {
        NSData *imageData = UIImageJPEGRepresentation(self.image, 0.8);
        [DEFAULTS setObject:RCDChatBackgroundFromAlbum forKey:RCDChatBackgroundKey];
        [DEFAULTS setObject:imageData forKey:RCDChatBackgroundImageDataKey];
    } else if(self.viewModel.detailImageName) {
        self.viewModel.selected = YES;
        if (![self.viewModel.imageName isEqualToString:@"chat_bg_select_0"]) {// 如果是第一个图片, 则移除背景
            [DEFAULTS setObject:self.viewModel.detailImageName forKey:RCDChatBackgroundKey];
        } else{
            [DEFAULTS removeObjectForKey:RCDChatBackgroundKey];
        }
        [DEFAULTS removeObjectForKey:RCDChatBackgroundImageDataKey];
    }
    [DEFAULTS synchronize];

    [self showTips:RCDLocalizedString(@"setting_success")];
    [self.navigationController popViewControllerAnimated:YES];
}

- (RCNDBackgroundDetailView *)detailView {
    if (!_detailView) {
        _detailView = [RCNDBackgroundDetailView new];
    }
    return _detailView;
}

@end
