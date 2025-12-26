//
//  RCDCustomerServiceViewController.m
//  RCloudMessage
//
//  Created by litao on 16/2/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerServiceViewController.h"
#import "RCDCSAnnounceView.h"
#import "RCDCSEvaluateView.h"
#import "RCDCSEvaluateModel.h"
#import "RCDCommonDefine.h"
#import "RCDUIBarButtonItem.h"
#import <RongCustomerService/RongCustomerService.h>
#import "RCDCommonString.h"
#import "RCDCustomerEmoticonTab.h"
@interface RCDCustomerServiceViewController () <RCDCSAnnounceViewDelegate, RCDCSEvaluateViewDelegate>
//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始1＊＊＊＊＊＊＊＊＊＊＊＊＊
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic) RCCustomerServiceStatus serviceStatus;
@property (nonatomic) BOOL quitAfterComment;
//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束1＊＊＊＊＊＊＊＊＊＊＊＊＊

@property (nonatomic, copy) NSString *announceClickUrl;

@property (nonatomic, strong) RCDCSEvaluateView *evaluateView;
// key为星级；value为RCDCSEvaluateModel对象
@property (nonatomic, strong) NSMutableDictionary *evaStarDic;
@property (nonatomic, strong) RCDCSAnnounceView *announceView;
@property (nonatomic, strong) UIImageView *imageViewBG;
@end

@implementation RCDCustomerServiceViewController
- (void)viewDidLoad {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugDisableSystemEmoji] boolValue];
    self.disableSystemEmoji = enable;
    [super viewDidLoad];
    [self.view insertSubview:self.imageViewBG atIndex:0];
    CGRect frame = self.view.bounds;
    frame.origin = self.conversationMessageCollectionView.frame.origin;
    self.imageViewBG.frame = frame;
    // Do any additional setup after loading the view.
    [self hideEmojiButtonIfNeed];
    [self addEmoticonTabDemo];
    self.evaStarDic = [NSMutableDictionary dictionary];
    __weak typeof(self) weakSelf = self;
    [[RCCustomerServiceClient sharedCustomerServiceClient] getHumanEvaluateCustomerServiceConfig:^(NSDictionary *evaConfig) {
        NSArray *array = [evaConfig valueForKey:@"evaConfig"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (array) {
                for (NSDictionary *dic in array) {
                    RCDCSEvaluateModel *model = [RCDCSEvaluateModel modelWithDictionary:dic];
                    [weakSelf.evaStarDic setObject:model forKey:[NSString stringWithFormat:@"%d", model.score]];
                }
            }
        });
    }];
    [self setupChatBackground];
}

- (void)setupChatBackground {
    NSString *imageName = [DEFAULTS objectForKey:RCDChatBackgroundKey];
    UIImage *image = [UIImage imageNamed:imageName];
    if ([imageName isEqualToString:RCDChatBackgroundFromAlbum]) {
        NSData *imageData = [DEFAULTS objectForKey:RCDChatBackgroundImageDataKey];
        image = [UIImage imageWithData:imageData];
    }
    if (image) {
        self.conversationMessageCollectionView.backgroundColor = [UIColor clearColor];
        image = [RCKitUtility fixOrientation:image];
//        self.view.layer.contents = (id)image.CGImage;
    }
    self.imageViewBG.image = image;

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createNavLeftBarButtonItem];
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideEmojiButtonIfNeed {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugDisableEmojiBtn] boolValue];
    if (enable) {
        self.chatSessionInputBarControl.inputContainerView.hideEmojiButton = enable;
    }
}

- (void)addEmoticonTabDemo {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugEnableCustomEmoji] boolValue];
    if (!enable) {
        return;
    }
      //表情面板添加自定义表情包
      UIImage *icon = [RCKitUtility imageNamed:@"emoji_btn_normal"
                                      ofBundle:@"RongCloud.bundle"];
      RCDCustomerEmoticonTab *emoticonTab1 = [[RCDCustomerEmoticonTab alloc] initWith:self.chatSessionInputBarControl.emojiBoardView];
      emoticonTab1.identify = @"1";
      emoticonTab1.image = icon;
      emoticonTab1.pageCount = 2;
      [self.chatSessionInputBarControl.emojiBoardView addEmojiTab:emoticonTab1];
    
    RCDCustomerEmoticonTab *emoticonTab2 = [[RCDCustomerEmoticonTab alloc] initWith:self.chatSessionInputBarControl.emojiBoardView];
      emoticonTab2.identify = @"2";
      emoticonTab2.image = icon;
      emoticonTab2.pageCount = 4;
      [self.chatSessionInputBarControl.emojiBoardView addEmojiTab:emoticonTab2];
}
//客服VC左按键注册的selector是customerServiceLeftCurrentViewController，
//这个函数是基类的函数，他会根据当前服务时间来决定是否弹出评价，根据服务的类型来决定弹出评价类型。
//弹出评价的函数是commentCustomerServiceAndQuit，应用可以根据这个函数内的注释来自定义评价界面。
//等待用户评价结束后调用如下函数离开当前VC。
- (void)clickLeftBarButtonItem:(id)sender {
    [super customerServiceLeftCurrentViewController];
}

