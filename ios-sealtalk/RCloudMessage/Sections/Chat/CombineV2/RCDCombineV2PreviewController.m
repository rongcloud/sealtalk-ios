//
//  RCDCombineV2PreviewController.m
//  SealTalk
//
//  Created by zgh on 2024/1/5.
//  Copyright © 2024 RongCloud. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <RongContactCard/RongContactCard.h>
#import <RongSticker/RongSticker.h>
#import <RongLocation/RongLocation.h>

#import "RCDCombineV2PreviewController.h"
#import "RCDCombineV2Utility.h"
#import "RCDUserInfo.h"
#import "RCDPersonDetailViewController.h"
#import "RCDUIBarButtonItem.h"
#import "RCDChatTitleAlertView.h"

#define RCViewSpace 8

@interface RCCombineMsgFilePreviewViewController : RCBaseViewController

- (instancetype)initWithRemoteURL:(NSString *)remoteURL
                 conversationType:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                         fileSize:(long long)fileSize
                         fileName:(NSString *)fileName
                         fileType:(NSString *)fileType;

@end

@interface RCDCombineV2PreviewController ()

@property (nonatomic, strong) NSMutableArray *messageList;

@property (nonatomic, strong) RCMessageModel *messageModel;

@property (nonatomic, strong) UIStackView *tipVStackView;

@property (nonatomic, strong) UIImageView *tipIcon;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) RCMessageModel *longPressModel;

@end

@implementation RCDCombineV2PreviewController

- (instancetype)initWithMessage:(RCMessageModel *)messageModel {
    self = [super init];
    if (self) {
        self.messageModel = messageModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ((UICollectionViewFlowLayout *)self.conversationMessageCollectionView.collectionViewLayout).sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.title = [RCDCombineV2Utility getCombineMessageTitle:(RCCombineV2Message *)self.messageModel.content];
    self.navigationItem.rightBarButtonItems = nil;
    
    [self.chatSessionInputBarControl removeFromSuperview];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:RCDChatTitleAlertView.class]) {
            [view removeFromSuperview];
        }
    }

    self.navigationItem.leftBarButtonItems = [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    
    [self rc_loadMessage];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat topHeight = [self statusBarHeight] +
                                      CGRectGetMaxY(self.navigationController.navigationBar.bounds);
    CGRect collectionFrame = self.view.bounds;
    collectionFrame.origin.y = topHeight;
    collectionFrame.size.height -= topHeight;
    self.conversationMessageCollectionView.frame = collectionFrame;
}

- (void)didTapMessageCell:(RCMessageModel *)model {
    if ([model.content isKindOfClass:[RCContactCardMessage class]]) {
        RCContactCardMessage *cardMSg = (RCContactCardMessage *)model.content;
        RCDUserInfo *user =
        [[RCDUserInfo alloc] initWithUserId:cardMSg.userId name:cardMSg.name portrait:cardMSg.portraitUri];
        [self pushPersonDetailVC:user];
        return;
    } else if ([model.content isKindOfClass:[RCCombineV2Message class]]) {
        RCDCombineV2PreviewController *combineV2PreviewVC = [[RCDCombineV2PreviewController alloc] initWithMessage:model];
        [self.navigationController pushViewController:combineV2PreviewVC animated:YES];
        return;
    } else if ([model.content isKindOfClass:[RCFileMessage class]]) {
        RCFileMessage *fileContent = (RCFileMessage *)model.content;
        RCCombineMsgFilePreviewViewController *fileViewController =
            [[RCCombineMsgFilePreviewViewController alloc] initWithRemoteURL:fileContent.remoteUrl conversationType:model.conversationType targetId:model.targetId fileSize:fileContent.size fileName:fileContent.name fileType:fileContent.type];
        [self.navigationController pushViewController:fileViewController animated:YES];
        return;
    }
    [super didTapMessageCell:model];
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    if ([model.content isMemberOfClass:[RCTextMessage class]] ||
        [model.content isMemberOfClass:[RCReferenceMessage class]]) {
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:RCLocalizedString(@"Copy")
                                                          action:@selector(onCopyMessage:)];
        return @[copyItem];
    }
    return nil;
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    self.longPressModel = model;
    [super didLongTouchMessageCell:model inView:view];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark - super method override

