//
//  RCDCreateGroupViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCreateGroupViewController.h"
#import "UIView+MBProgressHUD.h"
#import "RCDChatViewController.h"
#import "UIColor+RCColor.h"
#import "UIImage+RCImage.h"
#import <Masonry/Masonry.h>
#import "RCDGroupManager.h"
#import "RCDUploadManager.h"
#import "RCDForwardManager.h"
#import "NormalAlertView.h"
#import "RCDUltraGroupManager.h"
@interface RCDCreateGroupViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate,
                                            UINavigationControllerDelegate>
@property (nonatomic, strong) UIView *headBgView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UIButton *editPortraitImageButton;
@property (nonatomic, strong) UITextField *groupName;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, assign) BOOL privateChannel;
@end

@implementation RCDCreateGroupViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self addSubViews];
    [self registerNotification];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGRect captureRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        UIImage *captureImage =
            [UIImage getSubImage:originImage Rect:captureRect imageOrientation:originImage.imageOrientation];
        UIImage *scaleImage = [UIImage scaleImage:captureImage toScale:0.8];
        self.imageData = UIImageJPEGRepresentation(scaleImage, 0.00001);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    self.portraitImageView.image = [UIImage imageWithData:self.imageData];
}

#pragma mark - Notification action
- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve =
        [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         CGRect originalFrame = [UIScreen mainScreen].bounds;
                         if ([self.groupName isFirstResponder] &&
                             CGRectGetMaxY(self.groupName.frame) + [self getNaviAndStatusHeight] >
                                 keyboardBounds.origin.y) {
                             originalFrame.origin.y =
                                 originalFrame.origin.y - (CGRectGetMaxY(self.groupName.frame) +
                                                           [self getNaviAndStatusHeight] - keyboardBounds.origin.y);
                             self.view.frame = originalFrame;
                         }
                         [UIView commitAnimations];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.5
                     animations:^{
                         [UIView setAnimationCurve:0];
                         CGRect originalFrame = self.view.frame;
                         originalFrame.origin.y = [self getNaviAndStatusHeight];
                         self.view.frame = originalFrame;
                         [UIView commitAnimations];
                     }];
}

#pragma mark - target action
- (void)clickDoneBtn {
    [self.groupName resignFirstResponder];
    NSString *nameStr = [self.groupName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self groupNameIsAvailable:nameStr]) {
        if (![self.groupMemberIdList containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
            [self.groupMemberIdList addObject:[RCIM sharedRCIM].currentUserInfo.userId];
        }
        [self createGroup];
    }
}

- (void)hideKeyboard:(id)sender {
    [self.groupName resignFirstResponder];
}

#pragma mark - helper
- (void)addSubViews {
    //给整个view添加手势，隐藏键盘
    UITapGestureRecognizer *resetBottomTapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:resetBottomTapGesture];
    self.infoLabel.accessibilityLabel = @"infoLabel";
    [self.view addSubview:self.infoLabel];
    [self.view addSubview:self.groupName];
    [self.view addSubview:self.createButton];
    [self.view addSubview:self.headBgView];
    if (self.groupType != RCDCreateTypeUltraGroupChannel) {
        [self.headBgView addSubview:self.portraitImageView];
        [self.headBgView addSubview:self.editPortraitImageButton];
        [self.headBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(self.view);
            make.height.offset(102);
        }];
        [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.headBgView);
            make.top.equalTo(self.headBgView).offset(6);
            make.width.height.offset(70);
        }];
        
        [self.editPortraitImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.trailing.equalTo(self.portraitImageView);
            make.width.height.offset(20);
        }];
    }else{
        [self.headBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(self.view);
            make.height.offset(10);
        }];
    }
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.headBgView.mas_bottom).offset(16);
        make.height.offset(44);
    }];

    [self.groupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.infoLabel);
        make.top.bottom.equalTo(self.infoLabel);
        make.leading.equalTo(self.infoLabel.mas_leading).offset(80);
        make.height.equalTo(self.infoLabel);
    }];
    if (self.groupType == RCDCreateTypeUltraGroupChannel) {
        UILabel *titleLab = [UILabel new];
        titleLab.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x111f2c) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]];
        titleLab.font = [UIFont systemFontOfSize:17];
        titleLab.backgroundColor = RCDDYCOLOR(0xffffff, 0x191919);
        titleLab.text = RCDLocalizedString(@"channel_private");
        [self.view addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.height.mas_equalTo(self.infoLabel);
            make.top.mas_equalTo(self.infoLabel.mas_bottom).mas_offset(20);
        }];
        
        UISwitch *switchBtn = [UISwitch new];
        [self.view addSubview:switchBtn];
        [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(titleLab);
            make.trailing.mas_equalTo(self.view).mas_offset(-20);
        }];
        [switchBtn addTarget:self
                      action:@selector(switchBtnClick:)
            forControlEvents:UIControlEventValueChanged];
    }
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(25);
        make.right.equalTo(self.view).offset(-25);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-12);
        } else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-12);
        }
        make.height.offset(40);
    }];
}

