@Component
export struct BusinessCardItem {
  // 旧版组件，使用 @Prop 接收父组件传入参数
  @Prop name: string = ""
  @Prop studentId: string = ""
  @Prop major: string = ""
  @Prop email: string = ""

  build() {
    Column() {
      Text(this.name)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
      Text(this.studentId)
        .fontSize(18)
        .margin({top:4})
      Text(this.major)
        .fontSize(16)
        .fontColor("#666666")
        .margin({top:8})
      Text(this.email)
        .fontSize(14)
        .fontColor("#888888")
        .margin({top:12})
    }
    .width("90%")
    .padding(24)
    .borderRadius(16)
    .backgroundColor("#FFFFFF")
    .shadow({radius:8, color:"#00000015", offsetX:2, offsetY:2})
  }
}
