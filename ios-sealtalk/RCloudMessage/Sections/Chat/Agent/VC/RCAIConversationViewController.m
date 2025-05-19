//
//  RCAIConversationViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/7.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCAIConversationViewController.h"
#import "RCDAgentUnavailableView.h"
#import "RCDAgentSettingViewController.h"
#import "RCDAgentContext.h"

#define PLUGIN_BOARD_ITEM_AGENT_TAG 1110
@interface RCAIConversationViewController ()<RCAgentFacadeUIDelegate,RCAgentViewDelegate>
@property (nonatomic, weak) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIButton *buttonAgent;
@property (nonatomic, strong) RCConversationIdentifier *identifier;
@property (nonatomic, strong) RCDAgentTag *agentTag;
@property (nonatomic, strong) RCDAgentUnavailableView *unavailableView;
@property (nonatomic, copy) NSString *targetUsername;
@property (nonatomic, copy) NSString *currentUsername;
@property (nonatomic, assign) BOOL recommendationEnable;
@end

@implementation RCAIConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureForAgent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.agentTag = [self currentAgentTag];
    [self.agent changeAgentIDIfNeed:self.agentTag.agentID];
   
    if (self.agent.agentView.superview) {
        BOOL ret = [RCDAgentContext isAbilityValidForKey:RCDAgentEnableKey];
        if (ret) {// 已开启
            if (self.unavailableView.superview) {// 显示不可用视图
                [self.agent.agentView hideStatusView];
                [self.agent requestRecommendationWith:self.agentTag.agentID
                                           customInfo:[self customPrompt]];
            }
        } else {
            if (!self.unavailableView.superview) {// 没显示不可用视图
                [self.agent.agentView showStatusView:self.unavailableView];
            }
        }
    }
}

- (void)configureForAgent {
    RCUserInfo *user = [[RCIM sharedRCIM] getUserInfoCache:self.targetId];
    self.targetUsername = user.name;
    user = [[RCIM sharedRCIM] currentUserInfo];
    self.currentUsername = user.name;
    RCConversationIdentifier *identifier = [RCConversationIdentifier new];
    identifier.targetId = self.targetId;
    identifier.channelId = self.channelId;
    identifier.type = self.conversationType;
    self.identifier = identifier;
    self.agent.dataSource = self;
    self.agent.uiDelegate = self;
    self.agent.agentView.backgroundView.image = [UIImage imageNamed:@"ai_agent_bg"];
    self.agent.agentView.delegate = self;
    [self configureAgentButton];
    [self reconfigurePlusButton];
    
}

- (RCDAgentTag *)currentAgentTag {
    RCDAgentTag *tag = [RCDAgentContext agentTagFor:self.identifier];
    if (!tag) {
        NSArray *tags = [RCDAgentContext agentTags];
        tag = [tags firstObject];
    }
    return tag;
}

- (void)configureAgentButton {
    if (self.buttonAgent.superview) {
        [self.buttonAgent removeFromSuperview];
    }
    
    [self.chatSessionInputBarControl.inputTextView.superview addSubview:self.buttonAgent];
    CGSize size = self.chatSessionInputBarControl.inputTextView.superview.bounds.size;
    CGFloat xOffset = self.chatSessionInputBarControl.inputTextView.frame.origin.x +self.chatSessionInputBarControl.inputTextView.frame.size.width;
    self.buttonAgent.center = CGPointMake(xOffset-self.buttonAgent.frame.size.width/2-4, size.height/2);
    UIEdgeInsets textEdge = self.chatSessionInputBarControl.inputTextView.textContainerInset;
    textEdge.right += 22;
    self.chatSessionInputBarControl.inputTextView.textContainerInset = textEdge;
}

- (void)showSetting {
    RCDAgentSettingViewController *vc = [[RCDAgentSettingViewController alloc] init];
    vc.identifier = self.identifier;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 自定义提示词
- (NSDictionary *)customPrompt {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"user_name"]= self.currentUsername;
    info[@"target_name"]= self.targetUsername;
    return info;
}
#pragma mark - RCAgentFacadeDelegate

