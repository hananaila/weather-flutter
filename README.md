# Responsi Praktikum Pemrograman Mobile - Weather Forecast App

Aplikasi pemantau informasi dan prakiraan cuaca berbasis **Flutter** dengan arsitektur **Model-View-ViewModel (MVVM)**, integrasi **Open-Meteo REST API**, dan penyimpanan lokal menggunakan **SharedPreferences**.

---

## Identitas Praktikan
- **Nama:** Hana Naila Rahmadina
- **NIM:** H1D024093
- **Shift KRS:** Shift D
- **Shift Sekarang:** Shift I

---

## 🏛️ Arsitektur Aplikasi (Pola MVVM)

Aplikasi ini dibangun menggunakan arsitektur **Model-View-ViewModel (MVVM)** untuk memastikan kode modular, mudah diuji, dan memisahkan logika bisnis dari antarmuka pengguna:

```
lib/
├── models/             # Representasi struktur data (Data Layer)
│   ├── location_model.dart     # Model entitas kota, koordinat, & lokasi
│   └── weather_model.dart      # Model data cuaca terkini & prakiraan harian
├── services/           # Komunikasi eksternal (API & Storage Layer)
│   ├── api_service.dart        # Klien HTTP (GET) ke REST API Open-Meteo
│   └── storage_service.dart    # Penyimpanan lokal kota favorit (SharedPreferences)
├── utils/              # Helper dan konstanta utilitas
│   └── weather_codes.dart      # Pemetaan WMO Weather Code ke ikon, deskripsi, & tema warna
├── viewmodels/         # Pengelola logika bisnis & state (State Management)
│   ├── weather_viewmodel.dart  # State cuaca, lokasi aktif, & status favorit (ChangeNotifier)
│   └── search_viewmodel.dart   # State pencarian kota live & hasil Geocoding
└── views/              # Tampilan antarmuka pengguna (Presentation Layer)
    ├── home_screen.dart        # Halaman utama cuaca & prakiraan harian
    ├── search_screen.dart      # Halaman pencarian kota & daftar lokasi favorit
    └── widgets/                # Komponen antarmuka modular
        ├── forecast_card.dart      # Kartu informasi ramalan harian
        └── weather_info_tile.dart  # Kartu metrik kelembapan, angin, hujan, dll.
```

### 1. Model (Data Layer)
- **`LocationModel`**: Memetakan data geocoding nama kota, provinsi/administrasi, negara, serta koordinat lintang (*latitude*) dan bujur (*longitude*). Dilengkapi dengan metode serialisasi `fromJson` dan `toJson`.
- **`WeatherModel`**: Mengolah respons JSON dari API cuaca menjadi objek Dart yang terdiri dari `CurrentWeather` (kondisi cuaca saat ini) dan `DailyForecast` (ramalan cuaca 7 hari ke depan).

### 2. View (Presentation Layer)
- **`HomeScreen`**: Menampilkan kondisi cuaca terkini (suhu, cuaca, terasa seperti, suhu max/min), kartu metrik detail (kelembapan, kecepatan angin, curah hujan, peluang hujan), dan daftar prakiraan cuaca harian.
- **`SearchScreen`**: Menyediakan pencarian kota secara langsung (*live search*), hasil rekomendasi koordinat, serta daftar lokasi favorit yang dapat dikelola pengguna.

### 3. ViewModel (Business Logic & State Layer)
- Menggunakan pustaka **`Provider`** dengan turunan kelas **`ChangeNotifier`**.
- **`WeatherViewModel`**: Mengontrol pengambilan data cuaca dari API, menangani kondisi *loading*, *data*, dan *error*, menyimpan kota terakhir yang dilihat, serta mengelola status favorit.
- **`SearchViewModel`**: Mengontrol alur pencarian kota secara *real-time* dan menangani kondisi pencarian kosong atau galat jaringan.

