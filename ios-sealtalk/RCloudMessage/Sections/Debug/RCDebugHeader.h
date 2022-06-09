//
//  RCDebugHeader.h
//  RCloudMessage
//
//  Created by chinaspx on 2022/5/27.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#ifndef RCDebugHeader_h
#define RCDebugHeader_h

/*!
 会话集合设置方式
 */
typedef NS_ENUM(NSInteger, RCDebugCollectionModifyMode) {
    
    RCDebugCollectionModifyModeDefault = 0,         // 默认值，不设置
    RCDebugCollectionModifyModeWillDisplayCell = 1, // willDisplayConversationTableCell 中修改
    RCDebugCollectionModifyModeGlobalConfig = 2     // 全局配置中修改
};


#endif /* RCDebugHeader_h */
