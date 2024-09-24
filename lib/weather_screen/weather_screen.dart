import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/weather_screen/additional_info_card.dart';
import 'package:weather_app/weather_screen/hourly_forcast_card.dart';

import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temperature = 0;

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future getCurrentWeather() async {
    try {
      String cityName = 'London,uk';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);
      // if (res.statusCode == 200)
      if (int.parse(data['cod']) != 200) {
        throw "An unexpected error occured";
      }

      setState(() {
        temperature = data['list'][0]['main']['temp'];
      });

      print(res.body);
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
                print('refresh');
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: Padding(
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
                            '$temperature K',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.cloud,
                            size: 64,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Rain',
                            style: TextStyle(fontSize: 20),
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
            const Text("Weather Forecast",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  HourlyForcastCard(
                    time: "09:00",
                    icon: Icons.cloud,
                    temperature: "25 dC",
                  ),
                  HourlyForcastCard(
                    time: "09:00",
                    icon: Icons.sunny,
                    temperature: "25 dC",
                  ),
                  HourlyForcastCard(
                    time: "09:00",
                    icon: Icons.cloud,
                    temperature: "25 dC",
                  ),
                  HourlyForcastCard(
                    time: "09:00",
                    icon: Icons.cloud,
                    temperature: "25 dC",
                  ),
                  HourlyForcastCard(
                    time: "09:00",
                    icon: Icons.cloud,
                    temperature: "25 dC",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // additional information
            const Text("Additional Information",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 8,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AdditionalInfoCard(
                  title: 'Humidity',
                  icon: Icons.water_drop,
                  value: '20%',
                ),
                AdditionalInfoCard(
                  title: 'Humidity',
                  icon: Icons.air,
                  value: '20%',
                ),
                AdditionalInfoCard(
                  title: 'Humidity',
                  icon: Icons.beach_access,
                  value: '20%',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
