import 'package:flutter/material.dart';
import 'dart:async';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    // Cập nhật sau mỗi 30 giây
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchWeather(isSilent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeather({bool isSilent = false}) async {
    try {
      if (!isSilent) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
      final data = await _weatherService.getWeather();
      if (mounted) {
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !isSilent) {
        setState(() {
          _errorMessage = 'Failed to load weather data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Overview',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {
                  'username': widget.username,
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Center(
                      child: Text(
                        'Notification',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    content: Text('Bạn có chắc chắn muốn đăng xuất'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWeather,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.username}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here is the current weather update in Hanoi.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  Center(
                    child: Column(
                      children: [
                        Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red)),
                        TextButton(
                          onPressed: _fetchWeather,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildWeatherItem(
                        context,
                        'Temperature',
                        '${_weatherData?['main']?['temp']?.toStringAsFixed(1) ?? '--'}°C',
                        Icons.thermostat_outlined,
                        Colors.orange[50]!,
                        Colors.orange[700]!,
                      ),
                      _buildWeatherItem(
                        context,
                        'Humidity',
                        '${_weatherData?['main']?['humidity'] ?? '--'}%',
                        Icons.water_drop_outlined,
                        Colors.blue[50]!,
                        Colors.blue[700]!,
                      ),
                      _buildWeatherItem(
                        context,
                        'Wind Speed',
                        '${_weatherData?['wind']?['speed'] ?? '--'} km/h',
                        Icons.air_outlined,
                        Colors.green[50]!,
                        Colors.green[700]!,
                      ),
                      _buildWeatherItem(
                        context,
                        'Feels Like',
                        '${_weatherData?['main']?['feels_like']?.toStringAsFixed(1) ?? '--'}°C',
                        Icons.wb_sunny_outlined,
                        Colors.yellow[50]!,
                        Colors.yellow[800]!,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