- (void)agent:(RCAgentFacadeModel *)agent didSelectedRecommendations:(NSArray<RCAgentRecommendation *>*)recommendations {
    for (int i = 0; i< recommendations.count; i++) {
        RCAgentRecommendation *obj = recommendations[i];
        if ([obj imkit_category] == RCAgentRecommendationCategoryText) {
            RCTextMessage *txt = [RCTextMessage messageWithContent:obj.content];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i*1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sendMessage:txt pushContent:nil];
            });
        }
    }
    [agent removeAndCleanAgentView];
    self.recommendationEnable = NO;
    [self.chatSessionInputBarControl updateStatus:KBottomBarDefaultStatus animated:YES];
}

- (void)agent:(RCAgentFacadeModel *)agent editRecommendation:(NSArray <RCAgentRecommendation *> *)recommendations {
    [self.chatSessionInputBarControl setDefaultInputType:RCChatSessionInputBarInputText];
    NSString *recommendation = @"";
    if(recommendations.count) {
        RCAgentRecommendation *obj = recommendations[0];
        if ([obj imkit_category] == RCAgentRecommendationCategoryText) {
            recommendation = obj.content;
        }
    }
    self.chatSessionInputBarControl.draft = recommendation;
    [self.chatSessionInputBarControl updateStatus:KBottomBarKeyboardStatus animated:YES];
    [agent removeAndCleanAgentView];
    self.recommendationEnable = NO;
}

#pragma mark - RCAgentMessageDataSource
- (void)agent:(RCAgentFacadeModel *)agent
                 fetchMessageWithIdentifier:(RCConversationIdentifier *)identifier
                                   maxCount:(NSInteger)maxCount
                                 completion:(nonnull void (^)(NSArray<RCAgentContextMessage *> * _Nonnull))completion{
    BOOL ret = [RCDAgentContext isAbilityValidForKey:RCDAgentMessageAuthKey];
    if (ret) {
        NSMutableArray *array = [NSMutableArray array];
        [[RCCoreClient sharedCoreClient] getHistoryMessages:self.conversationType
                                                                       targetId:self.targetId
                                                                    objectNames:@[@"RC:TxtMsg"]
                                                                       sentTime:0
                                                                      isForward:YES
                                                                          count:[@(maxCount) intValue]
                                                                     completion:^(NSArray<RCMessage *> * _Nullable messages) {
            for (RCMessage *msg in messages) {
                RCAgentContextMessage * m = [RCAgentContextMessage new];
                m.userId = msg.senderUserId ?:@"";
                RCTextMessage *text = (RCTextMessage *)msg.content;
                m.content = text.content;
                m.timestamp = msg.sentTime;
                m.type = RCAgentContextMessageTypeText;
                m.messageId = msg.messageUId;
                if ([msg.senderUserId isEqualToString: self.targetId]) {
                    m.username = self.targetUsername;
                } else {
                    m.username = self.currentUsername;
                }
                [array addObject:m];
            }
            if (completion) {
                completion(array);
            }
        }];
    } else {
        if (completion) {
            completion(@[]);
        }
    }

}


#pragma mark - RCAgentFacadeUIDelegate
/// 用户配置智能体
/// - Parameter agent: agent
/// - Parameter identifier: 会话标识
- (void)agent:(RCAgentFacadeModel *)agent didClickSetting:(RCConversationIdentifier *)identifier {
    [self showSetting];
}

/// 用户刷新智能体推荐内容
/// - Parameter agent: agent
/// - Parameter identifier: 会话标识
- (BOOL)agent:(RCAgentFacadeModel *)agent shouldRefresh:(RCConversationIdentifier *)identifier {
    BOOL ret = [RCDAgentContext isAbilityValidForKey:RCDAgentEnableKey];
    if (!ret) {
        [RCAlertView showAlertController:nil
                                 message:RCDLocalizedString(@"agent_unavailable_title")
                             cancelTitle:RCLocalizedString(@"OK")
                        inViewController:self];
    }
    return ret;
}

- (void)agent:(RCAgentFacadeModel *)agent requestRecommendationFinished:(RCErrorCode)code {
    NSLog(@"[A] requestFinished: %ld", code);
    if (code != RC_SUCCESS) {
        [RCAlertView showAlertController:nil
                                 message:[NSString stringWithFormat:@"%ld", code]
                        hiddenAfterDelay:2];
    } else {
        self.recommendationEnable = YES;
    }
}

#pragma mark - RCAgentViewDelegate

- (void)agentView:(RCAgentView *)agentView didMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) {
        [self restoreInputBarFroAgent];
    } else {
        [self configureInputBarForAgent];
    }
}

