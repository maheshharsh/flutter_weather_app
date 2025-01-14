// paint the code on canvas with own rendering system and the system is skiyagraphic is currently replace by Impeller rendering backend

import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:weather_app/pages/additional_info_item.dart';
import 'package:weather_app/pages/hourly_forcast_item.dart';
import 'package:weather_app/pages/secrets.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
 late Future<Map<String, dynamic>> weather;
  // Api call with http
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'India, raj';
      String apiUrl =
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey&units=metric'; // Add units=metric for Celsius
      final response = await http.get(Uri.parse(apiUrl));
      final data = jsonDecode(response.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error ${response.statusCode}';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            setState(() {
              weather = getCurrentWeather();
            });
          }, icon: Icon(Icons.refresh))
        ],
      ),

      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];

          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];

          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // placeholder widget is use for ui space example
              // Main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('$currentTemp K', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                            SizedBox(height: 16,),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Snow' || currentSky == 'Rain' ?
                              Icons.cloud : Icons.sunny, size: 64,),
                            SizedBox(height: 16,),
                            Text(currentSky, style: TextStyle(fontSize: 20),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // weather forecast app
              Text('Hourly Forecast', style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),),
              const SizedBox(height: 8,),

               // in one time it generate all the 50 card it takes time and from that the app speed is readuse
              //  SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       for (int i = 0; i < 39; i++)
              //         HourlyForecastItem(
              //           time: data['list'][i + 1]['dt'].toString(),
              //           icon: data['list'][i + 1]['weather'][0]['main'] == 'Clouds' || data['list'][i + 1]['weather'][0]['main'] == "Rain" ? Icons.cloud : Icons.sunny,
              //           temperture: data['list'][i + 1]['main']['temp'].toString(),),
              //     ],
              //   ),
              // ),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast =  data['list'][index + 1];
                      final hourlySky = hourlyForecast['weather'][0]['main'];
                      final time = DateTime.parse(hourlyForecast['dt_txt'].toString());
                      return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        icon: hourlySky == 'Clouds' || hourlySky == "Rain" || hourlySky == 'Snow' ? Icons.cloud : Icons.sunny,
                        temperture: hourlyForecast['main']['temp'].toString(),
                      );
                    }
                ),
              ),
              const SizedBox(height: 20,),
              Text('Additional Information', style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),),
              const SizedBox(height: 20,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(icon: Icons.water_drop, atmosphere: 'Humidity', text: currentHumidity.toString()),
                  AdditionalInfoItem(icon: Icons.air, atmosphere: 'Wind Speed', text: currentWindSpeed.toString()),
                  AdditionalInfoItem(icon: Icons.beach_access, atmosphere: 'Pressure',  text: currentPressure.toString()),
                ],
              )
            ],
          ),
        );
        },
      ),
    );
  }
}