- (void)switchBtnClick:(UISwitch *)sender {
    self.privateChannel = sender.isOn;
}
- (CGFloat)getNaviAndStatusHeight {
    CGFloat navHeight = 44.0f;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    return navHeight + statusBarHeight;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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

- (void)gotoChatView:(NSString *)groupId groupName:(NSString *)groupName {
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.needPopToRootView = YES;
    chatVC.targetId = groupId;
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.title = groupName;
    chatVC.enableNewComingMessageIcon = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatVC animated:YES];
    });
}

- (void)sendForwardMessage:(NSString *)groupId {
    RCDForwardManager *manager = [RCDForwardManager sharedInstance];
    for (RCMessageModel *message in manager.selectedMessages) {
        [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP
            targetId:groupId
            content:message.content
            pushContent:nil
            pushData:nil
            success:^(long messageId) {
            }
            error:^(RCErrorCode nErrorCode, long messageId){
            }];
        [NSThread sleepForTimeInterval:0.3];
    }
    [manager forwardEnd];
}

- (void)showAlert:(NSString *)alertContent {
    [NormalAlertView showAlertWithTitle:nil
                                message:alertContent
                          describeTitle:nil
                           confirmTitle:RCDLocalizedString(@"confirm")
                                confirm:^{
                                }];
}

- (void)choosePortrait {
    [self.groupName resignFirstResponder];
    [RCActionSheetView showActionSheetView:nil cellArray:@[RCDLocalizedString(@"take_picture"), RCDLocalizedString(@"my_album")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
        if (index == 0) {
            [self pushToImagePickerController:UIImagePickerControllerSourceTypeCamera];
        }else{
            [self pushToImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    } cancelBlock:^{
        
    }];
}

- (BOOL)groupNameIsAvailable:(NSString *)nameStr {
    if ([nameStr length] == 0) {
        //群组名称不存在
        [self showAlert:RCDLocalizedString(@"group_name_can_not_nil")];
        return NO;
    } else if ([nameStr length] < 2) {
        //群组名称需要大于2个字
        [self showAlert:RCDLocalizedString(@"Group_name_is_too_short")];
        return NO;
    } else if ([nameStr length] > 10) {
        //群组名称需要小于10个字
        [self showAlert:RCDLocalizedString(@"Group_name_cannot_exceed_10_words")];
        return NO;
    }
    return YES;
}

- (void)createGroup {
    [self enableCreateButton:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    if ([RCDForwardManager sharedInstance].isForward) {
        hud.labelText = RCDLocalizedString(@"PrepareGroup");
    } else {
        hud.labelText = RCDLocalizedString(@"creating_group");
    }
    [hud show:YES];
    if (self.imageData) {
        [RCDUploadManager uploadImage:self.imageData
                             complete:^(NSString *url) {
                                 [self createGroupWithPortraitUri:url];
                             }];
    } else {
        [self createGroupWithPortraitUri:nil];
    }
}

- (void)createGroupWithPortraitUri:(NSString *)portraitUri {
    NSString *nameStr = [self.groupName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self containsSpecialWords:nameStr]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    switch (self.groupType) {
        case RCDCreateTypeNormalGroup:{
            [self createNormalGroup:nameStr portraitUri:portraitUri];
        }break;
        case RCDCreateTypeUltraGroup:{
            [self createUltraGroup:nameStr portraitUri:portraitUri];
        }break;
        case RCDCreateTypeUltraGroupChannel:{
            [self createUltraGroupChannel:nameStr];
        }break;
        default:
            break;
    }
}

- (void)createUltraGroupChannel:(NSString *)nameStr{
    __weak typeof(self) weakSelf = self;
    [RCDUltraGroupManager createUltraGroupChannel:self.groupId
                                      channelName:nameStr
                                         isPrivate:self.privateChannel
                                         complete:^(NSString *channelId, RCDUltraGroupCode code) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (channelId) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [weakSelf enableCreateButton:YES];
            if (code == RCDUltraGroupCodeChannelsOverLimit) {
                [weakSelf showAlert:@"创建频道超出最大限制"];
            }else{
                [weakSelf showAlert:RCDLocalizedString(@"create_group_fail")];
            }
        }
    }];
}

- (void)createUltraGroup:(NSString *)nameStr portraitUri:(NSString *)portraitUri{
    __weak typeof(self) weakSelf = self;
    [RCDUltraGroupManager createUltraGroup:nameStr portraitUri:portraitUri summary:@"" complete:^(NSString *groupId, RCDUltraGroupCode code) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (groupId) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [weakSelf enableCreateButton:YES];
            if (code == RCDUltraGroupCodeGroupsOverLimit) {
                [weakSelf showAlert:RCDLocalizedString(@"用户创建和加入的超级群组个数超限")];
            }else{
                [weakSelf showAlert:RCDLocalizedString(@"create_group_fail")];
            }
        }
    }];
}

