import 'package:flutter/material.dart';
import 'weather_dashboard.dart'; // Pastikan nama file ini sesuai

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca Indonesia', // Judul Aplikasi di Recent Apps
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B7D3C), // Warna Hijau Pertanian
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: const WeatherDashboard(),
      debugShowCheckedModeBanner: false, // Menghilangkan banner DEBUG
    );
  }
}