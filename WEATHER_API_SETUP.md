# Weather API Setup

This app uses OpenWeatherMap API to provide weather information for Japanese cities.

## Setup Instructions

1. **Get an API Key**
   - Go to [OpenWeatherMap](https://openweathermap.org/api)
   - Sign up for a free account
   - Get your API key from the "My API keys" section

2. **Configure the API Key**
   - Open `lib/services/weather/weather_service.dart`
   - Replace `YOUR_OPENWEATHER_API_KEY` with your actual API key:
   ```dart
   static const String _apiKey = 'your_actual_api_key_here';
   ```

3. **Features**
   - Displays current weather for Tokyo by default
   - Users can change to any of 20 major Japanese cities
   - Shows temperature, description, humidity, and wind speed
   - Weather data is fetched in real-time

## Available Cities

The app includes weather data for these Japanese cities:
- Tokyo, Osaka, Kyoto, Yokohama, Nagoya
- Sapporo, Kobe, Fukuoka, Kawasaki, Hiroshima
- Sendai, Chiba, Kitakyushu, Sakai, Niigata
- Hamamatsu, Kumamoto, Sagamihara, Shizuoka, Okayama

## API Limits

- Free tier: 1,000 calls per day
- Each city change counts as 1 API call
- Weather data is cached for the current session

## Troubleshooting

If weather data doesn't load:
1. Check your internet connection
2. Verify your API key is correct
3. Ensure you haven't exceeded daily API limits
4. Check the console for error messages

