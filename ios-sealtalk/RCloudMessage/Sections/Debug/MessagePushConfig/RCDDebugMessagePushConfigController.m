//
//  RCDDebugMessagePushConfigController.m
//  SealTalk
//
//  Created by 孙浩 on 2020/11/27.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugMessagePushConfigController.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, RCDInterruptionLevel) {
    RCDInterruptionLevel_passive = 1,
    RCDInterruptionLevel_active = 2,
    RCDInterruptionLevel_time_sensitive = 3,
    RCDInterruptionLevel_critical = 4
};

@interface RCDDebugMessagePushConfigController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIButton *disableNotificationBtn;

@property (nonatomic, strong) UIButton *disableTitleBtn;

@property (nonatomic, strong) UIButton *forceShowDetailBtn;

@property (nonatomic, strong) UITextField *notificationIdTF;

@property (nonatomic, strong) UITextField *pushTitleTF;

@property (nonatomic, strong) UITextField *pushContentTF;

@property (nonatomic, strong) UITextField *pushDataTF;

@property (nonatomic, strong) UITextField *imageUrlTF;

@property (nonatomic, strong) UILabel *interruptionLevelInfoLbl;
@property (nonatomic, strong) UITextField *interruptionLevelTF;

@property (nonatomic, strong) UITextField *templateIdTF;

@property (nonatomic, strong) UITextField *threadIdTF;

@property (nonatomic, strong) UITextField *categoryTF;

@property (nonatomic, strong) UITextField *apnsCollapseIdTF;

@property (nonatomic, strong) UITextField *channelIdMiTF;

@property (nonatomic, strong) UITextField *channelIdHWTF;

@property (nonatomic, strong) UITextField *categoryHWTF;

@property (nonatomic, strong) UITextField *channelIdOPPOTF;

@property (nonatomic, strong) UITextField *typeVivoTF;

@property (nonatomic, strong) UITextField *categoryVivoTF;

@property (nonatomic, strong) UITextField *fcmTF;

@property (nonatomic, strong) UITextField *fcmUrlTF;

@property (nonatomic, strong) UITextField *hwLvel;

@property (nonatomic, strong) UITextField *hwImgUrlTF;

@property (nonatomic, strong) UITextField *miImgUrlTF;

@property (nonatomic, strong) UITextField *fcmChannelIdTF;

@property (nonatomic, strong) UITextField *importanceHonorTF;

@property (nonatomic, strong) UITextField *imageUrlHonorTF;

// HMOS
@property (nonatomic, strong) UITextField *imageUrlHMOSTF;

@property (nonatomic, strong) UITextField *categoryHMOSTF;


@property (nonatomic, strong) RCMessagePushConfig *pushConfig;

@property (nonatomic, strong) RCMessageConfig *config;

@end

@implementation RCDDebugMessagePushConfigController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setNavi];
    [self addObserver];
    [self getDefaultPushConfig];
    [self setDefaultData];
}

