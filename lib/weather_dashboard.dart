import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Diperlukan untuk timeout

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  // --- KONFIGURASI API & LOKASI ---
  final String apiKey = '2b488ec308e6a4b9c9b9d7d2d8ccc4f9';
  final String city = 'Bandar Lampung';

  // --- VARIABEL DATA ---
  double temperature = 0.0;
  double humidity = 0.0;
  double rainfall = 0.0;
  double windSpeed = 0.0;
  String weatherStatus = 'Loading...';
  String weatherIcon = '☀️';
  List<dynamic> hourlyForecast = [];
  List<dynamic> dailyForecast = [];
  bool isLoading = true;
  bool isOffline = false;

  // --- DATA STATIS (CADANGAN JIKA OFFLINE) ---
  final Map<String, dynamic> staticWeatherData = {
    'main': {'temp': 29.5, 'humidity': 75.0},
    'rain': {'1h': 0.0},
    'wind': {'speed': 3.2},
    'weather': [{'description': 'Cerah Berawan (Data Offline)'}],
  };

  final List<Map<String, dynamic>> staticHourlyForecast = [
    {'dt_txt': '2024-12-25 15:00:00', 'main': {'temp': 30.0, 'humidity': 70}},
    {'dt_txt': '2024-12-25 18:00:00', 'main': {'temp': 28.0, 'humidity': 80}},
    {'dt_txt': '2024-12-25 21:00:00', 'main': {'temp': 26.0, 'humidity': 85}},
  ];

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  String _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('cerah') || desc.contains('clear')) return '☀️';
    if (desc.contains('mendung') || desc.contains('cloud')) return '☁️';
    if (desc.contains('hujan') || desc.contains('rain')) return '🌧️';
    if (desc.contains('guntur') || desc.contains('thunder')) return '⛈️';
    return '🌤️';
  }

  // --- FUNGSI AMBIL DATA API ---
  Future<void> _fetchWeatherData() async {
    setState(() {
      isLoading = true;
    });

    final currentWeatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
    );
    final forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric',
    );

    try {
      // Timeout 7 detik: Jika kuota mati, aplikasi tidak akan loading selamanya
      final currentResponse = await http.get(currentWeatherUrl).timeout(const Duration(seconds: 7));
      final forecastResponse = await http.get(forecastUrl).timeout(const Duration(seconds: 7));

      if (currentResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        final data = jsonDecode(currentResponse.body);
        final forecastData = jsonDecode(forecastResponse.body);

        setState(() {
          temperature = (data['main']['temp'] as num).toDouble();
          humidity = (data['main']['humidity'] as num).toDouble();
          rainfall = (data['rain']?['1h'] as num?)?.toDouble() ?? 0.0;
          windSpeed = (data['wind']['speed'] as num).toDouble();
          weatherStatus = data['weather'][0]['description'] ?? 'Unknown';
          weatherIcon = _getWeatherIcon(weatherStatus);
          hourlyForecast = forecastData['list'].take(8).toList();
          dailyForecast = _processDailyForecast(forecastData['list']);
          isOffline = false; // Berhasil Online
        });

        // NOTIFIKASI BERHASIL ONLINE
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Data cuaca berhasil diperbarui secara online'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      // JIKA OFFLINE / TIMEOUT
      setState(() {
        isOffline = true;
        temperature = (staticWeatherData['main']['temp'] as num).toDouble();
        humidity = (staticWeatherData['main']['humidity'] as num).toDouble();
        rainfall = 0.0;
        windSpeed = (staticWeatherData['wind']['speed'] as num).toDouble();
        weatherStatus = "Internet Terputus (Data Statis)";
        weatherIcon = '⚠️';
        hourlyForecast = staticHourlyForecast;
        dailyForecast = _processDailyForecast(staticHourlyForecast);
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _processDailyForecast(List<dynamic> forecastList) {
    Map<String, Map<String, dynamic>> dailyData = {};
    for (var item in forecastList) {
      final date = item['dt_txt'].toString().split(' ')[0];
      if (!dailyData.containsKey(date)) {
        dailyData[date] = Map<String, dynamic>.from(item);
      }
    }
    return dailyData.values.toList().take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          'Cuaca Lampung',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchWeatherData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Offline (Tetap ada sebagai informasi di atas)
          if (isOffline)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Mode Offline aktif',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCurrentWeatherSection(),
          const SizedBox(height: 24),
          _buildWeatherDetailsGrid(),
          const SizedBox(height: 24),
          _buildHourlyForecastSection(),
          const SizedBox(height: 24),
          _buildDailyForecastSection(),
        ],
      ),
    );
  }

  // --- UI Widget (Section kartu utama) ---
  Widget _buildCurrentWeatherSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOffline
              ? [Colors.blueGrey, Colors.grey] // Warna redup jika offline
              : [const Color(0xFF2196F3), const Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  Text('${temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(weatherIcon, style: const TextStyle(fontSize: 64)),
            ],
          ),
          const SizedBox(height: 10),
          Text(weatherStatus.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  // --- Grid detail cuaca ---
  Widget _buildWeatherDetailsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildDetailCard('💧', 'Kelembaban', '${humidity.toStringAsFixed(0)}%', Colors.blue),
        _buildDetailCard('💨', 'Angin', '${windSpeed.toStringAsFixed(1)} m/s', Colors.cyan),
        _buildDetailCard('🌧️', 'Hujan', '${rainfall.toStringAsFixed(1)} mm', Colors.blueAccent),
        _buildDetailCard('🌡️', 'Terasa', '${(temperature - 2).toStringAsFixed(1)}°C', Colors.teal),
      ],
    );
  }

  Widget _buildDetailCard(String icon, String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // --- Prakiraan Per Jam ---
  Widget _buildHourlyForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Per Jam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final f = hourlyForecast[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(f['dt_txt'].toString().split(' ')[1].substring(0, 5), style: const TextStyle(fontSize: 12)),
                    Text('${(f['main']['temp'] as num).toStringAsFixed(1)}°', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Prakiraan Harian ---
  Widget _buildDailyForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prakiraan 5 Hari', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyForecast.length,
            itemBuilder: (context, index) {
              final f = dailyForecast[index];
              return ListTile(
                title: Text(f['dt_txt'].toString().split(' ')[0]),
                trailing: Text('${(f['main']['temp'] as num).toStringAsFixed(1)}°C', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }
}