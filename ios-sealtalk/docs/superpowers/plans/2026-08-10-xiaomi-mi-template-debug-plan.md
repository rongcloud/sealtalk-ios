# iOS SealTalk 小米私信模板 Debug 测试实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**目标：** 在 iOS SealTalk 的现有消息推送 Debug 配置中增加小米私信模板 ID 和模板参数配置，使 iOS 发送到 Xiaomi Android 设备的消息可验证 5.46.0 IMLib 的编码链路。

**架构：** 复用 `RCDDebugMessagePushConfigController` 的现有页面和 `NSUserDefaults` 配置机制。各 Debug 发送控制器继续从共享配置构造 `RCMessagePushConfig`，新增字段统一从持久化 JSON 解析为 `NSDictionary<NSString *, NSString *>`；普通生产聊天路径不改动。

**技术栈：** Objective-C、UIKit、Masonry、RongIMLib 5.46.0。

---

### Task 1: 增加小米模板配置 UI 与持久化

**文件：** `RCloudMessage/Sections/Debug/MessagePushConfig/RCDDebugMessagePushConfigController.m`

- 增加默认关闭的开关、模板 ID 输入框和 JSON 参数输入框，默认值分别为 `P12491` 与 `{"keywords1":"测试群","keywords2":"张三","keywords3":"测试消息"}`。
- 从 `NSUserDefaults` 加载并保存开关、模板 ID、JSON 参数。
- 开关关闭时不向 `RCMessagePushConfig.androidConfig` 写入小米模板字段。
- 开关打开时用 `NSJSONSerialization` 解析 JSON，仅接受字符串键和值；非法 JSON 不崩溃且阻止保存并提示错误。

### Task 2: 让所有 Debug 发送路径携带小米模板字段

**文件：**
- `RCloudMessage/Sections/Debug/MessagePushConfig/RCDDebugChatViewController.m`
- `RCloudMessage/Sections/Debug/CommonChatroom/RCDDebugComChatViewController.m`
- `RCloudMessage/Sections/Debug/UlTraGroup/RCDDebugUltraGroupChatViewController.m`
- `RCloudMessage/Sections/Debug/UlTraGroup/RCDDebugUltraGroupSendMessage.m`

- 各 `getPushConfig` 从相同的 `NSUserDefaults` 键读取开关、模板 ID、JSON 参数。
- 解析成功后赋值 `templateIdMi`、`templateParamMi`，关闭或解析失败时保持为空。
- 保留现有普通模板、渠道、iOS/华为/OPPO 等字段行为。

### Task 3: 依赖与验证

**文件：** `framework/RongIMLibCore/RongIMLibCore.framework` 与 `framework/RongIMLib/RongIMLib.framework`

- 确认头文件暴露 `RCAndroidConfig.templateIdMi` 和 `templateParamMi`。
- 执行 SealTalk Debug 构建；若本地框架未更新，明确记录为阻塞而不伪造通过结果。
- 使用 iOS 发送端 + Xiaomi Android 接收端验证关闭、完整配置、仅 ID、仅参数和非法 JSON 五种场景。
