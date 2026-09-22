import router from '@ohos.router';

@Entry
@Component
struct TaskList {
  build() {
    Column(){
      Text("任务列表")
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({bottom:40})

      Button("任务1：上课")
        .width("80%")
        .height(48)
        .margin({bottom:15})
        .onClick(()=>{
          router.pushUrl({url:"pages/Task1Detail"})
        })
      Button("任务2：下课")
        .width("80%")
        .height(48)
        .margin({bottom:15})

      Button("返回首页")
        .width("70%")
        .height(50)
        .margin({top:80})
        .onClick(()=>{
          router.back()
        })
       Button("电子名片模块")
         .width("70%")
         .height(50)
         .margin({top:70})
        .onClick(()=>{
          router.pushUrl({url:"pages/BusinessCard"})
        })
      Button("有声计算器")
        .width("70%")
        .height(50)
        .margin({top:20})
        .onClick(()=>{
          router.pushUrl({url:"pages/Calculator"})
        })



    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
