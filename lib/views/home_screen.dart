import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../utils/weather_codes.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/forecast_card.dart';
import 'widgets/weather_info_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Consumer<WeatherViewModel>(
          builder: (context, vm, _) {
            final loc = vm.currentLocation;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 18, color: Colors.blueAccent),
                    const SizedBox(width: 4),
                    Text(
                      loc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                if (loc.admin1 != null && loc.admin1!.isNotEmpty)
                  Text(
                    '${loc.admin1}, ${loc.country ?? ""}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            );
          },
        ),
        actions: [
          Consumer<WeatherViewModel>(
            builder: (context, vm, _) {
              return IconButton(
                icon: Icon(
                  vm.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: vm.isFavorite ? Colors.redAccent : Colors.grey[700],
                ),
                tooltip: vm.isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () {
                  final willBeFavorite = !vm.isFavorite;
                  vm.toggleFavorite();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        willBeFavorite
                            ? '${vm.currentLocation.name} ditambahkan ke favorit!'
                            : '${vm.currentLocation.name} dihapus dari favorit.',
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Cari Kota',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.weather == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Mengambil data cuaca...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (vm.errorMessage != null && vm.weather == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.orangeAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal Memuat Cuaca',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => vm.refresh(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final weather = vm.weather;
          if (weather == null) {
            return const Center(child: Text('Tidak ada data cuaca.'));
          }

          final condition = WeatherCodeHelper.getCondition(weather.current.weatherCode);

          return RefreshIndicator(
            onRefresh: () => vm.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Weather Card
                  _buildHeroWeatherCard(context, weather, condition),
                  const SizedBox(height: 20),

                  // Detail Metrics Section
                  const Text(
                    'Informasi Cuaca Terkini',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMetricsGrid(weather),
                  const SizedBox(height: 24),

                  // 7-Day Forecast Section
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 20, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      const Text(
                        'Prakiraan Cuaca Harian',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${weather.daily.length} Hari',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: weather.daily.length,
                    itemBuilder: (context, index) {
                      return ForecastCard(
                        forecast: weather.daily[index],
                        index: index,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroWeatherCard(
    BuildContext context,
    WeatherModel weather,
    WeatherCondition condition,
  ) {
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: condition.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: condition.gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terasa seperti ${weather.current.apparentTemperature.round()}°C',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Icon(
                condition.icon,
                size: 56,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${weather.current.temperature.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                ),
              ),
              const Text(
                '°C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (today != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '▲ ${today.maxTemp.round()}°  ▼ ${today.minTemp.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(WeatherModel weather) {
    final todayRainProb = weather.daily.isNotEmpty
        ? weather.daily.first.precipitationProbability
        : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: WeatherInfoTile(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blueAccent,
                title: 'Kelembapan',
                value: '${weather.current.relativeHumidity}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherInfoTile(
                icon: Icons.air_rounded,
                iconColor: Colors.teal,
                title: 'Kecepatan Angin',
                value: '${weather.current.windSpeed} km/j',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: WeatherInfoTile(
                icon: Icons.umbrella_rounded,
                iconColor: Colors.indigoAccent,
                title: 'Curah Hujan',
                value: '${weather.current.precipitation} mm',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherInfoTile(
                icon: Icons.cloudy_snowing,
                iconColor: Colors.amber,
                title: 'Peluang Hujan',
                value: '$todayRainProb%',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
