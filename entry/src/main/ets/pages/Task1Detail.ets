import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Task1Detail {
  build() {
    Column() {
      Text("任务1详情页面")
        .fontSize(26).margin({bottom:30})

      Button("返回任务列表")
        .width("70%")
        .onClick(()=>{
          let uiContext = this.getUIContext();
          let router = uiContext.getRouter();
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
