//
//  RCNDSScanViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDScannerViewController.h"
#import "RCNDScannerView.h"
#import "RCDQRCodeManager.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+MBProgressHUD.h"
#import "RCDQRInfoHandle.h"
#import <RongIMKit/RCKitCommonDefine.h>
#import <RongIMKit/RongIMKit.h>
#import "RCUChatViewController.h"
#import "RCNDJoinGroupViewController.h"
#import "RCNDScannerViewModel.h"
@interface RCNDScannerViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate,RCNDScannerViewModelDelegate>

/** 扫描器 */
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) RCNDScannerView *scannerView;
@property (nonatomic, strong) RCNDScannerViewModel *viewModel;
@end

@implementation RCNDScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkCameraAuthorizationStatus];
    [self configureNavi];
    [self.view addSubview:self.scannerView];
    [self configureLeftBackButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)leftBarButtonBackAction {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resumeScanning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scannerView rcd_setFlashlightOn:NO];
    [self.scannerView rcd_hideFlashlightWithAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark-- AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output
didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    // 获取扫一扫结果
    if (metadataObjects && metadataObjects.count > 0) {
        [self pauseScanning];
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *stringValue = metadataObject.stringValue;
        [self rcd_handleWithValue:stringValue];
    } else {
        [self showErrorAlertView];
    }
}

#pragma mark -  RCDScannerViewDelegate
- (void)didClickSelectImageButton {
    [self showAlbum];
}

#pragma mark-- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    // 获取选择图片中识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithData:UIImagePNGRepresentation(pickImage)]];
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
        if (features.count > 0) {
            CIQRCodeFeature *feature = features[0];
            NSString *stringValue = feature.messageString;
            [self rcd_handleWithValue:stringValue];
        } else {
            [self rcd_didReadFromAlbumFailed];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - private
- (void)showErrorAlertView {
    [RCAlertView showAlertController:nil message:RCDLocalizedString(@"QRIdentifyError") actionTitles:nil cancelTitle:nil confirmTitle:RCLocalizedString(@"Confirm") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:nil confirmBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    } inViewController:self];
}

- (void)configureNavi {
    self.navigationItem.title = RCDLocalizedString(@"qr_scan");
    
    UIBarButtonItem *albumItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"PhotoAlbum")
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showAlbum)];
    self.navigationItem.rightBarButtonItem = albumItem;
}

- (void)checkCameraAuthorizationStatus {
    // 校验相机权限
    [RCDQRCodeManager rcd_checkCameraAuthorizationStatusWithGrand:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupScanner];
            });
        }
    }];
}

/** 创建扫描器 */
- (void)setupScanner {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    metadataOutput.rectOfInterest = CGRectMake([self.scannerView scanner_y] / self.view.frame.size.height,
                                               [self.scannerView scanner_x] / self.view.frame.size.width,
                                               [self.scannerView scanner_width] / self.view.frame.size.height,
                                               [self.scannerView scanner_width] / self.view.frame.size.width);
    
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    if ([self.session canAddOutput:metadataOutput]) {
        [self.session addOutput:metadataOutput];
    }
    if ([self.session canAddOutput:videoDataOutput]) {
        [self.session addOutput:videoDataOutput];
    }
#if TARGET_IPHONE_SIMULATOR
    // 模拟器设置不了，会crash
#else
    if ([metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeQRCode ];
    }
#endif
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPreviewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:videoPreviewLayer atIndex:0];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.session startRunning];
    });
}

- (void)pushImagePicker {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showAlbum {
    // 校验相册权限
    [RCDQRCodeManager rcd_checkAlbumAuthorizationStatusWithGrand:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pushImagePicker];
            });
        }
    }];
}

- (void)appDidBecomeActive:(NSNotification *)notify {
    [self resumeScanning];
}

- (void)appWillResignActive:(NSNotification *)notify {
    [self pauseScanning];
    [self.scannerView rcd_hideFlashlightWithAnimated:YES];
}

/** 恢复扫一扫功能 */
- (void)resumeScanning {
    if (self.session) {
        [self.session startRunning];
        [self.scannerView rcd_addScannerLineAnimation];
    }
}

/** 暂停扫一扫功能 */
- (void)pauseScanning {
    if (self.session) {
        [self.session stopRunning];
        [self.scannerView rcd_pauseScannerLineAnimation];
    }
}

/**
 处理扫一扫结果
 @param value 扫描结果
 */
- (void)rcd_handleWithValue:(NSString *)value {
    [self identifyQRCode:value];
}

/**
 相册选取图片无法读取数据
 */
- (void)rcd_didReadFromAlbumFailed {
    [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
}

#pragma mark - Result
- (void)identifyQRCode:(NSString *)info {
    [self.viewModel identifyQRCode:info];
}

#pragma mark - RCNDScannerViewModelDelegate

- (void)showGroupJoinViewInQRCode:(RCGroupInfo *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self leftBarButtonBackAction];
        if ([self.delegate respondsToSelector:@selector(showGroupJoinViewInQRCode:)]) {
            [self.delegate showGroupJoinViewInQRCode:info];
        }
    });
  
}

- (void)showGroupConversationInQRCode:(NSString *)groupId title:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self leftBarButtonBackAction];
        if ([self.delegate respondsToSelector:@selector(showGroupConversationInQRCode:title:)]) {
            [self.delegate showGroupConversationInQRCode:groupId title:title];
        }
    });
   
}

- (void)showUserProfileInQRCode:(NSString *)userID  {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self leftBarButtonBackAction];

        if ([self.delegate respondsToSelector:@selector(showUserProfileInQRCode:)]) {
            [self.delegate showUserProfileInQRCode:userID];
        }
    });
   
}

- (void)openURLInQRCode:(NSString *)urlString {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self leftBarButtonBackAction];
        if ([self.delegate respondsToSelector:@selector(openURLInQRCode:)]) {
            [self.delegate openURLInQRCode:urlString];
        }
    });
 
}



- (void)showAlert:(NSString *)alertContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCAlertView showAlertController:nil
                                 message:alertContent
                             cancelTitle:RCDLocalizedString(@"confirm")
                        inViewController:self];
    });
    
}

- (RCNDScannerView *)scannerView {
    if (!_scannerView) {
        _scannerView = [[RCNDScannerView alloc] initWithFrame:self.view.bounds];
        [_scannerView.selectImageBtn addTarget:self
                                        action:@selector(didClickSelectImageButton)
                              forControlEvents:UIControlEventTouchUpInside];
    }
    return _scannerView;
}

- (RCNDScannerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [RCNDScannerViewModel new];
        _viewModel.delegate = self;
        _viewModel.viewController = self;
    }
    return _viewModel;
}

@end
