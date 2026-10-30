//
//  RCDOpenClawCreateBotViewController.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawCreateBotViewController.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotTokenViewController.h"
#import "RCDOpenClawCreateBotViewModel.h"
#import "RCDUIBarButtonItem.h"
#import "UIView+MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RCDOpenClawCreateBotViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameTitleLabel;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) RCDOpenClawCreateBotViewModel *viewModel;

@end

@implementation RCDOpenClawCreateBotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"OpenClawCreateTitle");
    self.navigationItem.leftBarButtonItems =
        [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    self.view.backgroundColor = RCDDYCOLOR(0xf3f6f9, 0x111111);
    self.viewModel = [[RCDOpenClawCreateBotViewModel alloc] init];
    [self setupKeyboardDismissGesture];
    [self buildContent];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupKeyboardDismissGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)buildContent {
    NSLayoutYAxisAnchor *topAnchor = self.topLayoutGuide.bottomAnchor;
    NSLayoutYAxisAnchor *bottomAnchor = self.bottomLayoutGuide.topAnchor;
    if (@available(iOS 11.0, *)) {
        topAnchor = self.view.safeAreaLayoutGuide.topAnchor;
        bottomAnchor = self.view.safeAreaLayoutGuide.bottomAnchor;
    }

    [self.view addSubview:self.avatarView];
    [self.view addSubview:self.nameTitleLabel];
    [self.view addSubview:self.nameField];
    [self.view addSubview:self.createButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.avatarView.topAnchor constraintEqualToAnchor:topAnchor constant:68],
        [self.avatarView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.avatarView.widthAnchor constraintEqualToConstant:58],
        [self.avatarView.heightAnchor constraintEqualToConstant:58],

        [self.nameTitleLabel.topAnchor constraintEqualToAnchor:self.avatarView.bottomAnchor constant:47],
        [self.nameTitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.nameTitleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.nameTitleLabel.heightAnchor constraintEqualToConstant:21],

        [self.nameField.topAnchor constraintEqualToAnchor:self.nameTitleLabel.bottomAnchor constant:8],
        [self.nameField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.nameField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.nameField.heightAnchor constraintEqualToConstant:34],

        [self.createButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.createButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.createButton.bottomAnchor constraintEqualToAnchor:bottomAnchor constant:-25],
        [self.createButton.heightAnchor constraintEqualToConstant:42]
    ]];
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.layer.cornerRadius = 29;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.userInteractionEnabled = YES;
        _avatarView.backgroundColor = [UIColor clearColor];
        [_avatarView sd_setImageWithURL:[NSURL URLWithString:self.viewModel.portraitUri]
                       placeholderImage:[UIImage imageNamed:@"openclaw_assistant_logo"]];
        [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAvatar)]];
    }
    return _avatarView;
}

- (UILabel *)nameTitleLabel {
    if (!_nameTitleLabel) {
        _nameTitleLabel = [[UILabel alloc] init];
        _nameTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameTitleLabel.text = RCDLocalizedString(@"OpenClawBotNameTitle");
        _nameTitleLabel.font = [UIFont systemFontOfSize:15];
        _nameTitleLabel.textColor = RCDDYCOLOR(0x020814, 0xffffff);
    }
    return _nameTitleLabel;
}

- (UITextField *)nameField {
    if (!_nameField) {
        _nameField = [[UITextField alloc] init];
        _nameField.translatesAutoresizingMaskIntoConstraints = NO;
        _nameField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"OpenClawBotNamePlaceholder")
                                            attributes:@{
                                                NSForegroundColorAttributeName : RCDDYCOLOR(0x9ca3af, 0x777777),
                                                NSFontAttributeName : [UIFont systemFontOfSize:13]
                                            }];
        _nameField.textAlignment = NSTextAlignmentLeft;
        _nameField.backgroundColor = [UIColor whiteColor];
        _nameField.layer.borderWidth = 0;
        _nameField.font = [UIFont systemFontOfSize:13];
        _nameField.textColor = RCDDYCOLOR(0x020814, 0xffffff);
        _nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
        _nameField.leftViewMode = UITextFieldViewModeAlways;
        _nameField.delegate = self;
        [_nameField addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _nameField;
}

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [self blueButtonWithTitle:RCDLocalizedString(@"OpenClawCreateBotButton")];
        [_createButton addTarget:self action:@selector(createBot) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createButton;
}

- (UIButton *)blueButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = HEXCOLOR(0x0047ff);
    button.layer.cornerRadius = 6;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    return button;
}

- (void)textFieldChanged {
    if (self.nameField.text.length > 10) {
        self.nameField.text = [self.nameField.text substringToIndex:10];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *nextText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return nextText.length <= 10;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isDescendantOfView:self.nameField];
}

- (void)selectAvatar {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"OpenClawSelectFromAlbum") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"OpenClawUseDefaultAvatar") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.viewModel useDefaultPortrait];
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:self.viewModel.portraitUri]
                            placeholderImage:[UIImage imageNamed:@"openclaw_assistant_logo"]];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    self.avatarView.image = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.view showLoading];
        [self.viewModel uploadAvatarImage:image success:^(NSString *portraitUri) {
            [self.view hideLoading];
        } failure:^(NSString *message) {
            [self.view hideLoading];
            [self.view showHUDMessage:message];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)createBot {
    NSString *name = [self.viewModel normalizedName:self.nameField.text];
    if (![self.viewModel isValidName:name]) {
        [self.view showHUDMessage:RCDLocalizedString(@"OpenClawBotNameInvalid")];
        return;
    }
    [self.view endEditing:YES];
    [self.view showLoading];
    [self.viewModel createBotWithName:name success:^(RCDOpenClawBot *bot) {
        [self.view hideLoading];
        if (self.createSuccessBlock) {
            self.createSuccessBlock();
        }
        RCDOpenClawBotTokenViewController *vc = [[RCDOpenClawBotTokenViewController alloc] initWithBot:bot created:YES];
        [self.navigationController setViewControllers:[self stackForCreatedBotTokenViewController:vc] animated:YES];
    } error:^(NSError *error) {
        [self.view hideLoading];
        [self.view showHUDMessage:error.localizedDescription ?: RCDLocalizedString(@"OpenClawCreateFailed")];
    }];
}

- (NSArray<UIViewController *> *)stackForCreatedBotTokenViewController:(UIViewController *)tokenViewController {
    UIViewController *targetViewController = nil;
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        NSString *className = NSStringFromClass(viewController.class);
        if ([className isEqualToString:@"RCDChatListViewController"] ||
            [className isEqualToString:@"RCUChatListViewController"]) {
            targetViewController = viewController;
            break;
        }
    }
    if (!targetViewController) {
        targetViewController = self.navigationController.viewControllers.firstObject;
    }
    if (!targetViewController) {
        return @[ tokenViewController ];
    }
    return @[ targetViewController, tokenViewController ];
}

@end
