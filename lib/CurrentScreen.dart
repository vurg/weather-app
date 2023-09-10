import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'LocationManager.dart';

class CurrentScreen extends StatefulWidget {
  const CurrentScreen({super.key});

  @override
  _CurrentScreenState createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen> {
  Map<String, dynamic> weatherData = {};
  bool isLoading = true;
  String error = '';

  Future<void> fetchWeatherData() async {
    LocationManager locationManager = LocationManager();

    try {
      final location = await locationManager.getCurrentLocation();

      if (location != null) {
        const apiKey = 'INSERT API KEY HERE';
        final latitude = location.latitude;
        final longitude = location.longitude;
        const units = 'metric';
        final apiUrl =
            'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$units&appid=$apiKey';

        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          setState(() {
            weatherData = json.decode(response.body);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            error = 'Failed to load weather data';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          error = 'Location permission not granted';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'An error occurred while fetching data';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  // Extract the weather item formatting logic into a separate method
  Widget buildWeatherItem() {
    final city = weatherData['name'] ?? 'N/A';
    final country = weatherData['sys']['country'] ?? 'N/A';
    final weatherCondition = weatherData['weather'][0]['description'] ?? 'N/A';
    final temperature =
        weatherData['main']['temp']?.toStringAsFixed(1) ?? 'N/A';

    // Format the current date
    final formattedDate = DateFormat.yMMMMEEEEd().format(DateTime.now());

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (weatherData['weather'] != null &&
            weatherData['weather'][0]['icon'] != null)
          Image.asset(
            'images/${weatherData['weather'][0]['icon']}.png',
            width: 150,
            height: 150,
          ),
        Text(
          //City and Country
          '$city, $country',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 14),
        Text(
          // Current Date
          formattedDate,
          style: const TextStyle(fontSize: 17),
        ),
        const SizedBox(height: 5),
        Text(
          // Weather Condition
          weatherCondition,
          style: const TextStyle(fontSize: 17),
        ),
        const SizedBox(height: 18),
        Text(
          // Temperature
          '$temperature °C',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (error.isNotEmpty) {
      return Center(child: Text(error));
    } else {
      return Center(
        child: buildWeatherItem(), // Use the extracted method
      );
    }
  }
}
