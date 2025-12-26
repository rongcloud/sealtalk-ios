//
//  RCNDConversationBackgroundViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDConversationBackgroundViewController.h"
#import "RCNDBackgroundDetailViewController.h"
#import <Photos/Photos.h>
@interface RCNDConversationBackgroundViewController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation RCNDConversationBackgroundViewController

- (void)setupView {
    [super setupView];
    [self configureLeftBackButton];
    self.title = RCDLocalizedString(@"ChatBackground");
}


#pragma mark - UICollectionViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (indexPath.row == 1) {
        [self checkPhotoLibraryAuthorization];
       
    }
}

- (void)checkPhotoLibraryAuthorization {
    // 检测当前授权状态
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            // 已授权：直接打开相册
            [self openImagePicker];
            break;
            
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            // 拒绝/受限：引导用户到设置页开启权限
            [self showPermissionAlert];
            break;
            
        case PHAuthorizationStatusNotDetermined:
            // 未决定：请求授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PHAuthorizationStatusAuthorized) {
                        [self openImagePicker];
                    } else {
                        
                        [self showPermissionAlert];
                    }
                });
            }];
            break;
    }
}
// 引导用户到设置页的弹窗
- (void)showPermissionAlert {

    [RCAlertView showAlertController:RCLocalizedString(@"PhotoAccessRight")
                             message:nil
                         cancelTitle:RCDLocalizedString(@"confirm")];
}


- (void)openImagePicker {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        RCNDBackgroundDetailViewController *detailVC =
            [[RCNDBackgroundDetailViewController alloc] initWithImage:originImage];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
