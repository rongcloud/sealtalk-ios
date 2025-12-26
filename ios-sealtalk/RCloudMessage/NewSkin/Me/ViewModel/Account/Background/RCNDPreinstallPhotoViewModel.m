//
//  RCNDPreinstallPhotoViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDPreinstallPhotoViewModel.h"
#import "RCDCommonString.h"

@implementation RCNDPreinstallPhotoViewModel

- (void)refresh {
    [self ready];
}

- (void)ready {
    NSArray * dataArray = @[
        @"chat_bg_select_0",
        @"chat_bg_select_1",
        @"chat_bg_select_2",
        @"chat_bg_select_3",
        @"chat_bg_select_4",
        @"chat_bg_select_5"
    ];
    NSArray *imageDetailArray =
        @[ @"chat_bg_select_0", @"chat_bg_1", @"chat_bg_2", @"chat_bg_3", @"chat_bg_4", @"chat_bg_5" ];
    NSString *imageName = [DEFAULTS objectForKey:RCDChatBackgroundKey];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i< dataArray.count; i++) {
        NSString *name = dataArray[i];
        NSString *detail = imageDetailArray[i];
        RCNDPreinstallPhotoCellViewModel *vm = [RCNDPreinstallPhotoCellViewModel new];
        vm.selected = [detail isEqualToString:imageName];
        vm.imageName = name;
        vm.detailImageName = detail;
        [array addObject:vm];
    }
    self.dataSource = array;
}
@end
