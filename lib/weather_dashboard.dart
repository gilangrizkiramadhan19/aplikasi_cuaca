import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  // --- KONFIGURASI API & LOKASI ---
  final String apiKey = '2b488ec308e6a4b9c9b9d7d2d8ccc4f9';
  final String city = 'Bandar Lampung'; // Lokasi diset ke Lampung

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

  // --- DATA STATIS (CADANGAN JIKA OFFLINE) ---
  final Map<String, dynamic> staticWeatherData = {
    'main': {'temp': 29.5, 'humidity': 75.0},
    'rain': {'1h': 0.0},
    'wind': {'speed': 3.2},
    'weather': [{'description': 'cerah berawan'}],
  };

  final List<Map<String, dynamic>> staticHourlyForecast = [
    {'dt_txt': '2024-12-25 15:00:00', 'main': {'temp': 30.0, 'humidity': 70}},
    {'dt_txt': '2024-12-25 18:00:00', 'main': {'temp': 28.0, 'humidity': 80}},
    {'dt_txt': '2024-12-25 21:00:00', 'main': {'temp': 26.0, 'humidity': 85}},
    {'dt_txt': '2024-12-25 00:00:00', 'main': {'temp': 25.0, 'humidity': 90}},
    {'dt_txt': '2024-12-25 03:00:00', 'main': {'temp': 24.5, 'humidity': 92}},
  ];

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  // --- LOGIKA ICON CUACA ---
  String _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('cerah') || desc.contains('clear')) return '☀️';
    if (desc.contains('mendung') || desc.contains('cloud')) return '☁️';
    if (desc.contains('hujan') || desc.contains('rain')) return '🌧️';
    if (desc.contains('guntur') || desc.contains('thunder')) return '⛈️';
    if (desc.contains('salju') || desc.contains('snow')) return '❄️';
    return '🌤️';
  }

  // --- FUNGSI AMBIL DATA API ---
  Future<void> _fetchWeatherData() async {
    setState(() => isLoading = true);

    // URL Request ke OpenWeatherMap
    final currentWeatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
    );
    final forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric',
    );

    try {
      // 1. Ambil Cuaca Saat Ini
      final currentResponse = await http.get(currentWeatherUrl);
      if (currentResponse.statusCode == 200) {
        final data = jsonDecode(currentResponse.body);
        setState(() {
          temperature = data['main']['temp']?.toDouble() ?? 0.0;
          humidity = data['main']['humidity']?.toDouble() ?? 0.0;
          rainfall = data['rain']?['1h']?.toDouble() ?? 0.0;
          windSpeed = data['wind']['speed']?.toDouble() ?? 0.0;
          weatherStatus = data['weather'][0]['description'] ?? 'Unknown';
          weatherIcon = _getWeatherIcon(weatherStatus);
        });
      }

      // 2. Ambil Prakiraan Cuaca (Forecast)
      final forecastResponse = await http.get(forecastUrl);
      if (forecastResponse.statusCode == 200) {
        final data = jsonDecode(forecastResponse.body);
        setState(() {
          hourlyForecast = data['list'].take(8).toList();
          dailyForecast = _processDailyForecast(data['list']);
        });
      }
    } catch (e) {
      // Jika Gagal / Offline -> Pakai Data Statis
      setState(() {
        temperature = staticWeatherData['main']['temp'] as double;
        humidity = staticWeatherData['main']['humidity'] as double;
        rainfall = staticWeatherData['rain']['1h'] as double? ?? 0.0;
        windSpeed = staticWeatherData['wind']['speed'] as double;
        weatherStatus = '${staticWeatherData['weather'][0]['description']} (Offline)';
        weatherIcon = _getWeatherIcon(weatherStatus);
        hourlyForecast = staticHourlyForecast;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mode Offline: Menampilkan data statis (${e.toString()})'),
            backgroundColor: Colors.blue.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- LOGIKA MEMPROSES DATA HARIAN ---
  List<Map<String, dynamic>> _processDailyForecast(List<dynamic> forecastList) {
    Map<String, Map<String, dynamic>> dailyData = {};
    for (var item in forecastList) {
      final date = item['dt_txt'].toString().split(' ')[0];
      if (!dailyData.containsKey(date)) {
        dailyData[date] = item;
      }
    }
    return dailyData.values.toList().take(5).toList();
  }

  // --- TAMPILAN UTAMA (UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3), // Tema baru: Biru cerah untuk header
        title: const Text(
          'Cuaca Lampung', // Judul di Header Aplikasi
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchWeatherData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lokasi saat ini: Bandar Lampung')),
              );
            },
            tooltip: 'Lokasi',
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF2196F3), // Tema baru: Biru untuk loading
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Mengambil data cuaca...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      )
          : SingleChildScrollView(
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BAGIAN: KARTU UTAMA (SUHU BESAR) ---
  Widget _buildCurrentWeatherSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient( // Tema baru: Gradient biru ke cyan untuk fresh & cerah
          colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city, // Menampilkan 'Bandar Lampung'
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                weatherIcon,
                style: const TextStyle(fontSize: 64),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            weatherStatus.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BAGIAN: GRID DETAIL (ANGIN, HUJAN, DLL) ---
  Widget _buildWeatherDetailsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildDetailCard(
          icon: '💧',
          title: 'Kelembaban',
          value: '${humidity.toStringAsFixed(0)}%',
          subtitle: 'Tingkat kelembaban',
          color: Colors.lightBlue, // Tema baru: Biru muda untuk humidity
        ),
        _buildDetailCard(
          icon: '💨',
          title: 'Angin',
          value: '${windSpeed.toStringAsFixed(1)} m/s',
          subtitle: 'Kecepatan angin',
          color: Colors.cyan, // Tema baru: Cyan untuk angin (fresh)
        ),
        _buildDetailCard(
          icon: '🌧️',
          title: 'Curah Hujan',
          value: '${rainfall.toStringAsFixed(1)} mm',
          subtitle: 'Hujan 1 jam terakhir',
          color: Colors.blue, // Tema baru: Biru untuk hujan
        ),
        _buildDetailCard(
          icon: '🌡️',
          title: 'Terasa Seperti',
          value: '${(temperature - 2).toStringAsFixed(1)}°C',
          subtitle: 'RealFeel suhu',
          color: Colors.teal, // Tema baru: Teal untuk suhu (campur biru-hijau)
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BAGIAN: PRAKIRAAN PER JAM ---
  Widget _buildHourlyForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prakiraan Per Jam',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2196F3), // Tema baru: Biru untuk judul
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final forecast = hourlyForecast[index];
              final time = forecast['dt_txt']?.toString().split(' ')[1].substring(0, 5) ?? 'N/A';
              final temp = (forecast['main']?['temp'] as num?)?.toStringAsFixed(1) ?? 'N/A';
              final humidity = forecast['main']?['humidity'] ?? 'N/A';
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient( // Tema baru: Gradient biru muda untuk hourly
                    colors: [Colors.lightBlue.shade50, Colors.lightBlue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.lightBlue.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3), // Tema baru: Biru untuk waktu
                      ),
                    ),
                    Text(
                      '🌤️',
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      '$temp°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '$humidity%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- WIDGET BAGIAN: PRAKIRAAN 5 HARI ---
  Widget _buildDailyForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prakiraan 5 Hari ke Depan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2196F3), // Tema baru: Biru untuk judul daily
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyForecast.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              final forecast = dailyForecast[index];
              final date = forecast['dt_txt']?.toString().split(' ')[0] ?? 'N/A';
              final temp = (forecast['main']?['temp'] as num?)?.toStringAsFixed(1) ?? 'N/A';
              final humidity = forecast['main']?['humidity'] ?? 'N/A';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelembaban: $humidity%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '🌤️',
                      style: const TextStyle(fontSize: 28),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient( // Tema baru: Gradient biru untuk temp daily
                          colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$temp°C',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}