#pragma mark - Private Method
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    
    [self.contentView addSubview:self.disableNotificationBtn];
    [self.contentView addSubview:self.disableTitleBtn];
    [self.contentView addSubview:self.forceShowDetailBtn];
    [self.contentView addSubview:self.notificationIdTF];
    [self.contentView addSubview:self.pushTitleTF];
    [self.contentView addSubview:self.pushContentTF];
    [self.contentView addSubview:self.pushDataTF];
    [self.contentView addSubview:self.imageUrlTF];
    [self.contentView addSubview:self.interruptionLevelInfoLbl];
    [self.contentView addSubview:self.interruptionLevelTF];
    [self.contentView addSubview:self.templateIdTF];
    [self.contentView addSubview:self.threadIdTF];
    [self.contentView addSubview:self.categoryTF];
    [self.contentView addSubview:self.apnsCollapseIdTF];
    [self.contentView addSubview:self.channelIdMiTF];
    [self.contentView addSubview:self.channelIdHWTF];
    [self.contentView addSubview:self.categoryHWTF];
    [self.contentView addSubview:self.channelIdOPPOTF];
    [self.contentView addSubview:self.typeVivoTF];
    [self.contentView addSubview:self.categoryVivoTF];
    [self.contentView addSubview:self.fcmTF];
    [self.contentView addSubview:self.fcmUrlTF];
    [self.contentView addSubview:self.hwLvel];
    [self.contentView addSubview:self.hwImgUrlTF];
    [self.contentView addSubview:self.miImgUrlTF];
    [self.contentView addSubview:self.fcmChannelIdTF];
    [self.contentView addSubview:self.importanceHonorTF];
    [self.contentView addSubview:self.imageUrlHonorTF];

    [self.contentView addSubview:self.imageUrlHMOSTF];
    [self.contentView addSubview:self.categoryHMOSTF];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.equalTo(self.scrollView);
    }];
    
    [self.disableNotificationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.right.equalTo(self.contentView).inset(20);
        make.height.offset(30);
    }];
    
    [self.disableTitleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.disableNotificationBtn.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableNotificationBtn);
    }];
    
    [self.forceShowDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.disableTitleBtn.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.pushTitleTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forceShowDetailBtn.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.pushContentTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pushTitleTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.imageUrlTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pushContentTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.pushDataTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageUrlTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.templateIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pushDataTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.threadIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.templateIdTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.categoryTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.threadIdTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.apnsCollapseIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.interruptionLevelInfoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.apnsCollapseIdTF.mas_bottom).offset(10);
        make.left.right.equalTo(self.disableTitleBtn);
        make.height.mas_equalTo(50);
    }];
    [self.interruptionLevelTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.interruptionLevelInfoLbl.mas_bottom).offset(2);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];

    [self.notificationIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.interruptionLevelTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.channelIdMiTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.notificationIdTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.channelIdHWTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.channelIdMiTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.categoryHWTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.channelIdHWTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.channelIdOPPOTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryHWTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.typeVivoTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.channelIdOPPOTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.categoryVivoTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.typeVivoTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.fcmTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryVivoTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];

    [self.fcmUrlTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fcmTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.hwImgUrlTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fcmUrlTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.miImgUrlTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hwImgUrlTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.fcmChannelIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.miImgUrlTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.hwLvel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fcmChannelIdTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.importanceHonorTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hwLvel.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.imageUrlHonorTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.importanceHonorTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
//        make.bottom.equalTo(self.contentView);
    }];
    
    [self.imageUrlHMOSTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageUrlHonorTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
//        make.bottom.equalTo(self.contentView);
    }];
    
    [self.categoryHMOSTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageUrlHMOSTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)setNavi {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void)setDefaultData {
    if (self.pushConfig) {
        self.disableTitleBtn.selected = self.pushConfig.disablePushTitle;
        self.forceShowDetailBtn.selected = self.pushConfig.forceShowDetailContent;
        self.notificationIdTF.text = self.pushConfig.androidConfig.notificationId;
        self.pushTitleTF.text = self.pushConfig.pushTitle;
        self.pushContentTF.text = self.pushConfig.pushContent;
        self.imageUrlTF.text = self.pushConfig.iOSConfig.richMediaUri;
        self.interruptionLevelTF.text = [NSString stringWithFormat:@"%@", @([self p_interruptionLevelToInt:self.pushConfig.iOSConfig.interruptionLevel])];
        self.pushDataTF.text = self.pushConfig.pushData;
        self.templateIdTF.text = self.pushConfig.templateId;
        self.threadIdTF.text = self.pushConfig.iOSConfig.threadId;
        self.categoryTF.text = self.pushConfig.iOSConfig.category;
        self.apnsCollapseIdTF.text = self.pushConfig.iOSConfig.apnsCollapseId;
        self.channelIdMiTF.text = self.pushConfig.androidConfig.channelIdMi;
        self.channelIdHWTF.text = self.pushConfig.androidConfig.channelIdHW;
        self.categoryHWTF.text = self.pushConfig.androidConfig.categoryHW;
        self.channelIdOPPOTF.text = self.pushConfig.androidConfig.channelIdOPPO;
        self.typeVivoTF.text = self.pushConfig.androidConfig.typeVivo;
        self.categoryVivoTF.text = self.pushConfig.androidConfig.categoryVivo;
        self.fcmTF.text = self.pushConfig.androidConfig.fcmCollapseKey;
        self.fcmUrlTF.text = self.pushConfig.androidConfig.fcmImageUrl;
        self.hwLvel.text = self.pushConfig.androidConfig.importanceHW;
        self.hwImgUrlTF.text = self.pushConfig.androidConfig.hwImageUrl;
        self.miImgUrlTF.text = self.pushConfig.androidConfig.miLargeIconUrl;
        self.fcmChannelIdTF.text = self.pushConfig.androidConfig.fcmChannelId;
        self.importanceHonorTF.text = self.pushConfig.androidConfig.importanceHonor;
        self.imageUrlHonorTF.text = self.pushConfig.androidConfig.imageUrlHonor;
    }
    
    if (self.config) {
        self.disableNotificationBtn.selected = self.config.disableNotification;
    }
}

