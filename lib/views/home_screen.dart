import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../utils/weather_codes.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/forecast_card.dart';
import 'widgets/weather_3d_art.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getFormattedDate() {
    try {
      final now = DateTime.now();
      return DateFormat('EEEE, d MMM', 'id_ID').format(now);
    } catch (_) {
      try {
        final now = DateTime.now();
        return DateFormat('EEE, d MMM').format(now);
      } catch (_) {
        return 'Hari ini';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, _) {
        final weather = vm.weather;
        final condition = weather != null
            ? WeatherCodeHelper.getCondition(weather.current.weatherCode)
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F6FB),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE1F0FD), Color(0xFFF4F8FC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top Custom App Bar (Symmetrical & clearly labeled)
                  _buildTopBar(context, vm),

                  // Main Content
                  Expanded(
                    child: _buildBody(context, vm, weather, condition),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, WeatherViewModel vm) {
    final loc = vm.currentLocation;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Left: Search Button (Ikon kaca pembesar yang jelas)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.search_rounded, color: Color(0xFF0284C7), size: 22),
              tooltip: 'Cari & Kelola Kota',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
          ),

          // Center: City Name, Date & Coordinates (100% mathematically centered)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getFormattedDate(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (loc.admin1 != null && loc.admin1!.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    '${loc.admin1}, ${loc.country ?? ""} (${loc.latitude.toStringAsFixed(2)}°, ${loc.longitude.toStringAsFixed(2)}°)',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Right: Favorite Heart Button (Fixed width 44 to mirror left button exactly)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                vm.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: vm.isFavorite ? Colors.redAccent : const Color(0xFF64748B),
                size: 20,
              ),
              tooltip: vm.isFavorite ? 'Hapus favorit' : 'Tambah favorit',
              onPressed: () {
                final willBeFav = !vm.isFavorite;
                vm.toggleFavorite();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      willBeFav
                          ? '${vm.currentLocation.name} ditambahkan ke favorit!'
                          : '${vm.currentLocation.name} dihapus dari favorit.',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel vm,
    WeatherModel? weather,
    WeatherCondition? condition,
  ) {
    if (vm.isLoading && weather == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0284C7)),
            SizedBox(height: 16),
            Text(
              'Mengambil data cuaca...',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    if (vm.errorMessage != null && weather == null) {
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => vm.refresh(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (weather == null) {
      return const Center(
        child: Text(
          'Tidak ada data cuaca.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    final todayRainProb = weather.daily.isNotEmpty
        ? weather.daily.first.precipitationProbability
        : 0;

    return RefreshIndicator(
      color: const Color(0xFF0284C7),
      backgroundColor: Colors.white,
      onRefresh: () => vm.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Weather Card (Floating Sky Blue / Azure Gradient)
            _buildHeroCard(context, weather, condition),
            const SizedBox(height: 20),

            // 2. Section: 4 Separate White Metric Tiles (Memenuhi Semua Syarat Wajib)
            const Text(
              'Detail Informasi Cuaca',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildMetricGrid(weather, todayRainProb),
            const SizedBox(height: 26),

            // 3. Section: Prakiraan Cuaca 7 Hari
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: Color(0xFF0284C7),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Prakiraan 7 Hari',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Text(
                  '${weather.daily.length} Hari',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Clean Floating White Forecast Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weather.daily.length,
              itemBuilder: (context, index) {
                return ForecastCard(
                  forecast: weather.daily[index],
                  index: index,
                  isGlassmorphic: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Floating Hero Card (Sky-Blue theme from reference Image 1 & 2)
  Widget _buildHeroCard(
    BuildContext context,
    WeatherModel weather,
    WeatherCondition? condition,
  ) {
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Left: 3D Cute Weather Illustration & Condition Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Weather3DArt.fromWeatherCode(
                      weather.current.weatherCode,
                      size: 105,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      condition?.description ?? 'Berawan',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kondisi Hari Ini',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Big Temperature & Feels Like
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${weather.current.temperature.round()}°',
                    style: const TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Terasa seperti ${weather.current.apparentTemperature.round()}°C',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (today != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '▲ ${today.maxTemp.round()}°  ▼ ${today.minTemp.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4 Separate White Metric Tiles (Clean 2x2 Grid)
  Widget _buildMetricGrid(WeatherModel weather, int todayRainProb) {
    return Column(
      children: [
        Row(
          children: [
            // 1. Kelembapan (Humidity)
            Expanded(
              child: _buildMetricTile(
                icon: Icons.opacity_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBgColor: const Color(0xFFE0F2FE),
                title: 'Kelembapan',
                value: '${weather.current.relativeHumidity}%',
              ),
            ),
            const SizedBox(width: 14),

            // 2. Kecepatan Angin (Wind Speed)
            Expanded(
              child: _buildMetricTile(
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF0D9488),
                iconBgColor: const Color(0xFFCCFBF1),
                title: 'Kecepatan Angin',
                value: '${weather.current.windSpeed} km/j',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 3. Curah Hujan (Precipitation)
            Expanded(
              child: _buildMetricTile(
                icon: Icons.grain_rounded,
                iconColor: const Color(0xFF4F46E5),
                iconBgColor: const Color(0xFFE0E7FF),
                title: 'Curah Hujan',
                value: '${weather.current.precipitation} mm',
              ),
            ),
            const SizedBox(width: 14),

            // 4. Peluang Hujan (Rain Probability)
            Expanded(
              child: _buildMetricTile(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFFE11D48),
                iconBgColor: const Color(0xFFFFE4E6),
                title: 'Peluang Hujan',
                value: '$todayRainProb%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar untuk memisahkan Beranda dan Cari Kota secara jelas
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.search_rounded,
                label: 'Cari Kota',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE0F2FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? const Color(0xFF0284C7) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF0284C7) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
