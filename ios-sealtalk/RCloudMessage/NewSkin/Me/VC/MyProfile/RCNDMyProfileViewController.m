//
//  RCNDMyProfileViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMyProfileViewController.h"
#import "UIImage+RCImage.h"
#import "RCDUploadManager.h"
#import "UIView+MBProgressHUD.h"

@interface RCProfileViewController ()
@property (nonatomic, strong) RCProfileViewModel *viewModel;
- (void)reloadData:(BOOL)isEmpty;
@end

@interface RCNDMyProfileViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation RCNDMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [RCViewModelAdapterCenter registerDelegate:self forViewModelClass:[RCMyProfileViewModel class]];
}

- (void)refreshPortrait:(NSString *)url {
    if ([self.viewModel isKindOfClass:[RCMyProfileViewModel class]]) {
        [self.viewModel updateProfile];
        if ([self.delegate respondsToSelector:@selector(refreshPortrait:)]) {
            [self.delegate refreshPortrait:url];
        }
    }
    [self reloadData:NO];
}
///// 即将加载数据源
///// - Parameters viewModel: viewModel
///// - Parameters  profileList: 当前数据源
///// - Returns: App处理后的数据源
/////
///// - Since: 5.12.0
//- (NSArray <NSArray <RCProfileCellViewModel*> *> * )profileViewModel:(RCProfileViewModel *)viewModel
//                                        willLoadProfileCellViewModel:(NSArray <NSArray <RCProfileCellViewModel*> *> *)profileList {
//    if ([viewModel isKindOfClass:[RCMyProfileViewModel class]]) {
//
//    }
//}

/// 用户点击Cell事件
///
/// - Parameters viewModel: viewModel
/// - Parameters viewController: 当前 VC
/// - Parameters tableView: tableView
/// - Parameters indexPath: indexPath
/// - Parameters cellViewModel: cellViewModel
/// - Returns: App是否处理[YES : SDK不再处理, NO: SDK处理]
///
/// - Since: 5.12.0
- (BOOL)profileViewModel:(RCProfileViewModel *)viewModel
          viewController:(UIViewController*)viewController
             tableView:(UITableView *)tableView
          didSelectRow:(NSIndexPath *)indexPath
           cellViewModel:(RCProfileCellViewModel *)cellViewModel {
    if (indexPath.row == 0) {
        [self showUserProfile];
    }
    return NO;
}


- (void)showUserProfile {
  
    [RCActionSheetView showActionSheetView:nil cellArray:@[RCDLocalizedString(@"take_picture"), RCDLocalizedString(@"my_album")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
        if (index == 0) {
            [self pushToImagePickerController:UIImagePickerControllerSourceTypeCamera];
        }else{
            [self pushToImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    } cancelBlock:^{
            
    }];
}


- (void)pushToImagePickerController:(UIImagePickerControllerSourceType)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = sourceType;
            } else {
                NSLog(@"模拟器无法连接相机");
            }
        } else {
            picker.sourceType = sourceType;
        }
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:nil];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;

    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSData *data = nil;
    if ([mediaType isEqual:@"public.image"]) {
        //获取原图
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //获取截取区域
        CGRect captureRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        //获取截取区域的图像
        UIImage *captureImage =
            [UIImage getSubImage:originImage Rect:captureRect imageOrientation:originImage.imageOrientation];
        UIImage *scaleImage = [UIImage scaleImage:captureImage toScale:0.8];
        data = UIImageJPEGRepresentation(scaleImage, 0.00001);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self uploadImage:data];
}


- (void)showAlertView:(NSString *)message cancelBtnTitle:(NSString *)cTitle {
    [RCAlertView showAlertController:nil message:message cancelTitle:cTitle inViewController:self];
}

- (void)updateCurrentUserPortraitUri:(NSString *)url {
    
    [self showLoading];
    [[RCCoreClient sharedCoreClient] getMyUserProfile:^(RCUserProfile * _Nonnull userProfile) {
            userProfile.portraitUri = url;
            [[RCCoreClient sharedCoreClient] updateMyUserProfile:userProfile success:^{
                [self hideLoading];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshPortrait:url];
                });
                } error:^(RCErrorCode errorCode, NSString * _Nullable errorKey) {
                    [self hideLoading];
                    [self showTips:RCDLocalizedString(@"Upload_avatar_fail")];
                }];
        
        RCUserInfo *refreshUser = [[RCUserInfo alloc] initWithUserId:userProfile.userId
                                                                name:userProfile.name
                                                            portrait:url];
        refreshUser.rc_profile = userProfile;
        [[RCIM sharedRCIM] refreshUserInfoCache:refreshUser withUserId:userProfile.userId];
        } error:^(RCErrorCode errorCode) {
            [self hideLoading];
            [self showTips:RCDLocalizedString(@"Upload_avatar_fail")];
        }];
    
}

- (void)uploadImage:(NSData *)data {
    [self showLoading];
    __weak typeof(self) ws = self;
    [RCDUploadManager uploadImage:data
                         complete:^(NSString *url) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (url.length > 0) {
                                     [ws updateCurrentUserPortraitUri:url];
                                 } else {
                                     //关闭HUD
                                     [ws hideLoading];
                                     [ws showAlertView:RCDLocalizedString(@"Upload_avatar_fail")
                                         cancelBtnTitle:RCDLocalizedString(@"confirm")];
                                 }
                             });
                         }];
}

- (void)showTips:(NSString *)tips {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:tips];
    });
}


- (void)showLoading {
    [self.view showLoading];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showLoading];
    });
}

- (void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view hideLoading];
    });
}



@end