- (void)createNormalGroup:(NSString *)nameStr portraitUri:(NSString *)portraitUri{
    [RCDGroupManager
     createGroup:nameStr
     portraitUri:portraitUri
     memberIds:self.groupMemberIdList
     complete:^(NSString *groupId, RCDGroupAddMemberStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (groupId) {
                if (status == RCDGroupAddMemberStatusInviteeApproving) {
                    [self.view showHUDMessage:RCDLocalizedString(@"MemberInviteNeedConfirm")];
                }
                
                if ([RCDForwardManager sharedInstance].isForward) {
                    if ([RCDForwardManager sharedInstance].selectConversationCompleted) {
                        RCConversation *conversation = [[RCConversation alloc] init];
                        conversation.targetId = groupId;
                        conversation.conversationType = ConversationType_GROUP;
                        [RCDForwardManager sharedInstance].selectConversationCompleted([@[ conversation ] copy]);
                        [[RCDForwardManager sharedInstance] forwardEnd];
                    } else {
                        [self sendForwardMessage:groupId];
                    }
                } else {
                    [self gotoChatView:groupId groupName:nameStr];
                }
                //关闭HUD
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self enableCreateButton:YES];
                    //关闭HUD
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showAlert:RCDLocalizedString(@"create_group_fail")];
                });
            }
        });
    }];
}

- (void)enableCreateButton:(BOOL)enable{
    self.createButton.enabled = enable;
    if (enable) {
        self.createButton.alpha = 1;
    }else{
        self.createButton.alpha = 0.5;
    }
}

- (BOOL)containsSpecialWords:(NSString *)str{
    NSString * string = @"~,￥,#,&,*,<,>,《,》,(,),[,],{,},【,】,^,@,/,￡,¤,,|,§,¨,「,」,『,』,￠,￢,￣,（,）,——,+,|,$,_,€,¥,“,”,;";
    NSArray *specialStringArray = [string componentsSeparatedByString:@","];
    for (NSInteger i = 0; i < specialStringArray.count; i ++) {
        //判断字符串中是否含有特殊符号
        if ([str rangeOfString:specialStringArray[i]].location != NSNotFound) {
            [self showAlert:RCDLocalizedString(@"请不要输入特殊符号")];
            [self enableCreateButton:YES];
            return YES;
        }
    }
    return NO;
}



