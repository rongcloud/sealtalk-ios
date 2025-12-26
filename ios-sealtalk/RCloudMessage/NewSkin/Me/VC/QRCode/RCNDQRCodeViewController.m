//
//  RCNDQRCodeViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRCodeViewController.h"
#import "RCDCommonString.h"
#import "RCDQRCodeManager.h"
#import "RCDForwardManager.h"
#import "RCDUtilities.h"
#import "RCNDQRForwardConversationViewController.h"
#import "RCDNavigationViewController.h"

@interface RCNDQRCodeViewController ()<RCNDQRForwardConversationViewModelDelegate>
@end

@implementation RCNDQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLeftBackButton];

}
- (void)loadView {
    self.view = self.qrView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showQRInfo];
}

- (void)showQRInfo {
   
}

- (UIImage *)captureCurrentView:(UIView *)view {
    CGRect frame = view.frame;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (RCNDQRCodeView *)qrView {
    if (!_qrView) {
        _qrView = [RCNDQRCodeView new];
        [_qrView.buttonSave addTarget:self
                               action:@selector(saveAlbum)
                     forControlEvents:UIControlEventTouchUpInside];
        [_qrView.buttonRongCloud addTarget:self
                               action:@selector(shareToIM)
                     forControlEvents:UIControlEventTouchUpInside];
    }
    return _qrView;
}

- (void)saveAlbum {
    UIImage *image = [self captureCurrentView:self.qrView.infoContainerView];
    [RCDUtilities savePhotosAlbumWithImage:image authorizationStatusBlock:^{
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        [RCAlertView showAlertController:RCLocalizedString(@"AccessRightTitle")
                                 message:RCLocalizedString(@"photoAccessRight")
                             cancelTitle:RCLocalizedString(@"OK")
                        inViewController:self];
    } resultBlock:^(BOOL success) {
        [self showTips:success?RCLocalizedString(@"SavePhotoSuccess"):RCLocalizedString(@"SavePhotoFailed")];
    }];
}

- (void)shareToIM {
    UIImage *image = [self captureCurrentView:self.qrView.infoContainerView];
    RCImageMessage *msg = [RCImageMessage messageWithImage:image];
    msg.full = YES;
    RCMessage *message = [[RCMessage alloc] initWithType:1
                                                targetId:[RCIM sharedRCIM].currentUserInfo.userId
                                               direction:(MessageDirection_SEND)
                                               messageId:-1
                                                 content:msg];
    [[RCDForwardManager sharedInstance]
        setWillForwardMessageBlock:^(RCConversationType type, NSString *_Nonnull targetId) {
            [[RCIM sharedRCIM] sendMediaMessage:type
                targetId:targetId
                content:msg
                pushContent:nil
                pushData:nil
                progress:^(int progress, long messageId) {

                }
                success:^(long messageId) {

                }
                error:^(RCErrorCode errorCode, long messageId) {

                }
                cancel:^(long messageId){

                }];
        }];
    [RCDForwardManager sharedInstance].isForward = YES;
    [RCDForwardManager sharedInstance].isMultiSelect = NO;
    [RCDForwardManager sharedInstance].selectedMessages = @[ [RCMessageModel modelWithMessage:message] ];
    RCNDQRForwardConversationViewModel *vm = [RCNDQRForwardConversationViewModel new];
    vm.forwardDelegate = self;
    RCNDQRForwardConversationViewController *forwardSelectedVC = [[RCNDQRForwardConversationViewController alloc] initWithViewModel:vm];
    RCDNavigationViewController *navi = [[RCDNavigationViewController alloc] initWithRootViewController:forwardSelectedVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark - RCNDQRForwardConversationViewModelDelegate
- (void)userDidSelectedForwardViewModel:(RCNDQRForwardSelectCellViewModel *)viewModel parentViewController:(nonnull UIViewController *)controller{
    [controller.navigationController dismissViewControllerAnimated:YES completion:^{
            [[RCDForwardManager sharedInstance] showForwardAlertViewWith:viewModel inViewController:nil];
    }];
}
@end
