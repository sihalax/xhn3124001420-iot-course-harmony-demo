import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = "物联网课程作业";

  build() {
    Column() {
      Text(this.message)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom:30 })

      Text("姓名：谢瀚楠")
        .fontSize(22)
        .margin({bottom:10})
      Text("学号：3124001420")
        .fontSize(22)
        .margin({bottom:60})

      Button("进入任务列表")
        .fontSize(20)
        .width("70%")
        .height(50)
        .onClick(()=>{
          router.pushUrl({url:"pages/TaskList"})
        })


      Button("进入天气预报页面")
        .width("90%")
        .margin({top:20})
        .onClick(()=>{
          router.pushUrl({url:"pages/Weatherpages"})
        })


    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