- (RCDInterruptionLevel)p_interruptionLevelToInt:(NSString *)levelStr {
    if ([kInterruptionLevel_passive isEqualToString:levelStr]) {
        return RCDInterruptionLevel_passive;
    }
    else if ([kInterruptionLevel_active isEqualToString:levelStr]) {
        return RCDInterruptionLevel_active;
    }
    else if ([kInterruptionLevel_time_sensitive isEqualToString:levelStr]) {
        return RCDInterruptionLevel_time_sensitive;
    }
    else if ([kInterruptionLevel_critical isEqualToString:levelStr]) {
        return RCDInterruptionLevel_critical;
    }
    return RCDInterruptionLevel_active;
}

- (NSString *)p_interruptionLevelToString:(RCDInterruptionLevel)level {
    NSString *retLevelString = kInterruptionLevel_active;
    switch (level) {
        case RCDInterruptionLevel_passive:
            retLevelString = kInterruptionLevel_passive;
            break;
        case RCDInterruptionLevel_active:
            retLevelString = kInterruptionLevel_active;
            break;
        case RCDInterruptionLevel_time_sensitive:
            retLevelString = kInterruptionLevel_time_sensitive;
            break;
        case RCDInterruptionLevel_critical:
            retLevelString = kInterruptionLevel_critical;
            break;
    }
    return retLevelString;
}

#pragma mark - Action
- (void)disableNotification {
    self.disableNotificationBtn.selected = !self.disableNotificationBtn.selected;
}

- (void)disableTitle {
    self.disableTitleBtn.selected = !self.disableTitleBtn.selected;
}

- (void)forceShowDetail {
    self.forceShowDetailBtn.selected = !self.forceShowDetailBtn.selected;
}

- (void)save {
    
    RCMessagePushConfig *pushConfig = [[RCMessagePushConfig alloc] init];
    pushConfig.disablePushTitle = self.disableTitleBtn.selected;
    pushConfig.pushTitle = self.pushTitleTF.text;
    pushConfig.pushContent = self.pushContentTF.text;
    pushConfig.pushData = self.pushDataTF.text;
    pushConfig.templateId = self.templateIdTF.text;
    pushConfig.iOSConfig.threadId = self.threadIdTF.text;
    pushConfig.iOSConfig.category = self.categoryTF.text;
    pushConfig.iOSConfig.apnsCollapseId = self.apnsCollapseIdTF.text;
    pushConfig.iOSConfig.richMediaUri = self.imageUrlTF.text;
    pushConfig.iOSConfig.interruptionLevel = [self p_interruptionLevelToString:[self.interruptionLevelTF.text integerValue]];
    pushConfig.androidConfig.notificationId = self.notificationIdTF.text;
    pushConfig.androidConfig.channelIdMi = self.channelIdMiTF.text;
    pushConfig.androidConfig.channelIdHW = self.channelIdHWTF.text;
    pushConfig.androidConfig.categoryHW = self.categoryHWTF.text;
    pushConfig.androidConfig.channelIdOPPO = self.channelIdOPPOTF.text;
    pushConfig.androidConfig.typeVivo = self.typeVivoTF.text;
    pushConfig.androidConfig.categoryVivo = self.categoryVivoTF.text;
    pushConfig.androidConfig.fcmCollapseKey = self.fcmTF.text;
    pushConfig.androidConfig.fcmImageUrl = self.fcmUrlTF.text;
    pushConfig.androidConfig.importanceHW = self.hwLvel.text;
    pushConfig.forceShowDetailContent = self.forceShowDetailBtn.selected;
    pushConfig.androidConfig.hwImageUrl = self.hwImgUrlTF.text;
    pushConfig.androidConfig.miLargeIconUrl= self.miImgUrlTF.text;
    pushConfig.androidConfig.fcmChannelId = self.fcmChannelIdTF.text;
    pushConfig.androidConfig.importanceHonor = self.importanceHonorTF.text;
    pushConfig.androidConfig.imageUrlHonor = self.imageUrlHonorTF.text;
    
    // HMOS
    pushConfig.hmosConfig.imageUrl = self.imageUrlHMOSTF.text;
    pushConfig.hmosConfig.category = self.categoryHMOSTF.text;
    [self saveToUserDefaults:pushConfig];
    
    RCMessageConfig *config = [[RCMessageConfig alloc] init];
    config.disableNotification = self.disableNotificationBtn.selected;
    
    [self saveConfigToUserDefaults:config];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.view endEditing:YES];
}

