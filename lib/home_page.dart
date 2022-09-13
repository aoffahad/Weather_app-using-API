import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? positon;

  var lat;
  var lon;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    positon = await Geolocator.getCurrentPosition();
    lat = positon!.latitude;
    lon = positon!.longitude;
    print("latitude : ${lat},longitude: ${lon}");
    fetchWeatherData();
  }

  Map<String, dynamic>? mapOfWeather;
  Map<String, dynamic>? mapOfForecast;

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=906c0c77ba8058de5f2455853703dc3e";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=906c0c77ba8058de5f2455853703dc3e";
    var weatherResponse = await http.get(Uri.parse(weatherApi));
    var forecastResponse = await http.get(Uri.parse(forecastApi));
    print(weatherResponse.body);
    setState(() {
      mapOfWeather =
          Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
      mapOfForecast =
          Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    // var celsius = ((mapOfWeather!["main"]["temp"]) - 273.15);
   var celsius = ((mapOfWeather!["main"]["temp"])-273.15);
    return SafeArea(
      child: mapOfWeather == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              backgroundColor: Color.fromARGB(255, 229, 229, 229),
              body: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 500,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(40),
                          ),
                          color: Colors.blueGrey,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Text(
                                "${mapOfWeather!["name"]}",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  Jiffy(DateTime.now())
                                      .format("MMM do yy, h:mm"),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200)),
                              SizedBox(
                                height: 10,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  mapOfWeather!["main"]["feels_like"] ==
                                          "clear sky"
                                      ? "https://cdn-icons-png.flaticon.com/128/869/869869.png"
                                      : mapOfWeather!["main"]["feels_like"] ==
                                              "rainy"
                                          ? "https://cdn-icons-png.flaticon.com/128/2832/2832093.png"
                                          : mapOfWeather!["main"]
                                                      ["feels_like"] ==
                                                  "cloudy"
                                              ? "https://cdn-icons-png.flaticon.com/128/3093/3093390.png"
                                              : "https://cdn-icons-png.flaticon.com/128/869/869869.png",
                                  height:
                                      MediaQuery.of(context).size.height * .20,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                               
                              Text("${celsius.toInt()}°c",
                                  style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                "${mapOfWeather!["weather"][0]["description"]}",
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                " Humidity: ${mapOfWeather!["main"]["humidity"]} Pressure : ${mapOfWeather!["main"]["pressure"]}",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "🌄 Sunrise: ${Jiffy(DateTime.fromMillisecondsSinceEpoch(mapOfWeather!["sys"]["sunrise"] * 1000)).format("h:mm a")}  , 🌇Sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(mapOfWeather!["sys"]["sunset"] * 1000)).format("h:mm a")}",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height:10),
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: mapOfForecast!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: MediaQuery.of(context).size.width * .4,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white54),
                              margin: EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${Jiffy("${mapOfForecast!["list"][index]["dt_txt"]}").format("EEE h:mm")}",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  ClipRRect(
                                    //borderRadius:BorderRadius.circular(20),
                                    child: Image.network(
                                      mapOfWeather!["main"]["feels_like"] ==
                                              "clear sky"
                                          ? "https://cdn-icons-png.flaticon.com/128/869/869869.png"
                                          : mapOfWeather!["main"]
                                                      ["feels_like"] ==
                                                  "rainy"
                                              ? "https://cdn-icons-png.flaticon.com/128/2832/2832093.png"
                                              : mapOfWeather!["main"]
                                                          ["feels_like"] ==
                                                      "cloudy"
                                                  ? "https://cdn-icons-png.flaticon.com/128/3093/3093390.png"
                                                  : "https://cdn-icons-png.flaticon.com/128/7865/7865939.png",
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .20,
                                    ),
                                  ),
                                  Text(
                                    "${mapOfWeather!["weather"][0]["description"]}",
                                  ),
                                 
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
