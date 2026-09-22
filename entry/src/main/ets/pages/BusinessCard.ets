import { BusinessCardItem } from "../components/BusinessCardItem"
import router from '@ohos.router';
@Entry
@Component
struct BusinessCard {
  build() {
    Column() {
      BusinessCardItem({
        name: "谢瀚楠",
        studentId: "3124001420",
        major: "物联网工程",
        email: "3124001420@xxx.com"
      })

      Button("返回任务列表")
        .width("80%")
        .margin({top:30})
        .onClick(()=>{
          router.back()
        })
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F5F7FA")
  }
}
