import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
class WeatherCondition {
  String _imgStr =kSummerImg;
  var _waterColor = kColorSummer;

  String getImageOfWeather()=>_imgStr;
  MaterialColor getColorOfWeather()=> _waterColor;

  void setConditionOfWeather(int temperature){
    if(temperature> 25 || temperature==null)
    {
      _imgStr = kSummerImg;
      _waterColor= kColorSummer;
    }
    else if (temperature > 17)
    {
      _imgStr = kSpringImg;
      _waterColor= kColorSummer;
    }
    else if(temperature > 5)
      {
        _imgStr = kAutumnImg;
        _waterColor= kColorWinter;
      }
    else
      {
      _imgStr = kWinterImg;
      _waterColor= kColorWinter;
    }
  }


}

