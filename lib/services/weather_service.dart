import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "5d0d5710624c854181ffbc960a7663b8";

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather"
      "?q=${Uri.encodeComponent(city)}"
      "&appid=$apiKey"
      "&units=metric",
    );
 
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); 
    }

    throw Exception("Weather request failed: ${response.statusCode}");
  }

  Future<List<dynamic>> getForecast(String city) async {
    final url = Uri.parse(  
      "https://api.openweathermap.org/data/2.5/forecast"
      "?q=${Uri.encodeComponent(city)}"
      "&appid=$apiKey"
      "&units=metric",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["list"] as List<dynamic>;
    }

    throw Exception("Forecast request failed: ${response.statusCode}");
  }
}
