import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/weather_screen/additional_info_card.dart';
import 'package:weather_app/weather_screen/hourly_forcast.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London,uk';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey&units=metric',
        ),
      );
      final data = jsonDecode(res.body);

      // if (res.statusCode == 200)
      if (int.parse(data['cod']) != 200) {
        throw "An unexpected error occured";
      }

      // print(data);
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data!;

          // current weather data
          final currentWeatherData = data['list'][0];

          // main card
          final currentTemp = currentWeatherData['main']['temp'];
          final currentDayLighting = currentWeatherData['weather'][0]['main'];
          final weatherIcons = {
            'Clouds': Icons.cloud,
            'Rain': Icons.grain,
            'Sunny': Icons.sunny,
          };

          // hourly forecast
          List<Map<String, dynamic>> selectedForcast = data['list']
              .sublist(0, 10)
              .map<Map<String, dynamic>>((weatherData) {
            DateTime dateTime =
                DateTime.fromMillisecondsSinceEpoch(weatherData['dt'] * 1000)
                    .toLocal();
            return {
              'time': DateFormat.j().format(dateTime),
              'icon': weatherIcons[weatherData['weather'][0]['main']] ??
                  Icons.question_mark,
              'temperature': "${weatherData['main']['temp'].toString()} °C",
            };
          }).toList();

          // additional info
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentPressure = currentWeatherData['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main card
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
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp °C',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Icon(
                                weatherIcons[currentDayLighting] ??
                                    Icons.question_mark,
                                size: 64,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentDayLighting,
                                style: const TextStyle(fontSize: 20),
                              )
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
                // weather forcast cards
                const Text("Hourly Forecast",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                HourlyForcastList(hourlyForcastList: selectedForcast),
                const SizedBox(
                  height: 20,
                ),
                // additional information
                const Text("Additional Information",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoCard(
                      title: 'Humidity',
                      icon: Icons.water_drop,
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfoCard(
                      title: 'Wind speed',
                      icon: Icons.air,
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalInfoCard(
                      title: 'Pressure',
                      icon: Icons.beach_access,
                      value: currentPressure.toString(),
                    ),
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