- (void)saveToUserDefaults:(RCMessagePushConfig *)pushConfig {
    [[NSUserDefaults standardUserDefaults] setObject:@(pushConfig.disablePushTitle) forKey:@"pushConfig-disablePushTitle"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.pushTitle forKey:@"pushConfig-title"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.pushContent forKey:@"pushConfig-content"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.pushData forKey:@"pushConfig-data"];
    [[NSUserDefaults standardUserDefaults] setObject:@(pushConfig.forceShowDetailContent) forKey:@"pushConfig-forceShowDetailContent"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.templateId forKey:@"pushConfig-templateId"];
    
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.iOSConfig.threadId forKey:@"pushConfig-threadId"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.iOSConfig.apnsCollapseId forKey:@"pushConfig-apnsCollapseId"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.iOSConfig.richMediaUri forKey:@"pushConfig-richMediaUri"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.iOSConfig.category forKey:@"pushConfig-category"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.iOSConfig.interruptionLevel forKey:@"pushConfig-interruptionLevel"];

    
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.notificationId forKey:@"pushConfig-android-id"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.channelIdMi forKey:@"pushConfig-android-mi"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.channelIdHW forKey:@"pushConfig-android-hw"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.categoryHW forKey:@"pushConfig-android-hw-category"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.channelIdOPPO forKey:@"pushConfig-android-oppo"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.typeVivo forKey:@"pushConfig-android-vivo"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.categoryVivo forKey:@"pushConfig-android-vivo-category"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.fcmCollapseKey forKey:@"pushConfig-android-fcm"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.fcmImageUrl forKey:@"pushConfig-android-fcmImageUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.importanceHW forKey:@"pushConfig-android-importanceHW"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.hwImageUrl forKey:@"pushConfig-android-hwImageUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.miLargeIconUrl forKey:@"pushConfig-android-miLargeIconUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.fcmChannelId forKey:@"pushConfig-android-fcmChannelId"];
    // honor
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.importanceHonor forKey:@"pushConfig-android-importanceHonor"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.imageUrlHonor forKey:@"pushConfig-android-imageUrlHonor"];
    
    // HMOS
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.hmosConfig.category forKey:@"pushConfig-HarmonyOS-category"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.hmosConfig.imageUrl forKey:@"pushConfig-HarmonyOS-imageUrl"];
}

- (void)saveConfigToUserDefaults:(RCMessageConfig *)config {
    [[NSUserDefaults standardUserDefaults] setObject:@(config.disableNotification) forKey:@"config-disableNotification"];
}