//评价客服，并离开当前会话
//如果您需要自定义客服评价界面，请把本函数注释掉，并打开“应用自定义评价界面开始1/2”到“应用自定义评价界面结束”部分的代码，然后根据您的需求进行修改。
//如果您需要去掉客服评价界面，请把本函数注释掉，并打开下面“应用去掉评价界面开始”到“应用去掉评价界面结束”部分的代码，然后根据您的需求进行修改。
//- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//                               commentId:(NSString *)commentId
//                        quitAfterComment:(BOOL)isQuit {
//  [super commentCustomerServiceWithStatus:serviceStatus
//                                commentId:commentId
//                         quitAfterComment:isQuit];
//}

//＊＊＊＊＊＊＊＊＊应用去掉评价界面开始＊＊＊＊＊＊＊＊＊＊＊＊＊
//-
//(void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
// commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit {
//    if (isQuit) {
//        [super customerServiceLeftCurrentViewController];;
//    }
//}
//＊＊＊＊＊＊＊＊＊应用去掉评价界面结束＊＊＊＊＊＊＊＊＊＊＊＊＊

//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始2＊＊＊＊＊＊＊＊＊＊＊＊＊
- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
                               commentId:(NSString *)commentId
                        quitAfterComment:(BOOL)isQuit {
    if (self.evaStarDic.count == 0) {
        [super commentCustomerServiceWithStatus:serviceStatus commentId:commentId quitAfterComment:isQuit];
        return;
    }
    self.serviceStatus = serviceStatus;
    self.commentId = commentId;
    self.quitAfterComment = isQuit;
    if (serviceStatus == 0) {
        [super customerServiceLeftCurrentViewController];
    } else if (serviceStatus == 1) {
        //人工评价结果
        [self.evaluateView show];
    } else if (serviceStatus == 2) {
        //机器人评价结果
        [RCAlertView showAlertController:RCDLocalizedString(@"remark_rebot_service") message:RCDLocalizedString(@"satisfaction") actionTitles:nil cancelTitle:RCDLocalizedString(@"no") confirmTitle:RCDLocalizedString(@"yes") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:^{
            [self evaluateCustomerService:NO];
        } confirmBlock:^{
            [self evaluateCustomerService:YES];
        } inViewController:self];
    }
}

- (void)evaluateCustomerService:(BOOL)isRobotResolved {
    //(1)调用evaluateCustomerService将评价结果传给融云sdk。
    [[RCCustomerServiceClient sharedCustomerServiceClient] evaluateCustomerService:self.targetId
                                              knownledgeId:self.commentId
                                                robotValue:isRobotResolved
                                                   suggest:nil];
    //(2)离开当前客服VC
    if (self.quitAfterComment) {
        [super customerServiceLeftCurrentViewController];
    }
}

//＊＊＊＊＊＊＊＊＊应用自定义客服通告＊＊＊＊＊＊＊＊＊＊＊＊＊

- (void)announceViewWillShow:(NSString *)announceMsg announceClickUrl:(NSString *)announceClickUrl {
    self.announceClickUrl = announceClickUrl;
    self.announceView.hidden = NO;
    self.announceView.content.text = announceMsg;
    if (announceClickUrl.length == 0) {
        self.announceView.hiddenArrowIcon = YES;
    }
}

#pragma mark-- RCDCSAnnounceViewDelegate
- (void)didTapViewAction {
    if (self.announceClickUrl.length > 0) {
        [RCKitUtility openURLInSafariViewOrWebView:self.announceClickUrl base:self];
    }
}
//＊＊＊＊＊＊＊＊＊应用自定义客服通告＊＊＊＊＊＊＊＊＊＊＊＊＊

#pragma mark-- RCDCSEvaluateViewDelegate

- (void)didSubmitEvaluate:(RCCSResolveStatus)solveStatus
                     star:(int)star
                tagString:(NSString *)tagString
                  suggest:(NSString *)suggest {
    [[RCCustomerServiceClient sharedCustomerServiceClient] evaluateCustomerService:self.targetId
                                                  dialogId:nil
                                                 starValue:star
                                                   suggest:suggest
                                             resolveStatus:solveStatus
                                                   tagText:tagString
                                                     extra:nil];
    if (self.quitAfterComment) {
        [super customerServiceLeftCurrentViewController];
    }
}

- (void)dismissEvaluateView {
    [self.evaluateView hide];
    if (self.quitAfterComment) {
        [super customerServiceLeftCurrentViewController];
    }
}

- (RCDCSEvaluateView *)evaluateView {
    if (!_evaluateView) {
        _evaluateView = [[RCDCSEvaluateView alloc] initWithEvaStarDic:self.evaStarDic];
        _evaluateView.delegate = self;
    }
    return _evaluateView;
}

- (RCDCSAnnounceView *)announceView {
    if (!_announceView) {
        CGRect rect = self.conversationMessageCollectionView.frame;
        rect.origin.y += 44;
        rect.size.height -= 44;
        self.conversationMessageCollectionView.frame = rect;
        _announceView =
            [[RCDCSAnnounceView alloc] initWithFrame:CGRectMake(0, rect.origin.y - 44, self.view.frame.size.width, 44)];
        _announceView.delegate = self;
//        _announceView.hidden = YES;
        [self.view addSubview:_announceView];
    }
    return _announceView;
}

#pragma mark Navigation Setting
- (void)createNavLeftBarButtonItem {
    self.navigationItem.leftBarButtonItems = [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickLeftBarButtonItem:)];
}



- (UIImageView *)imageViewBG {
    if (!_imageViewBG) {
        _imageViewBG = [UIImageView new];
    }
    return _imageViewBG;
}
@end
