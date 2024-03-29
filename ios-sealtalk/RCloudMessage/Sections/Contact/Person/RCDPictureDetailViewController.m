//
//  RCDPictureDetailViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPictureDetailViewController.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUIBarButtonItem.h"
#import "UIView+MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDPictureDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation RCDPictureDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavi];
    [self addSubviews];
    [self updateImageView];
}

- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"ImageDetail");

    self.navigationItem.leftBarButtonItems = [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn:)];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"More")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(moreAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)addSubviews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.imageView];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(self.view);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.right.equalTo(self.contentView).inset(10);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

- (void)updateImageView {
    self.imageView.image = self.image;
    int imageW = self.image.size.width;
    int imageH = self.image.size.height;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.right.equalTo(self.contentView).inset(10);
        make.height.offset((RCDScreenWidth - 20) / imageW * imageH);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

- (void)saveImage {
    [RCDUtilities savePhotosAlbumWithImage:self.image authorizationStatusBlock:^{
        [RCAlertView showAlertController:RCLocalizedString(@"AccessRightTitle")
                                 message:RCLocalizedString(@"photoAccessRight")
                             cancelTitle:RCLocalizedString(@"OK")
                        inViewController:self];
    } resultBlock:^(BOOL success) {
        [self showHUDWithSuccess:success];
    }];
}

- (void)showHUDWithSuccess:(BOOL)success {
    if (success) {
        [self.view showHUDMessage:RCLocalizedString(@"SavePhotoSuccess")];
    } else {
        [self.view showHUDMessage:RCLocalizedString(@"SavePhotoFailed")];
    }
}

#pragma mark - Target Action
- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreAction {
    [RCActionSheetView showActionSheetView:nil cellArray:@[RCDLocalizedString(@"SaveToAlbum"), RCDLocalizedString(@"DeletePicture")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
        if (index == 0) {
            [self saveImage];
        }else{
           self.imageView.image = nil;
           if (self.deleteImageBlock) {
               self.deleteImageBlock();
           }
           [self.navigationController popViewControllerAnimated:YES];
        }
    } cancelBlock:^{
            
    }];
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return _imageView;
}

@end
