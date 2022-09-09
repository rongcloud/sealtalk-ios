//
//  RCDUnreadCountViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/8/2.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUnreadCountViewController.h"
#import "RCDUnreadCountParamController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUnreadCountView.h"
#import "RCDUGSelectListViewController.h"
#import "UIView+MBProgressHUD.h"

@interface RCDUnreadCountViewController()<RCDUnreadCountParamControllerDelegate, RCDUGSelectListViewControllerDelegate>
@property (nonatomic, strong) RCDUnreadCountView *detailView;
@property (nonatomic, strong) NSArray *arrayTypes;
@property (nonatomic, strong) NSArray *arrayLevels;
@property (nonatomic, copy) NSString *targetID;
@property (nonatomic, copy) NSString *groupName;
@end

@implementation RCDUnreadCountViewController

- (void)loadView {
    self.view = self.detailView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

#pragma mark - Private

- (void)ready {
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(back)];
    self.navigationItem.leftBarButtonItem = btn;
    
    UIBarButtonItem *btnParam = [[UIBarButtonItem alloc] initWithTitle:@"参数"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(selectParam)];
    if (self.isUltraGroup) {
        UIBarButtonItem *btnCategory = [[UIBarButtonItem alloc] initWithTitle:@"会话"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(selectCategory)];
        self.navigationItem.rightBarButtonItems = @[btnCategory, btnParam];
    } else {
        self.navigationItem.rightBarButtonItem = btnParam;
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectCategory {
    RCDUGSelectListViewController *vc = [RCDUGSelectListViewController new];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectParam {
    RCDUnreadCountParamController *vc = [[RCDUnreadCountParamController alloc] initWithConversationTypes:self.arrayTypes
                                                                                                  levels:self.arrayLevels];
    vc.delegate = self;
    vc.ultraGroup = self.ultraGroup;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCount:(NSInteger)count {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.detailView showCount:count];
    });
}

- (void)showError:(RCErrorCode)code {
    NSString *content = @"查询失败";
    switch (code) {
        case INVALID_PARAMETER_CONVERSATIONTYPENOTSUPPORT:
            content = @"不支持的会话类型";
            break;
        case INVALID_PARAMETER_CONVERSATIONTYPE:
            content = @"不合法的会话类型";
            break;
        case INVALID_PARAMETER_TARGETID:
            content = @"会话ID非法";
            break;
        case INVALID_PARAMETER_NOTIFICATION_LEVEL:
            content = @"免打扰级别非法";
            break;
        default:
            break;
    }
    [self showHUDMessage:content];
}

- (void)query {
    if (self.isUltraGroup) {
        if (!self.isMentioned) {
            [[RCChannelClient sharedChannelManager] getUltraGroupUnreadCount:self.targetID levels:self.arrayLevels success:^(NSInteger count) {
                [self showCount:count];
            } error:^(RCErrorCode status) {
                [self showError:status];
            }];
        } else {
            [[RCChannelClient sharedChannelManager] getUltraGroupUnreadMentionedCount:self.targetID
                                                                                levels:self.arrayLevels
                                                                               success:^(NSInteger count) {
                [self showCount:count];
            } error:^(RCErrorCode status) {
                [self showError:status];
            }];
        }
    } else {
        if (self.isMentioned) {
            [[RCChannelClient sharedChannelManager] getUnreadMentionedCount:self.arrayTypes levels:self.arrayLevels success:^(NSInteger count) {
                [self showCount:count];
            } error:^(RCErrorCode status) {
                [self showError:status];
            }];
        } else {
            [[RCChannelClient sharedChannelManager] getUnreadCount:self.arrayTypes levels:self.arrayLevels success:^(NSInteger count) {
                [self showCount:count];
                } error:^(RCErrorCode status) {
                    [self showError:status];
                }];
        }
    }
    
}

- (void)showHUDMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:message];
    });
}

#pragma mark - RCDUnreadCountParamControllerDelegate
- (void)userDidSelected:(NSArray<NSNumber *> *)conversationTypes
             typeString:(NSString *)typeString
                 levels:(NSArray<NSNumber *> *)levels
            levelString:(NSString *)levelString {
    self.arrayTypes = conversationTypes;
    self.arrayLevels = levels;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.detailView showTypes:typeString];
        [self.detailView showLevels:levelString];
    });
}

#pragma mark - RCDUGSelectListViewControllerDelegate

- (void)userDidSelected:(NSString *)conversationName
               targetID:(NSString *)targetID
            channelName:(NSString *)channelName
              channelID:(NSString *)channelID {
    self.targetID = targetID;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = [NSString stringWithFormat:@"%@-%@", conversationName, targetID];
    });
}

#pragma mark - Property

- (RCDUnreadCountView *)detailView {
    if (!_detailView) {
        _detailView = [RCDUnreadCountView new];
        [_detailView.btnQuery addTarget:self
                                 action:@selector(query)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailView;
}
@end