// 当有未读消息时，父控制器 RCDChatViewController 会修改导航栏，因本页面不显示未读数所以重写掉
- (void)setLeftNavigationItem {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat width = self.conversationMessageCollectionView.frame.size.width;
    return (CGSize){width, 0};
}


#pragma mark - target action
- (void)clickBackBtn {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Notification -

- (void)registerNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRecallMessageNotification:)
                                                 name:RCKitDispatchRecallMessageNotification
                                               object:nil];
}

- (void)didReceiveRecallMessageNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        long recalledMsgId = [notification.object longValue];
        //产品需求：当前正在查看的图片被撤回，dismiss 预览页面，否则不做处理
        if (recalledMsgId == self.messageModel.messageId) {
            UIViewController *currentVC = [self rc_findTopViewController:self];
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:nil
                                                  message:RCLocalizedString(@"MessageRecallAlert")
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alertController
             addAction:[UIAlertAction actionWithTitle:RCLocalizedString(@"Confirm")
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *_Nonnull action) {
                [self rc_dismissCurrentVC];
            }]];
            [currentVC presentViewController:alertController animated:YES completion:nil];
        }
    });
}

#pragma mark -

//复制消息内容
- (void)onCopyMessage:(id)sender {
    // self.msgInputBar.msgColumnTextView.disableActionMenu = NO;
    self.chatSessionInputBarControl.inputTextView.disableActionMenu = NO;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    // RCMessageCell* cell = _RCMessageCell;
    //判断是否文本消息
    if ([self.longPressModel.content isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *text = (RCTextMessage *)self.longPressModel.content;
        [pasteboard setString:text.content];
    } else if ([self.longPressModel.content isKindOfClass:[RCReferenceMessage class]]) {
        RCReferenceMessage *refer = (RCReferenceMessage *)self.longPressModel.content;
        [pasteboard setString:refer.content];
    }
}

- (void)rc_dismissCurrentVC {
    UIViewController *presentingViewController = self.presentingViewController ;
    UIViewController *lastVC = self ;
    while (presentingViewController) {
        id temp = presentingViewController;
        presentingViewController = [presentingViewController presentingViewController];
        lastVC = temp ;
    }
    [lastVC dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (UIViewController*)rc_findTopViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self rc_findTopViewController:vc.presentedViewController];
    }else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0) {
            return [self rc_findTopViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    }else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0) {
            return [self rc_findTopViewController:svc.topViewController];
        } else {
            return vc;
        }
    }else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0) {
            return [self rc_findTopViewController:svc.selectedViewController];
        } else {
            return vc;
        }
    }
    return vc;
}

- (void)rc_startDownload {
    [self rc_showLoadingView];
    if (![self.messageModel.content isKindOfClass:[RCCombineV2Message class]]) {
        return;
    }
    RCCombineV2Message *combineV2Message = (RCCombineV2Message *)self.messageModel.content;
    [[RCCoreClient sharedCoreClient] downloadMediaFile:combineV2Message.name mediaUrl:combineV2Message.remoteUrl progress:^(int progress) {
        
    } success:^(NSString *mediaPath) {
        dispatch_main_async_safe(^{
            [self rc_hiddenTipView];
            combineV2Message.localPath = mediaPath;
            [self rc_loadMessage];
        });
    } error:^(RCErrorCode errorCode) {
        dispatch_main_async_safe(^{
            [self rc_showFailedView];
        });
    }cancel:^{
    }];
}

- (void)rc_loadMessage {
    if (![self.messageModel.content isKindOfClass:RCCombineV2Message.class]) {
        return;
    }
    RCCombineV2Message *combineMsg =  (RCCombineV2Message *)self.messageModel.content;
    if (combineMsg.jsonMsgKey.length > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:combineMsg.localPath]) {
            NSData *data = [NSData dataWithContentsOfFile:combineMsg.localPath];
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (array && [array isKindOfClass:[NSArray class]]) {
                self.conversationDataRepository = [self rc_getMessagesWithJson:array];
                [self rc_reloadList];
            } else {
                RCLogE(@"RCCombineV2Message message list error");
            }
        } else {
            [self rc_startDownload];
        }
    } else {
        self.conversationDataRepository = [self rc_getMessagesWithJson:combineMsg.msgList];
        [self rc_reloadList];
    }
}

