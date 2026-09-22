import http from '@ohos.net.http';
import util from '@ohos.util';

// ========== 数据模型 ==========
export class WeatherInfo {
  temp: string = "";
  text: string = "";
  humidity: string = "";
  wind: string = "";
}

export class ForecastItem {
  date: string = "";
  tempMin: string = "";
  tempMax: string = "";
  text: string = "";
}

export class WeatherResult {
  now: WeatherInfo = new WeatherInfo();
  forecast: ForecastItem[] = [];
}

// ========== 和风天气返回数据结构 ==========
interface QWeatherNowInner {
  temp: string;
  text: string;
  humidity: string;
  windDir: string;
  windScale: string;
}

interface QWeatherNowResp {
  code: string;
  now: QWeatherNowInner;
}

interface QWeatherDailyItem {
  fxDate: string;
  tempMin: string;
  tempMax: string;
  textDay: string;
}

interface QWeatherForecastResp {
  code: string;
  daily: QWeatherDailyItem[];
}

// ========== 天气服务层（网络请求独立封装） ==========
export class WeatherService {
  private static readonly API_KEY: string = "43cc26e764fa4948afd3619465f06b83";
  private static readonly BASE_URL: string = "https://n33fc3xx9p.re.qweatherapi.com/v7";

  // 把HTTP返回结果解码成字符串
  private static decodeResult(result: Object): string {
    // 如果已经是字符串，直接返回
    if (typeof result === "string") {
      return (result as string).replace(/^\uFEFF/, "").trim();
    }
    // 如果是ArrayBuffer，用TextDecoder解码
    if (result instanceof ArrayBuffer) {
      const uint8Array = new Uint8Array(result as ArrayBuffer);
      const decoder = util.TextDecoder.create("utf-8");
      return decoder.decodeToString(uint8Array).replace(/^\uFEFF/, "").trim();
    }
    // 其他类型转字符串
    return String(result).replace(/^\uFEFF/, "").trim();
  }

  static async fetchWeather(cityId: string): Promise<WeatherResult> {
    const httpRequest = http.createHttp();
    try {
      // 1. 请求实时天气
      const nowUrl: string =
        WeatherService.BASE_URL + "/weather/now?location=" + cityId + "&key=" + WeatherService.API_KEY;
      const nowRes = await httpRequest.request(nowUrl, {
        method: http.RequestMethod.GET
      });

      if (nowRes.responseCode !== 200) {
        throw new Error("HTTP错误码: " + nowRes.responseCode);
      }

      const nowStr: string = WeatherService.decodeResult(nowRes.result);
      console.info("实时天气返回前300字: " + nowStr.substring(0, Math.min(300, nowStr.length)));
      const nowData: QWeatherNowResp = JSON.parse(nowStr) as QWeatherNowResp;

      if (nowData.code !== "200") {
        throw new Error("接口错误码: " + nowData.code);
      }

      // 2. 请求3天预报
      const forecastUrl: string =
        WeatherService.BASE_URL + "/weather/3d?location=" + cityId + "&key=" + WeatherService.API_KEY;
      const forecastRes = await httpRequest.request(forecastUrl, {
        method: http.RequestMethod.GET
      });
      const forecastStr: string = WeatherService.decodeResult(forecastRes.result);
      const forecastData: QWeatherForecastResp = JSON.parse(forecastStr) as QWeatherForecastResp;

      // 3. 组装结果
      const result = new WeatherResult();
      result.now.temp = nowData.now.temp;
      result.now.text = nowData.now.text;
      result.now.humidity = nowData.now.humidity;
      result.now.wind = nowData.now.windDir + " " + nowData.now.windScale + "级";

      for (let i = 0; i < forecastData.daily.length; i++) {
        const item = forecastData.daily[i];
        const forecastItem = new ForecastItem();
        forecastItem.date = item.fxDate;
        forecastItem.tempMin = item.tempMin;
        forecastItem.tempMax = item.tempMax;
        forecastItem.text = item.textDay;
        result.forecast.push(forecastItem);
      }

      httpRequest.destroy();
      return result;
    } catch (err) {
      httpRequest.destroy();
      if (err instanceof Error) {
        throw err;
      } else {
        throw new Error("网络请求异常");
      }
    }
  }
}
