import 'package:dio/dio.dart';

class WeatherService {
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY'; // Replace with actual API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  final Dio _dio = Dio();
  
  // Japanese cities with their coordinates
  static const Map<String, Map<String, double>> japaneseCities = {
    'Tokyo': {'lat': 35.6762, 'lon': 139.6503},
    'Osaka': {'lat': 34.6937, 'lon': 135.5023},
    'Kyoto': {'lat': 35.0116, 'lon': 135.7681},
    'Yokohama': {'lat': 35.4437, 'lon': 139.6380},
    'Nagoya': {'lat': 35.1815, 'lon': 136.9066},
    'Sapporo': {'lat': 43.0618, 'lon': 141.3545},
    'Kobe': {'lat': 34.6901, 'lon': 135.1955},
    'Fukuoka': {'lat': 33.5902, 'lon': 130.4017},
    'Kawasaki': {'lat': 35.5206, 'lon': 139.7172},
    'Hiroshima': {'lat': 34.3853, 'lon': 132.4553},
    'Sendai': {'lat': 38.2688, 'lon': 140.8721},
    'Chiba': {'lat': 35.6073, 'lon': 140.1065},
    'Kitakyushu': {'lat': 33.8833, 'lon': 130.8833},
    'Sakai': {'lat': 34.5733, 'lon': 135.4833},
    'Niigata': {'lat': 37.9022, 'lon': 139.0232},
    'Hamamatsu': {'lat': 34.7108, 'lon': 137.7262},
    'Kumamoto': {'lat': 32.7898, 'lon': 130.7414},
    'Sagamihara': {'lat': 35.5685, 'lon': 139.3916},
    'Shizuoka': {'lat': 34.9769, 'lon': 138.3831},
    'Okayama': {'lat': 34.6618, 'lon': 133.9344},
  };

  Future<WeatherData?> getCurrentWeather(String city) async {
    try {
      if (!japaneseCities.containsKey(city)) {
        throw Exception('City not found in Japan');
      }
      
      // For demo purposes, return mock data if API key is not set
      if (_apiKey == 'YOUR_OPENWEATHER_API_KEY') {
        return _getMockWeatherData(city);
      }
      
      final coords = japaneseCities[city]!;
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': coords['lat'],
          'lon': coords['lon'],
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'en',
        },
      );
      
      if (response.statusCode == 200) {
        return WeatherData.fromJson(response.data);
      }
    } catch (e) {
      // Error fetching weather data, return mock data as fallback
      return _getMockWeatherData(city);
    }
    return null;
  }

  WeatherData _getMockWeatherData(String city) {
    // Mock weather data for demonstration
    final Map<String, Map<String, dynamic>> mockData = {
      'Tokyo': {'temp': 22.0, 'desc': 'Partly cloudy', 'humidity': 65, 'wind': 3.2},
      'Osaka': {'temp': 25.0, 'desc': 'Sunny', 'humidity': 58, 'wind': 2.8},
      'Kyoto': {'temp': 23.0, 'desc': 'Light rain', 'humidity': 72, 'wind': 4.1},
      'Yokohama': {'temp': 21.0, 'desc': 'Cloudy', 'humidity': 68, 'wind': 3.5},
      'Nagoya': {'temp': 24.0, 'desc': 'Clear sky', 'humidity': 55, 'wind': 2.3},
      'Sapporo': {'temp': 18.0, 'desc': 'Cool breeze', 'humidity': 45, 'wind': 5.2},
      'Kobe': {'temp': 26.0, 'desc': 'Warm', 'humidity': 62, 'wind': 2.1},
      'Fukuoka': {'temp': 27.0, 'desc': 'Hot', 'humidity': 70, 'wind': 1.8},
      'Hiroshima': {'temp': 24.0, 'desc': 'Mild', 'humidity': 66, 'wind': 3.0},
      'Sendai': {'temp': 20.0, 'desc': 'Pleasant', 'humidity': 59, 'wind': 3.8},
    };
    
    final data = mockData[city] ?? {'temp': 22.0, 'desc': 'Mild weather', 'humidity': 60, 'wind': 3.0};
    
    return WeatherData(
      temperature: (data['temp'] as num).toDouble(),
      description: data['desc'] as String,
      icon: '01d', // Default sunny icon
      humidity: data['humidity'] as int,
      windSpeed: (data['wind'] as num).toDouble(),
      cityName: city,
    );
  }
  
  List<String> getAvailableCities() {
    return japaneseCities.keys.toList()..sort();
  }
}

class WeatherData {
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final String cityName;
  
  WeatherData({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
  });
  
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      cityName: json['name'] as String,
    );
  }
}