- (void)rc_reloadList {
    [self rc_figureOutAllConversationDataRepository];
    [self.conversationMessageCollectionView reloadData];
}

- (void)pushPersonDetailVC:(RCDUserInfo *)user {
    if (self.conversationType == ConversationType_GROUP) {
        UIViewController *vc = [RCDPersonDetailViewController configVC:user.userId groupId:self.targetId];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIViewController *vc = [RCDPersonDetailViewController configVC:user.userId groupId:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSMutableArray <RCMessageModel *>*)rc_getMessagesWithJson:(NSArray <NSDictionary *>*)msgList {
    RCCombineV2Message *combineMsg =  (RCCombineV2Message *)self.messageModel.content;
    NSMutableArray *tempList = [NSMutableArray array];
    for (NSDictionary *dic in msgList) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        RCMessage *message = [[RCMessage alloc] init];
        message.senderUserId = dic[@"fromUserId"];
        message.targetId = dic[@"targetId"];
        message.sentTime = [dic[@"timestamp"] longLongValue];
        message.objectName = dic[@"objectName"];
        message.conversationType = combineMsg.conversationType;
        NSDictionary *json = dic[@"content"];
        if (json) {
            NSData *msgData = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil];
            RCMessageContent *content = [self rc_getMessageContent:message.objectName jsonData:msgData];
            if ([content isKindOfClass:[RCMediaMessageContent class]]) {
                RCMediaMessageContent *mediaContent = (RCMediaMessageContent *)content;
                mediaContent.localPath = [RCUtilities getCorrectedFilePath:[RCFileUtility getFileLocalPath:mediaContent.remoteUrl]];
            }
            message.content = content;
        }
        message.messageUId = [NSString stringWithFormat:@"%@",@(message.sentTime)];
        if ([message.senderUserId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            message.messageDirection = MessageDirection_SEND;
        } else {
            message.messageDirection = MessageDirection_RECEIVE;
        }
        RCMessageModel *model = [RCMessageModel modelWithMessage:message];
        [tempList addObject:model];
    }
    return tempList;
}

- (void)rc_figureOutAllConversationDataRepository {
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
        if (0 == i) {
            model.isDisplayMessageTime = YES;
        } else if (i > 0) {
            RCMessageModel *pre_model = [self.conversationDataRepository objectAtIndex:i - 1];

            long long previous_time = pre_model.sentTime;

            long long current_time = model.sentTime;

            long long interval =
                current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
            CGFloat increment = [self rc_incrementOfTimeLabelBy:model];
            if (interval / 1000 <= 3 * 60) {
                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
                    CGSize size = model.cellSize;
                    size.height = model.cellSize.height - increment;
                    model.cellSize = size;
                }
                model.isDisplayMessageTime = NO;
            }
        }
    }
}

- (CGFloat)rc_incrementOfTimeLabelBy:(RCMessageModel *)model {
    if ([model.content isKindOfClass:[RCHQVoiceMessage class]]) {
        return 36;
    } else {
        return 45;
    }
}