#pragma mark - Private

- (void)configureInputBarForAgent {
    if (self.gradientLayer) {
        [self.gradientLayer removeFromSuperlayer];
    }
    self.gradientLayer = [self gradientLayerForView:self.chatSessionInputBarControl.inputTextView];
    [self.chatSessionInputBarControl.inputTextView.layer addSublayer:self.gradientLayer];
}


- (void)restoreInputBarFroAgent {
    if (self.gradientLayer) {
        [self.gradientLayer removeFromSuperlayer];
    }
}

- (CAGradientLayer *)gradientLayerForView:(UIView *)view {
    // 创建渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    
    gradientLayer.colors = @[(id)RCMASKCOLOR(0x7F6AFE,1).CGColor, (id)RCMASKCOLOR(0x6FDEE5,1).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    
    // 创建形状层来模拟边框
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.lineWidth = 1;
    CGFloat cornerRadius = 6; // 设置圆角半径
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(view.bounds, 1,1) cornerRadius:cornerRadius].CGPath;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor blackColor].CGColor;
    
    // 将形状层作为渐变层的遮罩
    gradientLayer.mask = borderLayer;
    
    // 将渐变层添加到 UIView 的 layer 上
    return gradientLayer;
}

- (void)chatInputBar:(RCChatSessionInputBarControl *)chatInputBar
   shouldChangeFrame:(CGRect)frame {
    [super chatInputBar:chatInputBar shouldChangeFrame:frame];
  
    // 输入框还原, 则移除 AI 视图
    if (chatInputBar.currentBottomBarStatus != KBottomBarPluginStatus) {
        [self.agent.agentView removeFromSuperview];
        return;
    }
}

/// AI 按钮点击事件
- (void)buttonAgentClicked {
    if (self.agent.agentView.superview) {
//        [self.agent removeAndCleanAgentView];
        [self.agent.agentView removeFromSuperview];
        [self.chatSessionInputBarControl resetToDefaultStatus];
    } else {
        [self.chatSessionInputBarControl setDefaultInputType:RCChatSessionInputBarInputExtention];
        [self.chatSessionInputBarControl containerViewWillAppear];
        UIView *pluginBoardView = self.chatSessionInputBarControl.pluginBoardView;
        self.agent.agentView.frame = pluginBoardView.bounds;
        if (![RCDAgentContext isAbilityValidForKey:RCDAgentEnableKey]) {
            [self.agent.agentView showStatusView:self.unavailableView];
        } else {
            if (!self.recommendationEnable) {
                [self.agent requestRecommendationWith:self.agentTag.agentID
                                           customInfo:[self customPrompt]];
            }
        }
        [pluginBoardView addSubview:self.agent.agentView];
     
    }
}

/// 扩展按钮点击事件
- (void)additionalButtonClick {
    // 如果agent 视图已显示, 则移除视图
    if (self.agent.agentView.superview) {
        [self.agent.agentView removeFromSuperview];
        return;
    }
    // 触发原有扩展按钮点击事件
    UIButton *btn = self.chatSessionInputBarControl.additionalButton;
    [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
}


/// 重新配置扩展按钮
- (void)reconfigurePlusButton {
    UIButton *additionalButton = self.chatSessionInputBarControl.additionalButton;
    self.chatSessionInputBarControl.additionalButton.hidden = YES;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = additionalButton.frame;
    [btn setImage:additionalButton.imageView.image
         forState:UIControlStateNormal];
    [self.chatSessionInputBarControl.inputContainerView addSubview:btn];
    [btn addTarget:self
            action:@selector(additionalButtonClick)
  forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Property

- (UIButton *)buttonAgent {
    if (!_buttonAgent) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"agent_call_btn"]
             forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self
                action:@selector(buttonAgentClicked)
      forControlEvents:UIControlEventTouchUpInside];
        _buttonAgent = btn;
    }
    return _buttonAgent;
}

- (RCDAgentUnavailableView *)unavailableView {
    if (!_unavailableView) {
        RCDAgentUnavailableView *view = [RCDAgentUnavailableView new];
        [view.buttonEnable addTarget:self
                              action:@selector(showSetting)
                    forControlEvents:UIControlEventTouchUpInside];
        _unavailableView = view;
    }
    return _unavailableView;
}
@end
