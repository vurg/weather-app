import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'LocationManager.dart'; // Import the LocationManager class

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<dynamic> forecastData = [];
  bool isLoading = true;
  String error = '';

  Future<void> fetchForecastData() async {
    LocationManager locationManager = LocationManager();

    try {
      final location = await locationManager.getCurrentLocation();

      if (location != null) {
        const apiKey = 'INSERT API KEY HERE';
        final latitude = location.latitude;
        final longitude = location.longitude;
        const units = 'metric';
        final apiUrl =
            'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$units&appid=$apiKey';

        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          setState(() {
            forecastData = json.decode(response.body)['list'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            error = 'Failed to load forecast data';
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
    fetchForecastData();
  }

  // Extract the forecast item formatting logic into a separate method
  Widget buildForecastItem(Map<String, dynamic> forecast) {
    final timestamp =
        DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
    final formattedDate = DateFormat.yMMMMEEEEd().format(timestamp);
    final formattedTime = DateFormat('hh:mm a').format(timestamp);

    final temperature = forecast['main']['temp'];
    final weatherCondition = forecast['weather'][0]['description'];
    final iconCode = forecast['weather'][0]['icon'];

    return ListTile(
      contentPadding: EdgeInsets.all(10),
      leading: Image.asset(
        'images/$iconCode.png',
        width: 50,
        height: 50,
      ),
      title: Text(
        '$formattedDate - $formattedTime',
        style: const TextStyle(fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${temperature.toStringAsFixed(1)} °C',
            style: const TextStyle(fontSize: 17),
          ),
          Text(
            weatherCondition,
            style: const TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (error.isNotEmpty) {
      return Center(child: Text(error));
    } else {
      return ListView.builder(
        itemCount: forecastData.length,
        itemBuilder: (context, index) {
          final forecast = forecastData[index];
          return buildForecastItem(forecast); // Use the extracted method
        },
      );
    }
  }
}