### 4. Service (Data Source Layer)
- **`ApiService`**: Bertanggung jawab melakukan HTTP Request metode `GET` ke Open-Meteo REST API dengan penanganan waktu henti (*timeout*) dan galat koneksi (*SocketException*).
- **`StorageService`**: Menggunakan **`SharedPreferences`** untuk menyimpan daftar lokasi favorit dalam format JSON string secara persisten sehingga data tidak hilang saat aplikasi ditutup.

---

## 🌐 Implementasi REST API (Open-Meteo)

Aplikasi mengintegrasikan dua endpoint resmi dari **Open-Meteo API**:

1. **Geocoding API (Pencarian Lokasi):**
   * Endpoint: `https://geocoding-api.open-meteo.com/v1/search`
   * Parameter: `name={query}&count=10&language=id&format=json`
   * Mengambil nama kota, negara, dan koordinat (*latitude*, *longitude*).

2. **Weather Forecast API (Data Cuaca):**
   * Endpoint: `https://api.open-meteo.com/v1/forecast`
   * Parameter: `latitude={lat}&longitude={lon}&current=...&daily=...&timezone=auto`

### Pemetaan Field Data API yang Ditampilkan:

| Informasi Cuaca | Field API Open-Meteo | Keterangan |
| :--- | :--- | :--- |
| **Suhu Saat Ini** | `current.temperature_2m` | Ditampilkan dalam satuan °C |
| **Kelembapan Udara** | `current.relative_humidity_2m` | Ditampilkan dalam satuan % |
| **Suhu yang Dirasakan** | `current.apparent_temperature` | Nilai *feels like* suhu dalam °C |
| **Curah Hujan** | `current.precipitation` | Ditampilkan dalam satuan mm |
| **Kode Kondisi Cuaca** | `current.weather_code` | Dikonversi ke deskripsi dan ikon cuaca WMO |
| **Kecepatan Angin** | `current.wind_speed_10m` | Ditampilkan dalam satuan km/j |
| **Suhu Maksimum Harian** | `daily.temperature_2m_max` | Suhu tertinggi pada ramalan harian |
| **Suhu Minimum Harian** | `daily.temperature_2m_min` | Suhu terendah pada ramalan harian |
| **Peluang Hujan Maksimum** | `daily.precipitation_probability_max` | Peluang persentase hujan harian |

---

## ✨ Fitur-Fitur Utama Aplikasi

1. **Data Cuaca Dinamis Real-Time:** 100% data diambil langsung dari Open-Meteo REST API (bukan data tiruan/hardcoded).
2. **Pencarian Kota Global:** Pengguna dapat mencari kota di seluruh dunia dan memilihnya untuk langsung memperbarui cuaca di halaman beranda.
3. **Penyimpanan Lokasi Favorit (Local Storage):** Menandai kota dengan ikon hati ❤️ untuk disimpan ke memori internal perangkat (*SharedPreferences*).
4. **Prakiraan Cuaca 7 Hari ke Depan:** Informasi cuaca harian lengkap dengan rentang suhu dan kemungkinan hujan.
5. **Indikator Visual Dinamis:** Warna latar kartu hero dan ikon otomatis menyesuaikan kondisi cuaca (cerah, berawan, gerimis, hujan lebat, atau badai petir).
6. **Penanganan Status Lengkap:**
   - *Loading State:* Indikator animasi memuat saat mengambil data.
   - *Empty State:* Tampilan informatif ketika belum ada kota favorit atau hasil pencarian nihil.
   - *Error State:* Pesan galat jelas dengan tombol **Coba Lagi (Retry)** ketika koneksi internet terputus.

---

## 📸 Dokumentasi Screenshot Aplikasi

*(Screenshot dapat disimpan di dalam folder `screenshots/`)*

| Halaman Utama (Cuaca Terkini & Forecast) | Halaman Pencarian Kota (Geocoding API) |
| :---: | :---: |
| <img src="screenshots/home_screen.png" width="240" /> | <img src="screenshots/search_screen.png" width="240" /> |
| **Daftar Lokasi Favorit (Local Storage)** | **Detail Metrik Cuaca & Ramalan Harian** |
| <img src="screenshots/favorite_screen.png" width="240" /> | <img src="screenshots/forecast_screen.png" width="240" /> |