- (void)getDefaultPushConfig {
    self.pushConfig = [[RCMessagePushConfig alloc] init];
    self.pushConfig.disablePushTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-disablePushTitle"] boolValue];
    self.pushConfig.pushTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-title"];
    self.pushConfig.pushContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-content"];
    self.pushConfig.pushData = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-data"];
    self.pushConfig.forceShowDetailContent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-forceShowDetailContent"] boolValue];
    self.pushConfig.templateId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-templateId"];
    
    self.pushConfig.iOSConfig.threadId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-threadId"];
    self.pushConfig.iOSConfig.apnsCollapseId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-apnsCollapseId"];
    self.pushConfig.iOSConfig.richMediaUri = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-richMediaUri"];
    self.pushConfig.iOSConfig.category = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-category"];
    self.pushConfig.iOSConfig.interruptionLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-interruptionLevel"];

    self.pushConfig.androidConfig.notificationId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-id"];
    self.pushConfig.androidConfig.channelIdMi = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-mi"];
    self.pushConfig.androidConfig.channelIdHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw"];
    self.pushConfig.androidConfig.categoryHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw-category"];
    self.pushConfig.androidConfig.channelIdOPPO = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-oppo"];
    self.pushConfig.androidConfig.typeVivo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-vivo"];
    self.pushConfig.androidConfig.categoryVivo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-vivo-category"];
    self.pushConfig.androidConfig.fcmCollapseKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcm"];
    self.pushConfig.androidConfig.fcmImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcmImageUrl"];
    self.pushConfig.androidConfig.hwImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hwImageUrl"];
    self.pushConfig.androidConfig.miLargeIconUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-miLargeIconUrl"];
    self.pushConfig.androidConfig.fcmChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcmChannelId"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-importanceHW"]) {
        self.pushConfig.androidConfig.importanceHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-importanceHW"];
    }else{
        self.pushConfig.androidConfig.importanceHW = RCImportanceHwNormal;

    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-importanceHonor"]) {
        self.pushConfig.androidConfig.importanceHonor = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-importanceHonor"];
    }else{
        self.pushConfig.androidConfig.importanceHonor = RCImportanceHonorNormal;
    }
    self.pushConfig.androidConfig.imageUrlHonor = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-imageUrlHonor"];
// HMOS
    self.pushConfig.hmosConfig.imageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-HarmonyOS-imageUrl"];

    self.pushConfig.hmosConfig.category = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-HarmonyOS-category"];

    self.config = [[RCMessageConfig alloc] init];
    self.config.disableNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"config-disableNotification"] boolValue];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardBounds = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-keyboardBounds.size.height);//.offset(-350)
        }];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self.view);
        }];
    } completion:nil];
}

#pragma mark - Setter && Getter
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

- (UIButton *)disableNotificationBtn {
    if (!_disableNotificationBtn) {
        _disableNotificationBtn = [[UIButton alloc] init];
        [_disableNotificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_disableNotificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_disableNotificationBtn setTitle:@"□ 是否开启静默消息" forState:UIControlStateNormal];
        [_disableNotificationBtn setTitle:@"✅ 是否开启静默消息" forState:UIControlStateSelected];
        [_disableNotificationBtn addTarget:self action:@selector(disableNotification) forControlEvents:UIControlEventTouchUpInside];
        _disableNotificationBtn.layer.borderWidth = 1;
        _disableNotificationBtn.layer.cornerRadius = 8;
    }
    return _disableNotificationBtn;
}

- (UIButton *)disableTitleBtn {
    if (!_disableTitleBtn) {
        _disableTitleBtn = [[UIButton alloc] init];
        [_disableTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_disableTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_disableTitleBtn setTitle:@"□ 是否屏蔽推送标题" forState:UIControlStateNormal];
        [_disableTitleBtn setTitle:@"✅ 是否屏蔽推送标题" forState:UIControlStateSelected];
        [_disableTitleBtn addTarget:self action:@selector(disableTitle) forControlEvents:UIControlEventTouchUpInside];
        _disableTitleBtn.layer.borderWidth = 1;
        _disableTitleBtn.layer.cornerRadius = 8;
    }
    return _disableTitleBtn;
}

- (UIButton *)forceShowDetailBtn {
    if (!_forceShowDetailBtn) {
        _forceShowDetailBtn = [[UIButton alloc] init];
        [_forceShowDetailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_forceShowDetailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_forceShowDetailBtn setTitle:@"□ 是否强制显示通知详情" forState:UIControlStateNormal];
        [_forceShowDetailBtn setTitle:@"✅ 是否强制显示通知详情" forState:UIControlStateSelected];
        [_forceShowDetailBtn addTarget:self action:@selector(forceShowDetail) forControlEvents:UIControlEventTouchUpInside];
        _forceShowDetailBtn.layer.borderWidth = 1;
        _forceShowDetailBtn.layer.cornerRadius = 8;
    }
    return _forceShowDetailBtn;
}

- (UITextField *)pushTitleTF {
    if (!_pushTitleTF) {
        _pushTitleTF = [[UITextField alloc] init];
        _pushTitleTF.placeholder = @"推送标题";
        _pushTitleTF.layer.borderWidth = 1;
    }
    return _pushTitleTF;
}

