import { webview } from '@kit.ArkWeb';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MessageStore, Message } from './MessageStore';

const TAG: string = 'MessageBridge';

/**
 * MessageBridge —— 网页 ↔ 原生 桥接对象
 *
 * 通过 Web 组件的 javaScriptProxy 注入到网页，挂载为 window.nativeBridge。
 * 网页侧可调用：
 *   - submitMessage(nickname, content)  提交留言，原生持久化后回调网页刷新
 *   - showToast(msg)                    弹出原生 Toast
 *   - clearAll()                        清空所有留言
 *   - onPageReady()                     网页 DOMContentLoaded 时通知原生
 *
 * 原生侧通过 controller.runJavaScript 主动回调网页：
 *   - window.renderMessages(jsonStr)    回传历史留言列表
 *   - window.onMessageSaved(jsonStr)    通知单条留言已保存
 *   - window.onNativeNotification(text) 原生推送一条通知
 *   - window.onCleared()                通知清空完成
 */
export class MessageBridge {
  private store: MessageStore;
  private controller: webview.WebviewController;

  constructor(store: MessageStore, controller: webview.WebviewController) {
    this.store = store;
    this.controller = controller;
  }

  // ==================== 网页 → 原生（暴露给 JS 调用） ====================

  /** 网页提交留言 */
  submitMessage(nickname: string, content: string): void {
    hilog.info(0x0000, TAG, 'submitMessage: %{public}s / %{public}s', nickname, content);
    if (!nickname || !content) {
      this.showToast('昵称或内容为空');
      return;
    }
    const msg: Message = this.store.add(nickname, content);
    // 回调网页：通知已保存，网页自行追加到列表
    const js: string = 'window.onMessageSaved(' + JSON.stringify(JSON.stringify(msg)) + ')';
    this.controller.runJavaScript(js);
  }

  /** 网页请求弹出原生 Toast */
  showToast(msg: string): void {
    promptAction.showToast({ message: msg, duration: 1800 });
  }

  /** 网页请求清空留言 */
  clearAll(): void {
    this.store.clear();
    this.controller.runJavaScript('window.onCleared()');
  }

  /** 网页 DOM 就绪，原生此时回传历史留言 */
  onPageReady(): void {
    this.sendHistory();
  }

  // ==================== 原生 → 网页（主动推送） ====================

  /** 回传历史留言列表给网页渲染 */
  sendHistory(): void {
    const list: Message[] = this.store.getAll();
    const js: string = 'window.renderMessages(' + JSON.stringify(JSON.stringify(list)) + ')';
    this.controller.runJavaScript(js);
  }

  /** 原生主动向网页推送一条通知 */
  pushNotification(text: string): void {
    const js: string = 'window.onNativeNotification(' + JSON.stringify(text) + ')';
    this.controller.runJavaScript(js);
  }
}
