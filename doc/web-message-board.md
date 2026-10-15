# 任务5：网页留言板（Web ↔ 原生双向通信）

> 学号：3124001420　姓名：谢瀚楠　分支：`task5-web-message-board`

## 一、功能概述

在课程项目中新增一个"网页留言板"页面。使用鸿蒙 **Web 组件**加载放在 `rawfile` 目录中的本地 HTML 页面，通过 **JavaScriptProxy** 注入桥接对象，实现网页与原生侧的双向通信。留言数据由原生侧使用 **Preferences** 持久化保存。

### 已实现功能

| 类别 | 功能 |
|---|---|
| 基础要求 | Web 组件加载 rawfile 本地 HTML；网页结构/样式/脚本全在网页侧 |
| 网页→原生 | `nativeBridge.submitMessage()` 提交留言、`showToast()` 弹出 Toast、`clearAll()` 清空 |
| 原生→网页 | 页面加载完成时回传历史留言 `renderMessages()`；单条保存后回调 `onMessageSaved()`；主动推送通知 `onNativeNotification()` |
| 持久化 | 原生侧 Preferences 存储留言 JSON 数组，重启 App 不丢失 |
| 加载提示 | 加载中显示 Loading 进度条 + 菊花遮罩；加载失败显示错误页与"重新加载"按钮 |
| 特色功能 | 加载进度条、网页标题同步到原生标题栏、前进/后退/刷新工具栏、原生侧推送通知按钮 |

## 二、项目结构

```
entry/src/main/
├── ets/
│   ├── pages/
│   │   └── MessageBoard.ets        # Web 容器页面（UI、加载/错误状态、工具栏）
│   └── webbridge/
│       ├── MessageStore.ets       # 持久化层：Preferences 读写留言
│       └── MessageBridge.ets      # 桥接层：注入 nativeBridge，双向通信
└── resources/
    └── rawfile/
        └── message_board.html     # 网页留言板（HTML + CSS + JS）
```

桥接代码独立封装在 `ets/webbridge/` 目录下，`MessageStore` 只负责数据存取，`MessageBridge` 只负责双向调用，职责清晰、互不耦合。

## 三、双向通信架构

```
┌─────────────────┐         javaScriptProxy          ┌─────────────────┐
│  网页 (HTML/JS)  │  ───────────────────────────▶    │  原生 (ArkTS)    │
│                 │   nativeBridge.submitMessage()    │                 │
│                 │   nativeBridge.showToast()        │  MessageStore   │
│                 │   nativeBridge.clearAll()         │  (Preferences)  │
│                 │                                 │                 │
│                 │  ◀───────────────────────────  │                 │
│                 │   runJavaScript() 回调：         │                 │
│                 │   window.renderMessages(list)    │                 │
│                 │   window.onMessageSaved(msg)      │                 │
│                 │   window.onNativeNotification()  │                 │
└─────────────────┘                                 └─────────────────┘
```

### 3.1 网页调用原生（注入桥接对象）

在 `MessageBoard.ets` 中通过 `.javaScriptProxy()` 注入：

```typescript
Web({ src: $rawfile('message_board.html'), controller: this.controller })
  .javaScriptProxy({
    object: this.bridge,
    name: 'nativeBridge',
    methodList: ['submitMessage', 'showToast', 'clearAll', 'onPageReady'],
    controller: this.controller
  })
```

网页侧调用示例：

```javascript
window.nativeBridge.submitMessage(nickname, content);
```

### 3.2 原生调用网页（runJavaScript）

原生侧通过 `controller.runJavaScript()` 主动执行网页中的 JS 函数：

```typescript
// 回传历史留言
const js = 'window.renderMessages(' + JSON.stringify(JSON.stringify(list)) + ')';
this.controller.runJavaScript(js);
```

## 四、数据模型

```typescript
interface Message {
  id: number;        // 时间戳唯一 ID
  nickname: string;  // 昵称
  content: string;   // 留言内容
  timestamp: number; // 毫秒时间戳
}
```

## 五、运行方式

1. 在 DevEco Studio 中切换到分支 `task5-web-message-board`
2. 连接鸿蒙手机/模拟器，运行 `entry` 工程
3. 首页 → 进入任务列表 → 点击"网页留言板"
4. 输入昵称和内容提交，退出再进入可看到历史留言仍在
5. 点击工具栏"推送通知"可测试原生→网页主动推送

## 六、关键技术点

- **`$rawfile()`** 加载 rawfile 目录下本地 HTML，无需网络
- **`javaScriptProxy`** 将 ArkTS 对象注入网页全局 `window`，方法名通过 `methodList` 暴露
- **`onPageEnd`** 页面加载完成后调用 `sendHistory()` 回传留言列表
- **`onErrorReceive`** 捕获加载失败，显示友好错误页
- **`onProgressChange`** 实时获取加载进度，显示进度条
- **`onTitleReceive`** 同步网页标题到原生顶部栏
- **Preferences** 同步 API（`getSync/putSync`）存储 JSON 字符串