- (UITextField *)pushContentTF {
    if (!_pushContentTF) {
        _pushContentTF = [[UITextField alloc] init];
        _pushContentTF.placeholder = @"推送详情";
        _pushContentTF.layer.borderWidth = 1;
    }
    return _pushContentTF;
}

- (UITextField *)imageUrlTF {
    if (!_imageUrlTF) {
        _imageUrlTF = [[UITextField alloc] init];
        _imageUrlTF.placeholder = @"iOS 推送图片地址";
        _imageUrlTF.layer.borderWidth = 1;
    }
    return _imageUrlTF;
}

- (UILabel *)interruptionLevelInfoLbl {
    if (!_interruptionLevelInfoLbl) {
        _interruptionLevelInfoLbl = [[UILabel alloc] init];
        _interruptionLevelInfoLbl.numberOfLines = 2;
        _interruptionLevelInfoLbl.textColor = UIColor.lightGrayColor;
        _interruptionLevelInfoLbl.text = @"1:passive,2:active(default),3:time-sensitive,4:critical";
    }
    return _interruptionLevelInfoLbl;
}

- (UITextField *)interruptionLevelTF {
    if (!_interruptionLevelTF) {
        _interruptionLevelTF = [[UITextField alloc] init];
        _interruptionLevelTF.placeholder = @"1:passive,2:active,3:time-sensitive,4:critical";
        _interruptionLevelTF.layer.borderWidth = 1;
    }
    return _interruptionLevelTF;
}

- (UITextField *)pushDataTF {
    if (!_pushDataTF) {
        _pushDataTF = [[UITextField alloc] init];
        _pushDataTF.placeholder = @"pushData";
        _pushDataTF.layer.borderWidth = 1;
    }
    return _pushDataTF;
}

- (UITextField *)templateIdTF {
    if (!_templateIdTF) {
        _templateIdTF = [[UITextField alloc] init];
        _templateIdTF.placeholder = @"模板 id";
        _templateIdTF.layer.borderWidth = 1;
    }
    return _templateIdTF;
}

- (UITextField *)threadIdTF {
    if (!_threadIdTF) {
        _threadIdTF = [[UITextField alloc] init];
        _threadIdTF.placeholder = @"iOS 分组 id";
        _threadIdTF.layer.borderWidth = 1;
    }
    return _threadIdTF;
}

- (UITextField *)categoryTF {
    if (!_categoryTF) {
        _categoryTF = [[UITextField alloc] init];
        _categoryTF.placeholder = @"iOS category";
        _categoryTF.layer.borderWidth = 1;
    }
    return _categoryTF;
}

- (UITextField *)apnsCollapseIdTF {
    if (!_apnsCollapseIdTF) {
        _apnsCollapseIdTF = [[UITextField alloc] init];
        _apnsCollapseIdTF.placeholder = @"iOS 覆盖 id";
        _apnsCollapseIdTF.layer.borderWidth = 1;
    }
    return _apnsCollapseIdTF;
}

- (UITextField *)notificationIdTF {
    if (!_notificationIdTF) {
        _notificationIdTF = [[UITextField alloc] init];
        _notificationIdTF.placeholder = @"推送 Id";
        _notificationIdTF.layer.borderWidth = 1;
    }
    return _notificationIdTF;
}

- (UITextField *)channelIdMiTF {
    if (!_channelIdMiTF) {
        _channelIdMiTF = [[UITextField alloc] init];
        _channelIdMiTF.placeholder = @"小米 channelId";
        _channelIdMiTF.layer.borderWidth = 1;
    }
    return _channelIdMiTF;
}

- (UITextField *)channelIdHWTF {
    if (!_channelIdHWTF) {
        _channelIdHWTF = [[UITextField alloc] init];
        _channelIdHWTF.placeholder = @"华为 channelId";
        _channelIdHWTF.layer.borderWidth = 1;
    }
    return _channelIdHWTF;
}

- (UITextField *)categoryHWTF {
    if (!_categoryHWTF) {
        _categoryHWTF = [[UITextField alloc] init];
        _categoryHWTF.placeholder = @"华为 categoryHW";
        _categoryHWTF.layer.borderWidth = 1;
    }
    return _categoryHWTF;
}

