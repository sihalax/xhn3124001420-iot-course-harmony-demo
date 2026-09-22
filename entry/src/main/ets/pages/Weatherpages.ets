import { WeatherService, WeatherInfo, ForecastItem } from '../common/weatherService';
import router from '@ohos.router';

// 省市数据模型
class ProvinceItem {
  name: string = "";
  cityList: CityItem[] = [];
}
class CityItem {
  name: string = "";
  cityId: string = "";
}

// 页面状态常量
const PAGE_IDLE: string = "idle";
const PAGE_LOADING: string = "loading";
const PAGE_SUCCESS: string = "success";
const PAGE_ERROR: string = "error";

@Entry
@Component
struct WeatherPage {
  @State provinceIndex: number = 0;
  @State cityIndex: number = 0;
  @State provinceList: ProvinceItem[] = [];
  @State provinceNameArr: string[] = [];
  @State cityNameArr: string[] = [];

  @State pageStatus: string = PAGE_IDLE;
  @State weatherData: WeatherInfo = new WeatherInfo();
  @State forecastList: ForecastItem[] = [];
  @State errorMsg: string = "";

  updateCityOptions(): void {
    if (this.provinceList.length > 0) {
      const selectedProvince: ProvinceItem = this.provinceList[this.provinceIndex];
      this.cityNameArr = [];
      for (let i = 0; i < selectedProvince.cityList.length; i++) {
        this.cityNameArr.push(selectedProvince.cityList[i].name);
      }
    }
  }

  aboutToAppear(): void {
    const gd = new ProvinceItem();
    gd.name = "广东省";
    const gz = new CityItem();
    gz.name = "广州市";
    gz.cityId = "101280101";
    const sz = new CityItem();
    sz.name = "深圳市";
    sz.cityId = "101280601";
    gd.cityList.push(gz);
    gd.cityList.push(sz);

    const bj = new ProvinceItem();
    bj.name = "北京市";
    const beijing = new CityItem();
    beijing.name = "北京市";
    beijing.cityId = "101010100";
    bj.cityList.push(beijing);

    this.provinceList.push(gd);
    this.provinceList.push(bj);

    this.provinceNameArr = [];
    for (let i = 0; i < this.provinceList.length; i++) {
      this.provinceNameArr.push(this.provinceList[i].name);
    }
    this.updateCityOptions();
  }

  // 切换省份：循环切换 0/1
  changeProvince(): void {
    if(this.provinceIndex === 0){
      this.provinceIndex = 1;
    }else{
      this.provinceIndex = 0;
    }
    this.cityIndex = 0;
    this.updateCityOptions();
  }

  // 切换城市：循环切换
  changeCity(): void {
    const selectedProvince: ProvinceItem = this.provinceList[this.provinceIndex];
    const maxCityIdx: number = selectedProvince.cityList.length - 1;
    if(this.cityIndex >= maxCityIdx){
      this.cityIndex = 0;
    }else{
      this.cityIndex += 1;
    }
  }

  async queryWeather(): Promise<void> {
    const selectedCity: CityItem = this.provinceList[this.provinceIndex].cityList[this.cityIndex];
    this.pageStatus = PAGE_LOADING;
    this.errorMsg = "";
    try {
      const res = await WeatherService.fetchWeather(selectedCity.cityId);
      this.weatherData = res.now;
      this.forecastList = res.forecast;
      this.pageStatus = PAGE_SUCCESS;
    } catch(err) {
      this.pageStatus = PAGE_ERROR;
      if(err instanceof Error){
        this.errorMsg = err.message;
      }else{
        this.errorMsg = "网络异常，请检查网络";
      }
    }
  }

  build() {
    Column() {
      Row() {
        Button("返回", {type:ButtonType.Normal})
          .onClick(()=>router.back())
        Text("天气预报查询").fontSize(24).layoutWeight(1).textAlign(TextAlign.Center)
      }.width("100%").padding(10)

      Row() {
        Button(`省份:${this.provinceNameArr[this.provinceIndex]}`)
          .layoutWeight(1)
          .onClick(()=>this.changeProvince())
        Button(`城市:${this.cityNameArr[this.cityIndex]}`)
          .layoutWeight(1)
          .onClick(()=>this.changeCity())
        Button("查询")
          .onClick(()=>this.queryWeather())
      }.width("100%").padding(10)

      if(this.pageStatus === PAGE_IDLE){
        Text("请选择省市，点击查询天气").fontSize(18).margin({top:50})
      }
      else if(this.pageStatus === PAGE_LOADING){
        Text("正在加载天气数据...").fontSize(18).margin({top:50})
      }
      else if(this.pageStatus === PAGE_ERROR){
        Column(){
          Text(`查询失败：${this.errorMsg}`).fontSize(18).fontColor(Color.Red)
          Button("重试").margin({top:10}).onClick(()=>this.queryWeather())
        }.margin({top:50})
      }
      else if(this.pageStatus === PAGE_SUCCESS){
        Column(){
          Text("实时天气").fontSize(22).fontWeight(FontWeight.Bold)
          Text(`温度：${this.weatherData.temp} ℃`).fontSize(18).margin({top:4})
          Text(`天气：${this.weatherData.text}`).fontSize(18).margin({top:4})
          Text(`湿度：${this.weatherData.humidity}`).fontSize(18).margin({top:4})
          Text(`风力：${this.weatherData.wind}`).fontSize(18).margin({top:4})
        }.width("90%").padding(15).border({width:1, color:Color.Gray}).borderRadius(12)

        Text("未来3天预报").fontSize(22).fontWeight(FontWeight.Bold).margin({top:20})
        List(){
          ForEach(this.forecastList, (item:ForecastItem)=>{
            ListItem(){
              Column(){
                Text(`日期：${item.date}`).fontSize(16)
                Text(`${item.text}  ${item.tempMin}~${item.tempMax}℃`).fontSize(16)
              }.width("100%").padding(10)
            }
          }, (item:ForecastItem)=>item.date)
        }.width("90%").height(200).margin({top:10})
      }
    }
    .width("100%")
    .padding(10)
  }
}
