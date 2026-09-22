import router from '@ohos.router';

@Entry
@Component
struct Calculator {
  @State displayText: string = "";

  // 预留语音播报接口，日志打印替代TTS
  speakContent(text: string): void {
    console.info("语音播报内容：", text);
  }

  handleButtonClick(val: string): void {
    if(val === "+") this.speakContent("加");
    else if(val === "-") this.speakContent("减");
    else if(val === "*") this.speakContent("乘");
    else if(val === "/") this.speakContent("除以");
    else if(val === "C") this.speakContent("清除");
    else if(val === "=") this.speakContent("等于");
    else this.speakContent(val);

    if (val === "C") {
      this.displayText = "";
    } else if (val === "=") {
      try {
        const expr = this.displayText;
        let opIndex = -1;
        let op = "";
        // 从下标1开始查找运算符，跳过最开头的负号
        for(let i = 1; i < expr.length; i++){
          const c = expr[i];
          if(c === '+' || c === '-'){
            opIndex = i;
            op = c;
            break;
          }
        }
        if(opIndex === -1){
          for(let i = 1; i < expr.length; i++){
            const c = expr[i];
            if(c === '*' || c === '/'){
              opIndex = i;
              op = c;
              break;
            }
          }
        }
        // 校验运算符位置合法性
        if(opIndex <=0 || opIndex >= expr.length-1){
          this.displayText = "Error";
          this.speakContent("计算错误");
          return;
        }
        const left = parseFloat(expr.substring(0, opIndex));
        const right = parseFloat(expr.substring(opIndex+1));
        if(isNaN(left) || isNaN(right)){
          this.displayText = "Error";
          this.speakContent("计算错误");
          return;
        }
        let result:number = 0;
        switch(op){
          case "+": result = left + right; break;
          case "-": result = left - right; break;
          case "*": result = left * right; break;
          case "/":
            if(right === 0){
              this.displayText = "Error";
              this.speakContent("除零错误");
              return;
            }
            result = left / right;
            break;
        }
        this.displayText = result.toString();
        this.speakContent(`结果等于${result}`);
      } catch(err) {
        this.displayText = "Error";
        this.speakContent("计算错误");
      }
    } else {
      this.displayText += val;
    }
  }

  build() {
    Column() {
      Text(this.displayText)
        .fontSize(36)
        .width("90%")
        .height(80)
        .textAlign(TextAlign.End)
        .margin({top:20, bottom:20})
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Grid() {
        GridItem() { Button("7").onClick(() => this.handleButtonClick("7")) }
        GridItem() { Button("8").onClick(() => this.handleButtonClick("8")) }
        GridItem() { Button("9").onClick(() => this.handleButtonClick("9")) }
        GridItem() { Button("/").onClick(() => this.handleButtonClick("/")) }

        GridItem() { Button("4").onClick(() => this.handleButtonClick("4")) }
        GridItem() { Button("5").onClick(() => this.handleButtonClick("5")) }
        GridItem() { Button("6").onClick(() => this.handleButtonClick("6")) }
        GridItem() { Button("*").onClick(() => this.handleButtonClick("*")) }

        GridItem() { Button("1").onClick(() => this.handleButtonClick("1")) }
        GridItem() { Button("2").onClick(() => this.handleButtonClick("2")) }
        GridItem() { Button("3").onClick(() => this.handleButtonClick("3")) }
        GridItem() { Button("-").onClick(() => this.handleButtonClick("-")) }

        GridItem() { Button("0").onClick(() => this.handleButtonClick("0")) }
        GridItem() { Button("C").onClick(() => this.handleButtonClick("C")) }
        GridItem() { Button("=").onClick(() => this.handleButtonClick("=")) }
        GridItem() { Button("+").onClick(() => this.handleButtonClick("+")) }
      }
      .columnsTemplate("1fr 1fr 1fr 1fr")
      .columnsGap(12)
      .rowsGap(12)
      .width("90%")

      Button("返回任务列表")
        .margin({ top: 30 })
        .onClick(() => {
          router.back();
        })
    }
    .width("100%")
    .height("100%")
    .padding(20)
  }
}
