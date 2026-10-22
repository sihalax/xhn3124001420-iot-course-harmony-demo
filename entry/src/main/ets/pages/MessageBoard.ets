import { webview } from '@kit.ArkWeb';
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { MessageStore } from '../webbridge/MessageStore';
import { MessageBridge } from '../webbridge/MessageBridge';

/**
 * 任务5：网页留言板
 * - Web 组件加载 rawfile/message_board.html
 * - javaScriptProxy 注入 nativeBridge，实现网页↔原生双向通信
 * - 加载中 / 加载失败友好提示
 * - 特色功能：加载进度条、网页标题同步、前进/后退/刷新、原生推送通知
 */
@Entry
@Component
struct MessageBoard {
  // ---- 原生侧状态 ----
  @State title: string = '网页留言板';
  @State progress: number = 0;
  @State isLoading: boolean = true;
  @State loadError: boolean = false;

  // ---- Web 控制器与桥接对象 ----
  private controller: webview.WebviewController = new webview.WebviewController();
  private store: MessageStore = new MessageStore();
  private bridge: MessageBridge | null = null;

  aboutToAppear(): void {
    const ctx: common.Context = getContext(this) as common.Context;
    this.store.init(ctx);
    this.bridge = new MessageBridge(this.store, this.controller);
  }

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      Row() {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#4e6ef2')

      // ===== 加载进度条 =====
      if (this.isLoading) {
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .color('#4e6ef2')
      }

      // ===== 工具栏：前进 / 后退 / 刷新 / 推送通知 =====
      Row({ space: 16 }) {
        Button('后退').fontSize(13).height(34)
          .onClick(() => {
            try { this.controller.backward(); } catch (e) {}
          })
        Button('前进').fontSize(13).height(34)
          .onClick(() => {
            try { this.controller.forward(); } catch (e) {}
          })
        Button('刷新').fontSize(13).height(34)
          .onClick(() => {
            this.isLoading = true;
            this.loadError = false;
            try { this.controller.refresh(); } catch (e) {}
          })
        Button('推送通知').fontSize(13).height(34)
          .backgroundColor('#ff9a2e')
          .onClick(() => {
            this.bridge?.pushNotification('原生侧推送：现在是 ' + new Date().toLocaleTimeString());
          })
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#f2f4f7')

      // ===== Web 区域（Stack 叠加载入/失败遮罩） =====
      Stack({ alignContent: Alignment.Center }) {
        Web({ src: $rawfile('message_board.html'), controller: this.controller })
          .javaScriptProxy({
            object: this.bridge as object,
            name: 'nativeBridge',
            methodList: ['submitMessage', 'showToast', 'clearAll', 'onPageReady'],
            controller: this.controller
          })
          .onProgressChange((event) => {
            this.progress = event.newProgress;
          })
          .onTitleReceive((event) => {
            if (event.title) {
              this.title = event.title;
            }
          })
          .onPageEnd(() => {
            this.isLoading = false;
            this.progress = 100;
            // 页面加载完成，回传历史留言
            this.bridge?.sendHistory();
          })
          .onErrorReceive((event) => {
            this.isLoading = false;
            this.loadError = true;
          })
          .width('100%')
          .layoutWeight(1)

        // 加载中遮罩
        if (this.isLoading && !this.loadError) {
          Column() {
            LoadingProgress().width(50).height(50).color('#4e6ef2')
            Text('页面加载中...').fontSize(14).margin({ top: 12 }).fontColor('#4e5969')
          }
          .width('100%').height('100%')
          .backgroundColor('#ffffff')
          .justifyContent(FlexAlign.Center)
        }

        // 加载失败遮罩
        if (this.loadError) {
          Column() {
            Text('😞').fontSize(48)
            Text('页面加载失败').fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 8 })
            Text('请检查 rawfile 资源后重试').fontSize(13).fontColor('#86909c').margin({ top: 6 })
            Button('重新加载').margin({ top: 16 }).height(38)
              .onClick(() => {
                this.loadError = false;
                this.isLoading = true;
                try { this.controller.refresh(); } catch (e) {}
              })
          }
          .width('100%').height('100%')
          .backgroundColor('#ffffff')
          .justifyContent(FlexAlign.Center)
        }
      }
      .layoutWeight(1)
      .width('100%')

      // ===== 底部返回按钮 =====
      Button('返回任务列表')
        .width('70%')
        .height(44)
        .margin({ top: 10, bottom: 10 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f4f7')
  }
}