#pragma mark - geter & setter
- (UIView *)headBgView {
    if (!_headBgView) {
        _headBgView = [[UIView alloc] init];
        _headBgView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                           darkColor:HEXCOLOR(0x191919)];
    }
    return _headBgView;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.backgroundColor = HEXCOLOR(0x3f95fb);
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = 35.f;
        } else {
            _portraitImageView.layer.cornerRadius = 4.f;
        }

    }
    return _portraitImageView;
}

- (UITextField *)groupName {
    if (!_groupName) {
        _groupName = [[UITextField alloc] init];
        _groupName.font = [UIFont systemFontOfSize:17];
        switch (self.groupType) {
            case RCDCreateTypeNormalGroup:{
                _groupName.placeholder = RCDLocalizedString(@"type_group_name_hint");
            }break;
            case RCDCreateTypeUltraGroup:{
                _groupName.placeholder = RCDLocalizedString(@"type_group_name_hint");
            }break;
            case RCDCreateTypeUltraGroupChannel:{
                _groupName.placeholder = RCDLocalizedString(@"填写频道名称（2-10个字符)");
            }break;
            default:
                break;
        }
        _groupName.delegate = self;
        _groupName.returnKeyType = UIReturnKeyDone;
        _groupName.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _groupName.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x000000) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]];
        NSAttributedString *attrString = [[NSAttributedString alloc]
                                          initWithString:_groupName.placeholder
                                          attributes:@{
                                              NSForegroundColorAttributeName : RCDDYCOLOR(0x999999, 0x585858),
                                              NSFontAttributeName : _groupName.font
                                          }];
        _groupName.attributedPlaceholder = attrString;
    }
    return _groupName;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x111f2c) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]];
        _infoLabel.font = [UIFont systemFontOfSize:17];
        _infoLabel.backgroundColor = RCDDYCOLOR(0xffffff, 0x191919);
        _infoLabel.text = [NSString stringWithFormat:@"  %@",RCDLocalizedString(@"Group_Name")];
        switch (self.groupType) {
            case RCDCreateTypeNormalGroup:{
                _infoLabel.text = [NSString stringWithFormat:@"  %@",RCDLocalizedString(@"Group_Name")];
            }break;
            case RCDCreateTypeUltraGroup:{
                _infoLabel.text = [NSString stringWithFormat:@"  %@",RCDLocalizedString(@"UltraGroup")];
            }break;
            case RCDCreateTypeUltraGroupChannel:{
                _infoLabel.text = [NSString stringWithFormat:@"  %@",RCDLocalizedString(@"channel")];
            }break;
            default:
                break;
        }
        _infoLabel.userInteractionEnabled = YES;
    }
    return _infoLabel;
}

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [[UIButton alloc] init];
        _createButton.clipsToBounds = YES;
        _createButton.layer.cornerRadius = 8;
        _createButton.backgroundColor = HEXCOLOR(0x0099ff);
        [_createButton setTitleColor:HEXCOLOR(0xffffff) forState:(UIControlStateNormal)];
        _createButton.titleLabel.font = [UIFont systemFontOfSize:17];
        switch (self.groupType) {
            case RCDCreateTypeNormalGroup:{
                [_createButton setTitle:RCDLocalizedString(@"CreateGroup") forState:(UIControlStateNormal)];
            }break;
            case RCDCreateTypeUltraGroup:{
                [_createButton setTitle:RCDLocalizedString(@"UltraGroup") forState:(UIControlStateNormal)];
            }break;
            case RCDCreateTypeUltraGroupChannel:{
                [_createButton setTitle:RCDLocalizedString(@"channel") forState:(UIControlStateNormal)];
            }break;
            default:
                break;
        }
        [_createButton addTarget:self
                        action:@selector(clickDoneBtn)
              forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _createButton;
}

- (UIButton *)editPortraitImageButton{
    if (!_editPortraitImageButton) {
        _editPortraitImageButton = [[UIButton alloc] init];
        [_editPortraitImageButton setImage:[UIImage imageNamed:@"edit_header_icon"] forState:(UIControlStateNormal)];
        [_editPortraitImageButton addTarget:self action:@selector(choosePortrait) forControlEvents:(UIControlEventTouchUpInside)];
        
    }
    return _editPortraitImageButton;
}
@end
