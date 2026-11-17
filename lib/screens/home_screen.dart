import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController cityController = TextEditingController();
  final WeatherService weatherService = WeatherService();

  Map<String, dynamic>? weatherData;
  List<dynamic> forecastData = [];

  bool isLoading = false;
  String errorMessage = '';

  Future<void> searchWeather() async {
    final city = cityController.text.trim();

    if (city.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a city name';
        weatherData = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final weather = await weatherService.getWeather(city);

      List<dynamic> forecast = [];

      try {
        forecast = await weatherService.getForecast(city);
      } catch (_) {
        forecast = [];
      }

      if (!mounted) return;

      setState(() {
        weatherData = weather;
        forecastData = forecast;
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        weatherData = null;
        forecastData = [];
        isLoading = false;
        errorMessage = 'City not found. Please try again.';
      });
    }
  }

  String getWeatherIcon(String condition) {
    final value = condition.toLowerCase();

    if (value.contains('thunder')) {
      return '⛈️';
    } else if (value.contains('rain')) {
      return '🌧️';
    } else if (value.contains('drizzle')) {
      return '🌦️';
    } else if (value.contains('snow')) {
      return '❄️';
    } else if (value.contains('cloud')) {
      return '⛅';
    } else if (value.contains('clear')) {
      return '☀️';
    }

    return '🌤️';
  }

  String getDayName(String dateTime) {
    final date = DateTime.parse(dateTime);

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return days[date.weekday - 1];
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFE85D8E), size: 27),
            const SizedBox(height: 9),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget forecastCard(dynamic item) {
    final condition = item['weather'][0]['main'].toString();

    return Container(
      width: 95,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.pink.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getDayName(item['dt_txt'].toString()),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 8),
          Text(getWeatherIcon(condition), style: const TextStyle(fontSize: 31)),
          const SizedBox(height: 7),
          Text(
            '${(item['main']['temp'] as num).round()}°C',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE85D8E),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFFC6D9),
        title: const Text(
          'Weather App',
          style: TextStyle(
            color: Color(0xFF4A3040),
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
          child: Column(
            children: [
              // Search box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: cityController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => searchWeather(),
                  decoration: InputDecoration(
                    hintText: 'Enter city name',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFE85D8E),
                    ),
                    suffixIcon: IconButton(
                      onPressed: searchWeather,
                      icon: const Icon(Icons.search, color: Color(0xFFE85D8E)),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 17),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: CircularProgressIndicator(color: Color(0xFFE85D8E)),
                ),

              if (errorMessage.isNotEmpty && !isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFD84B78),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              if (weatherData != null && !isLoading) ...[
                const SizedBox(height: 5),

                // City
                Text(
                  '${weatherData!['name']}, ${weatherData!['sys']['country']}',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3040),
                  ),
                ),

                const SizedBox(height: 12),

                // Weather icon
                Text(
                  getWeatherIcon(weatherData!['weather'][0]['main'].toString()),
                  style: const TextStyle(fontSize: 72),
                ),

                // Temperature
                Text(
                  '${(weatherData!['main']['temp'] as num).round()}°C',
                  style: const TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF4A3040),
                  ),
                ),

                const SizedBox(height: 4),

                // Condition
                Text(
                  weatherData!['weather'][0]['description']
                      .toString()
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF765464),
                  ),
                ),

                const SizedBox(height: 22),

                // First row
                Row(
                  children: [
                    infoCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Humidity',
                      value: '${weatherData!['main']['humidity']}%',
                    ),
                    infoCard(
                      icon: Icons.air,
                      title: 'Wind',
                      value: '${weatherData!['wind']['speed']} m/s',
                    ),
                  ],
                ),

                // Second row
                Row(
                  children: [
                    infoCard(
                      icon: Icons.speed,
                      title: 'Pressure',
                      value: '${weatherData!['main']['pressure']} hPa',
                    ),
                    infoCard(
                      icon: Icons.thermostat_outlined,
                      title: 'Feels Like',
                      value:
                          '${(weatherData!['main']['feels_like'] as num).round()}°C',
                    ),
                  ],
                ),

                if (forecastData.isNotEmpty) ...[
                  const SizedBox(height: 22),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '5 Days Forecast',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3040),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 135,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: forecastData.length > 5
                          ? 5
                          : forecastData.length,
                      itemBuilder: (context, index) {
                        return forecastCard(forecastData[index]);
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }
}
