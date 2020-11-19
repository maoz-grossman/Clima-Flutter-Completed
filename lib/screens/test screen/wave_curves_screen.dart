import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';
import 'package:clima/screens/test screen/weather_condition.dart';

//set this class to home of material app in main.dart
class MyAnimatedWaveCurves extends StatefulWidget{
  final locationWeather;
  MyAnimatedWaveCurves({this.locationWeather});
  @override
  State<StatefulWidget> createState() {
    return _MyAnimatedWavesCurves();
  }
}

class _MyAnimatedWavesCurves extends State<MyAnimatedWaveCurves> with SingleTickerProviderStateMixin {
  //use "with SingleThickerProviderStateMixin" at last of class declaration
  //where you have to pass "vsync" argument, add this

  Animation<double> animation;
  AnimationController _controller; //controller for animation
  WeatherModel _weather = WeatherModel();
  WeatherCondition _wc = WeatherCondition();
  MaterialColor _themeCurveColor;
  String _imgName;
  int _temperature;
  String _weatherIcon;
  String _cityName;
  String _weatherMessage;
  String _newCityName ;



  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);

    _controller = AnimationController(duration: Duration(seconds: 4), vsync: this);
    _controller.repeat();
    //we set animation duration, and repeat for infinity
    animation = Tween<double>(begin: -400, end: 0).animate(_controller);
    //we have set begin to -600 and end to 0, it will provide the value for
    //left or right position for Positioned() widget to creat movement from left to right
    animation.addListener(() {
      setState(() {}); //update UI on every animation value update
    });
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        _temperature = 0;
        _weatherIcon = 'Error';
        _weatherMessage = 'Unable to get weather data';
        _cityName = '';
        _wc = WeatherCondition();
        _themeCurveColor = _wc.getColorOfWeather();
        _imgName = _wc.getImageOfWeather();
        return;
      }
      double temp = weatherData['main']['temp'];
      _temperature = temp.toInt();
      var condition = weatherData['weather'][0]['id'];
      _weatherIcon = _weather.getWeatherIcon(condition);
      _weatherMessage = _weather.getMessage(_temperature);
      _cityName = weatherData['name'];
      _wc.setConditionOfWeather(_temperature);
      _themeCurveColor = _wc.getColorOfWeather();
      _imgName=_wc.getImageOfWeather();
    });
  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); //destory anmiation to free memory on last
  }


  @override
  Widget build(BuildContext context) {
    double screenRatio =MediaQuery.of(context).size.height*0.35;
    double helfOfScreen= MediaQuery.of(context).size.height*0.48;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      /*appBar: AppBar(
          title:Text("Wave Clipper Animation"),
          backgroundColor: Colors.redAccent
      ),*/
      body: Container(
        //constraints: BoxConstraints.expand(),
        child: Stack( //stack helps to overlaps widgets
            children: [
              SafeArea(
                child: Container(
                  height: helfOfScreen,
                  alignment: Alignment.topCenter,
                  child: Image.asset(_imgName,
                      fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                //helps to position widget where ever we want
                bottom: screenRatio, //position at the bottom
                right: animation.value, //value of right from animation controller
                child: ClipPath(
                  clipper: MyWaveClipper(), //applying our custom clipper
                  child: Opacity(
                    opacity: 0.5,
                    child: Container(
                      color: _themeCurveColor,
                      width: 900,
                      height: 200,
                    ),
                  ),
                ),
              ),

              Positioned( //helps to position widget where ever we want
                bottom:screenRatio, //position at the bottom
                left: animation.value, //value of left from animation controller
                child: ClipPath(
                  clipper: MyWaveClipper(), //applying our custom clipper
                  child: Opacity(
                    opacity: 1,
                    child: Container(
                      color: _themeCurveColor,
                      width: 900,
                      height: 200,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    height:helfOfScreen ,
                    color: _themeCurveColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom:25),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '$_temperature°',
                            style: kTempTextStyle,
                          ),
                          Text(
                            _weatherIcon,
                            style: kConditionTextStyle,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left:15),
                      child: Text(
                        '$_weatherMessage in $_cityName',
                        //textAlign: TextAlign.right,
                        style: kMessageTextStyle,
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          /*
                          Align(
                            alignment: Alignment.topLeft,
                            child: FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 50.0,
                              ),
                            ),
                          ),
                           */
                          Container(
                            padding: EdgeInsets.all(20.0),
                            child: TextField(
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: kTextFieldInputDecoration,
                              onChanged: (value) {
                                _newCityName = value;
                              },
                            ),
                          ),
                          FlatButton(
                            onPressed: () async{
                              String typedName = _newCityName;
                              if (typedName != null) {
                                print(typedName);
                                var weatherData =
                                    await _weather.getCityWeather(typedName);
                                updateUI(weatherData);
                              }
                            },
                            child: Text(
                              'Get Weather',
                              style: kButtonTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ]),
      ),
    );
  }
}


//our custom clipper with Path class
class MyWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, 40.0);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 40.0);

    //see my previous post to understand about Bezier Curve waves
    // https://www.hellohpc.com/flutter-how-to-make-bezier-curve-waves-using-custom-clippath/

    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            0.0,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      } else {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            size.height - 120,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      }
    }

    path.lineTo(0.0, 40.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}