//
//  RCNDChatroomViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDChatroomViewController.h"
#import "RCNDChatroomView.h"
#import "RCUChatViewController.h"
#import "RCDChatRoomManager.h"
#import "RCDCommonString.h"
@interface RCNDChatroomViewController ()
@property (nonatomic, strong) RCNDChatroomView *chatroomView;
@property (nonatomic, strong) NSArray *chatRoomList;
@end

@implementation RCNDChatroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"chatroom");
    [self getDefaultChatRoomInfo];
    [self fetchRemoteChatRoomListAndRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 进入页面时设置透明
    [self configureTransparentNavigationBar];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 离开页面时恢复默认样式
    [self restoreDefaultNavigationBarAppearance];
}

- (void)loadView {
    self.view = self.chatroomView;
}

- (void)showChatViewControllerAt:(NSInteger)index {
    [self restoreDefaultNavigationBarAppearance];

    RCDChatRoom *room = self.chatRoomList[index];
    if (room.targetId && room.targetId.length > 0) {
        RCDChatViewController *chatVC = [[RCDChatViewController alloc] initWithConversationType:ConversationType_CHATROOM targetId:room.targetId];
        chatVC.title = room.name;
        [self.navigationController pushViewController:chatVC animated:YES];
    } else {
        [self.view showHUDMessage:RCDLocalizedString(@"ChatroomIdIsEmpty")];
    }
}

- (void)warmHomeControlTouched:(UIControl *)control {
    [self showChatViewControllerAt:0];

}

- (void)futureTouchControl:(UIControl *)control {
    [self showChatViewControllerAt:1];
}

- (void)musicHeavenControl:(UIControl *)control {
    [self showChatViewControllerAt:2];
}

- (void)gameInfoControl:(UIControl *)control {
    [self showChatViewControllerAt:3];
}


#pragma mark - private method
- (void)getDefaultChatRoomInfo {
    NSMutableArray *squareInfoList = [DEFAULTS mutableArrayValueForKey:RCDSquareInfoListKey];
    NSMutableArray *array = [NSMutableArray array];
    if (squareInfoList.count > 0) {
        for (NSDictionary *info in squareInfoList) {
            RCDChatRoom *room = [RCDChatRoom new];
            room.targetId = info[@"id"];
            room.name = info[@"name"];
            [array addObject:room];
        }
    } else {
        NSArray *names = @[ @"温暖小窝", @"未来触手", @"音乐天堂", @"游戏情报站" ];
        for (NSString *name in names) {
            RCDChatRoom *room = [RCDChatRoom new];
            room.targetId = @"";
            room.name = name;
            [array addObject:room];
        }
    }
    self.chatRoomList = array.copy;
}

- (void)fetchRemoteChatRoomListAndRefresh {

    RCNetworkStatus status = [[RCCoreClient sharedCoreClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        return;
    }
    [RCDChatRoomManager getChatRoomList:^(NSArray<RCDChatRoom *> *_Nonnull rooms) {
        if (rooms) {
            rcd_dispatch_main_async_safe(^{
                for (int i = 0; i<rooms.count; i++) {
                    RCDChatRoom *room = rooms[i];
                    if (i<self.chatRoomList.count) {
                        RCDChatRoom *room2 = self.chatRoomList[i];
                        room2.targetId = room.targetId;
                    }
                }
                [self saveChatRoomList:rooms];
            });
        }
    }];
}

- (void)saveChatRoomList:(NSArray *)result {
    if (result.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (RCDChatRoom *room in result) {
            NSDictionary *dic = @{ @"id" : room.targetId, @"name" : room.name };
            [array addObject:dic];
        }
        //保存默认聊天室信息
        [DEFAULTS setObject:array forKey:RCDSquareInfoListKey];
        [DEFAULTS synchronize];
    }
}


- (RCNDChatroomView *)chatroomView {
    if (!_chatroomView) {
        RCNDChatroomView *view = [RCNDChatroomView new];
        [view.warmHomeControl addTarget:self
                                 action:@selector(warmHomeControlTouched:)
                       forControlEvents:UIControlEventTouchUpInside];
        [view.futureTouchControl addTarget:self
                                 action:@selector(futureTouchControl:)
                       forControlEvents:UIControlEventTouchUpInside];
        [view.musicHeavenControl addTarget:self
                                 action:@selector(musicHeavenControl:)
                       forControlEvents:UIControlEventTouchUpInside];
        [view.gameInfoControl addTarget:self
                                 action:@selector(gameInfoControl:)
                       forControlEvents:UIControlEventTouchUpInside];
        _chatroomView = view;
    }
    return _chatroomView;
}

@end