- (UITextField *)channelIdOPPOTF {
    if (!_channelIdOPPOTF) {
        _channelIdOPPOTF = [[UITextField alloc] init];
        _channelIdOPPOTF.placeholder = @"OPPO channelId";
        _channelIdOPPOTF.layer.borderWidth = 1;
    }
    return _channelIdOPPOTF;
}

- (UITextField *)typeVivoTF {
    if (!_typeVivoTF) {
        _typeVivoTF = [[UITextField alloc] init];
        _typeVivoTF.placeholder = @"vivo type，只能为 0 或者 1";
        _typeVivoTF.layer.borderWidth = 1;
    }
    return _typeVivoTF;
}

- (UITextField *)categoryVivoTF {
    if (!_categoryVivoTF) {
        _categoryVivoTF = [[UITextField alloc] init];
        _categoryVivoTF.placeholder = @"vivo category";
        _categoryVivoTF.layer.borderWidth = 1;
    }
    return _categoryVivoTF;
}

- (UITextField *)fcmTF {
    if (!_fcmTF) {
        _fcmTF = [[UITextField alloc] init];
        _fcmTF.placeholder = @"FCM 分组 ID";
        _fcmTF.layer.borderWidth = 1;
    }
    return _fcmTF;
}

- (UITextField *)fcmUrlTF {
    if (!_fcmUrlTF) {
        _fcmUrlTF = [[UITextField alloc] init];
        _fcmUrlTF.placeholder = @"FCM 图片 Url";
        _fcmUrlTF.layer.borderWidth = 1;
    }
    return _fcmUrlTF;
}


- (UITextField *)hwLvel {
    if (!_hwLvel) {
        _hwLvel = [[UITextField alloc] init];
        _hwLvel.placeholder = @"hw推送级别";
        _hwLvel.layer.borderWidth = 1;
    }
    return _hwLvel;
}

- (UITextField *)hwImgUrlTF {
    if (!_hwImgUrlTF) {
        _hwImgUrlTF = [[UITextField alloc] init];
        _hwImgUrlTF.placeholder = @"hw 图片地址";
        _hwImgUrlTF.layer.borderWidth = 1;
    }
    return _hwImgUrlTF;
}

- (UITextField *)miImgUrlTF {
    if (!_miImgUrlTF) {
        _miImgUrlTF = [[UITextField alloc] init];
        _miImgUrlTF.placeholder = @"mi 图片地址";
        _miImgUrlTF.layer.borderWidth = 1;
    }
    return _miImgUrlTF;
}

- (UITextField *)fcmChannelIdTF {
    if (!_fcmChannelIdTF) {
        _fcmChannelIdTF = [[UITextField alloc] init];
        _fcmChannelIdTF.placeholder = @"FCM channelId";
        _fcmChannelIdTF.layer.borderWidth = 1;
    }
    return _fcmChannelIdTF;
}

- (UITextField *)importanceHonorTF {
    if (!_importanceHonorTF) {
        _importanceHonorTF = [[UITextField alloc] init];
        _importanceHonorTF.placeholder = @"Honor 推送级别";
        _importanceHonorTF.layer.borderWidth = 1;
    }
    return _importanceHonorTF;
}

- (UITextField *)imageUrlHonorTF {
    if (!_imageUrlHonorTF) {
        _imageUrlHonorTF = [[UITextField alloc] init];
        _imageUrlHonorTF.placeholder = @"Honor 图片地址";
        _imageUrlHonorTF.layer.borderWidth = 1;
    }
    return _imageUrlHonorTF;
}

- (UITextField *)imageUrlHMOSTF {
    if (!_imageUrlHMOSTF) {
        _imageUrlHMOSTF = [[UITextField alloc] init];
        _imageUrlHMOSTF.placeholder = @"HarmonyOS 图片地址";
        _imageUrlHMOSTF.layer.borderWidth = 1;
    }
    return _imageUrlHMOSTF;
}

- (UITextField *)categoryHMOSTF {
    if (!_categoryHMOSTF) {
        _categoryHMOSTF = [[UITextField alloc] init];
        _categoryHMOSTF.placeholder = @"HarmonyOS 类别";
        _categoryHMOSTF.layer.borderWidth = 1;
    }
    return _categoryHMOSTF;
}

@end
