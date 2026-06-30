//
//  RCDImageSlideController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDImageSlideController.h"
#import "RCDQRInfoHandle.h"
#import "RCDQRCodeManager.h"
#import "RCDUtilities.h"
#import "RCNDScannerViewModel.h"
#import "RCUChatViewController.h"
#import "RCNDJoinGroupViewController.h"

@interface RCDImageSlideController ()<RCNDScannerViewModelDelegate>
@property (nonatomic, strong) RCNDScannerViewModel *scannerViewModel;
@end

@implementation RCDImageSlideController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - over method
- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        if (![self getCurrentPreviewImageData]) {
            return;
        }
        NSArray *actions = @[RCLocalizedString(@"Save")];
        NSString *info = [RCDQRCodeManager decodeQRCodeImage:[UIImage imageWithData:[self getCurrentPreviewImageData]]];
        if (info) {
            actions = @[RCLocalizedString(@"Save"), RCDLocalizedString(@"IdentifyQRCode")];
        }
        [RCActionSheetView showActionSheetView:nil cellArray:actions cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
            if (index == 0) {
                [self saveImage];
            }else{
                if ([[RCIM sharedRCIM] currentDataSourceType] == RCDataSourceTypeInfoManagement) {
                    [self.scannerViewModel identifyQRCode:info];
                } else {
                    [[RCDQRInfoHandle alloc] identifyQRCode:info base:self];
                }
            }
        } cancelBlock:^{
            
        }];
    }
}

#pragma mark - private
- (void)saveImage {
    [RCDUtilities savePhotosAlbumWithImage:[UIImage imageWithData:[self getCurrentPreviewImageData]] authorizationStatusBlock:^{
        [RCAlertView showAlertController:RCLocalizedString(@"AccessRightTitle")
                                 message:RCLocalizedString(@"photoAccessRight")
                             cancelTitle:RCLocalizedString(@"OK")
                        inViewController:self];
    } resultBlock:^(BOOL success) {
        [self showAlertWithSuccess:success];
    }];
}

- (void)showAlertWithSuccess:(BOOL)success {
    if (success) {
        [RCAlertView showAlertController:nil
                                 message:RCLocalizedString(@"SavePhotoSuccess")
                             cancelTitle:RCLocalizedString(@"OK") inViewController:self];
    } else {
        [RCAlertView showAlertController:nil
                                 message:RCLocalizedString(@"SavePhotoFailed")
                             cancelTitle:RCLocalizedString(@"OK") inViewController:self];
    }
}

#pragma mark - helper
- (NSData *)getCurrentPreviewImageData {
    NSData *imageData;
    if (self.currentPreviewImage.localPath.length > 0) {
        NSString *path = [RCUtilities getCorrectedFilePath:self.currentPreviewImage.localPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            imageData = [[NSData alloc] initWithContentsOfFile:path];
        }
    }
    if (!imageData) {
        imageData = [RCKitUtility getImageDataForURLString:self.currentPreviewImage.imageUrl];
    }
    return imageData;
}

#pragma mark - RCNDScannerViewModelDelegate
- (RCNDScannerViewModel *)scannerViewModel {
    if (!_scannerViewModel) {
        _scannerViewModel = [RCNDScannerViewModel new];
        _scannerViewModel.viewController = self;
        _scannerViewModel.delegate = self;
    }
    return _scannerViewModel;
}

- (void)openURLInQRCode:(NSString *)urlString {
    [RCKitUtility openURLInSafariViewOrWebView:urlString base:self];
}

- (void)showUserProfileInQRCode:(NSString *)userID {
    RCUserProfileViewModel *vm = [RCUserProfileViewModel viewModelWithUserId:userID];
    RCProfileViewController *vc = [[RCProfileViewController alloc] initWithViewModel:vm];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)showGroupConversationInQRCode:(NSString *)groupId title:(NSString *)title {
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.targetId = groupId;
    chatVC.title = title;
    chatVC.conversationType = ConversationType_GROUP;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)showGroupJoinViewInQRCode:(RCGroupInfo *)info {
    RCNDJoinGroupViewController *vc = [[RCNDJoinGroupViewController alloc] initWithGroupInfo:info];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