- (RCMessageContent *)rc_getMessageContent:(NSString *)objectName jsonData:(NSData *)jsonData {
    Class contentClass;
    if ([objectName isEqualToString:[RCTextMessage getObjectName]]) {
        contentClass = RCTextMessage.class;
    } else if ([objectName isEqualToString:[RCImageMessage getObjectName]]) {
        contentClass = RCImageMessage.class;
    } else if ([objectName isEqualToString:[RCSightMessage getObjectName]]) {
        contentClass = RCSightMessage.class;
    } else if ([objectName isEqualToString:[RCReferenceMessage getObjectName]]) {
        contentClass = RCReferenceMessage.class;
    } else if ([objectName isEqualToString:[RCVoiceMessage getObjectName]]) {
        contentClass = RCVoiceMessage.class;
    } else if ([objectName isEqualToString:[RCHQVoiceMessage getObjectName]]) {
        contentClass = RCHQVoiceMessage.class;
    } else if ([objectName isEqualToString:[RCCombineMessage getObjectName]]) {
        contentClass = RCCombineMessage.class;
    } else if ([objectName isEqualToString:[RCCombineV2Message getObjectName]]) {
        contentClass = RCCombineV2Message.class;
    } else if ([objectName isEqualToString:[RCGIFMessage getObjectName]]) {
        contentClass = RCGIFMessage.class;
    } else if ([objectName isEqualToString:[RCLocationMessage getObjectName]]) {
        contentClass = RCLocationMessage.class;
    } else if ([objectName isEqualToString:[RCContactCardMessage getObjectName]]) {
        contentClass = RCContactCardMessage.class;
    } else if ([objectName isEqualToString:[RCRichContentMessage getObjectName]]) {
        contentClass = RCContactCardMessage.class;
    } else if ([objectName isEqualToString:[RCRichContentMessage getObjectName]]) {
        contentClass = RCContactCardMessage.class;
    } else if ([objectName isEqualToString:[RCFileMessage getObjectName]]) {
        contentClass = RCFileMessage.class;
    } else if ([objectName isEqualToString:@"RC:StkMsg"]) {
        contentClass = NSClassFromString(@"RCStickerMessage");
    }
    if (!contentClass) {
        return nil;
    }
    id content = [[contentClass alloc] init];
    NSAssert([content isMemberOfClass:contentClass], @"Shoud always be passed this assertion");
    if ([contentClass conformsToProtocol:@protocol(RCMessageCoding)]) {
        if ([content respondsToSelector:@selector(decodeWithData:)]) {
            [content performSelector:@selector(decodeWithData:) withObject:jsonData];
        }
    }
    return content;
}

- (void)rc_configTipView {
    [self.view addSubview:self.tipVStackView];
    [self.tipVStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [self rc_hiddenTipView];
}

- (void)rc_hiddenTipView {
    [self.view sendSubviewToBack:self.tipVStackView];
    self.tipVStackView.hidden = YES;
    [self rc_stopAnimation];
}

- (void)rc_showLoadingView {
    if (self.tipVStackView.hidden) {
        [self.view bringSubviewToFront:self.tipVStackView];
        self.tipVStackView.hidden = NO;
    }
    [self.view bringSubviewToFront:self.tipVStackView];
    self.tipIcon.image = RCResourceImage(@"combine_loading");
    self.tipLabel.text = RCLocalizedString(@"CombineMessageLoading");
}

- (void)rc_showFailedView {
    if (self.tipVStackView.hidden) {
        [self.view bringSubviewToFront:self.tipVStackView];
        self.tipVStackView.hidden = NO;
    }
    [self rc_stopAnimation];
    self.tipIcon.image = RCResourceImage(@"combine_loading");
    self.tipLabel.text = RCLocalizedString(@"CombineMessageLoading");
}

- (void)rc_startAnimation {
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [self.tipIcon.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)rc_stopAnimation {
    if (self.tipIcon) {
        [self.tipIcon.layer removeAnimationForKey:@"rotationAnimation"];
    }
}

- (UIStackView *)tipVStackView {
    if (!_tipVStackView) {
        _tipVStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.tipIcon, self.tipLabel]];
        _tipVStackView.translatesAutoresizingMaskIntoConstraints = NO;
        _tipVStackView.axis = UILayoutConstraintAxisVertical;
        _tipVStackView.alignment = UIStackViewAlignmentCenter;
        _tipVStackView.spacing = RCViewSpace;
    }
    return _tipVStackView;
}

- (UIImageView *)tipIcon {
    if (!_tipIcon) {
        _tipIcon = [[UIImageView alloc] init];
    }
    return _tipIcon;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:15];
        _tipLabel.numberOfLines = 1;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textColor =
            [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1 / 1.0];
    }
    return _tipLabel;
}

@end
