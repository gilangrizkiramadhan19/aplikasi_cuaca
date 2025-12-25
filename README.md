# Aplikasi Cuaca Indonesia (Flutter)

## Deskripsi

Aplikasi **Cuaca Indonesia** merupakan aplikasi mobile sederhana berbasis **Flutter** yang menampilkan informasi cuaca terkini serta prakiraan cuaca menggunakan **REST API OpenWeatherMap**.  
Aplikasi ini dikembangkan sebagai **Tugas ke-1 Kelas Pra-Magang Reguler PT Makerindo** pada **Bidang Mobile Programming**.

Lokasi cuaca yang digunakan pada aplikasi ini adalah **Bandar Lampung**.

---

## Latar Belakang

Perkembangan aplikasi mobile yang memanfaatkan data real-time mendorong kebutuhan akan pemahaman dasar pengembangan aplikasi berbasis API. Melalui aplikasi cuaca ini, peserta dilatih memahami konsep aplikasi mobile, lifecycle Flutter, serta konsumsi REST API sesuai standar pengembangan industri.

---

## Tujuan

Tujuan pembuatan aplikasi ini adalah:

- Menerapkan konsep dasar pengembangan aplikasi mobile menggunakan Flutter
- Mengimplementasikan konsumsi REST API
- Menampilkan data cuaca secara dinamis ke dalam antarmuka aplikasi
- Membiasakan penggunaan Git dan repository sebagai media dokumentasi proyek
- Memenuhi Tugas ke-1 sesuai TOR Kelas Pra-Magang Reguler PT Makerindo

---

## Fitur Aplikasi

- Menampilkan cuaca saat ini (suhu, kelembaban, kecepatan angin, dan curah hujan)
- Prakiraan cuaca per jam
- Prakiraan cuaca 5 hari ke depan
- Mode offline menggunakan data statis
- Refresh data cuaca secara manual
- Tampilan UI menggunakan Material Design 3

---

## Teknologi dan Tools

- **Framework**: Flutter
- **Bahasa Pemrograman**: Dart
- **Library**:
  - flutter/material.dart
  - http
  - dart:convert
- **API**: OpenWeatherMap (REST API)
- **Version Control**: Git

---

## Struktur Proyek

```

lib/
├── main.dart
├── weather_dashboard.dart

```

**Keterangan:**

- `main.dart`
  Entry point aplikasi, pengaturan tema, dan pemanggilan halaman utama.
- `weather_dashboard.dart`
  Berisi logika pengambilan data API, pengolahan data cuaca, dan tampilan UI aplikasi.

---

## Cara Menjalankan Aplikasi

1. Pastikan Flutter SDK telah terpasang
2. Clone repository ini

```

git clone <link-repository>

```

3. Masuk ke folder proyek

```

cd nama_proyek

```

4. Install dependency

```

flutter pub get

```

5. Jalankan aplikasi

```

flutter run

```

---

## API yang Digunakan

Aplikasi ini menggunakan **OpenWeatherMap API**, meliputi:

- Current Weather API
- 5 Days / 3 Hours Forecast API

Data yang ditampilkan:

- Suhu (°C)
- Kelembaban (%)
- Kecepatan angin (m/s)
- Curah hujan (mm)
- Deskripsi cuaca

---

## Kesesuaian dengan TOR PT Makerindo

**Bidang**: Mobile Programming

**Materi yang diterapkan**:

- Konsep aplikasi mobile dan lifecycle
- UI mobile dasar
- Konsumsi REST API

**Tools yang digunakan**:

- Flutter
- REST API
- Git

**Tugas ke-1**:

- Membuat aplikasi mobile sederhana
- Menampilkan data statis dan API
- Mendokumentasikan proyek dalam repository

---

## Informasi Kegiatan

- **Program**: Kelas Pra-Magang Reguler
- **Instansi**: PT Makerindo Dot Indo
- **Periode**: 24 Desember – 3 Januari
- **Email Koordinasi**: makerdotindo@gmail.com

---

## Penutup

Repository ini dibuat sebagai dokumentasi resmi **Tugas ke-1 Kelas Pra-Magang Reguler PT Makerindo**. Aplikasi ini diharapkan dapat menjadi dasar kesiapan teknis sebelum mengikuti program magang reguler di bidang Mobile Programming.

```

```
