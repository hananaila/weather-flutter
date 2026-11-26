import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../utils/weather_codes.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/weather_3d_art.dart';

enum LocationFilterTab { all, favorites, recents }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  LocationFilterTab _selectedTab = LocationFilterTab.all;

  // Colorful gradient palette for favorite cards
  static const List<List<Color>> _cardGradients = [
    [Color(0xFF38BDF8), Color(0xFF0284C7)], // Sky Blue
    [Color(0xFF0D9488), Color(0xFF115E59)], // Teal
    [Color(0xFF6366F1), Color(0xFF4338CA)], // Indigo
    [Color(0xFFF59E0B), Color(0xFFD97706)], // Warm Amber
    [Color(0xFFEC4899), Color(0xFFBE185D)], // Rose
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchController.clear();
        Provider.of<SearchViewModel>(context, listen: false).clear();
        Provider.of<WeatherViewModel>(context, listen: false).fetchFavoriteWeathers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocation(BuildContext context, LocationModel location) {
    final weatherVM = Provider.of<WeatherViewModel>(context, listen: false);
    weatherVM.fetchWeather(location);
    Navigator.pop(context);
  }

  void _clearSearch(BuildContext context) {
    _searchController.clear();
    Provider.of<SearchViewModel>(context, listen: false).clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
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
              icon: const Icon(Icons.home_rounded, color: Color(0xFF0284C7), size: 22),
              tooltip: 'Kembali ke Beranda',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Kelola Kota',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar Capsule
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Cari kota (misal: Jakarta, Bandung)...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () => _clearSearch(context),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (val) {
                    setState(() {});
                    if (val.trim().isEmpty) {
                      Provider.of<SearchViewModel>(context, listen: false).clear();
                    } else {
                      Provider.of<SearchViewModel>(context, listen: false).search(val);
                    }
                  },
                ),
              ),
            ),

            // 2. Filter Pills (Semua / Favorit / Riwayat) - Selalu Bisa Diklik Kapan Saja
            Consumer<WeatherViewModel>(
              builder: (context, weatherVM, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    children: [
                      _buildFilterPill(
                        context: context,
                        label: 'Semua',
                        icon: Icons.grid_view_rounded,
                        tab: LocationFilterTab.all,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context: context,
                        label: 'Favorit',
                        icon: Icons.favorite_rounded,
                        tab: LocationFilterTab.favorites,
                        badgeCount: weatherVM.favorites.length,
                        activeColor: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context: context,
                        label: 'Riwayat',
                        icon: Icons.history_rounded,
                        tab: LocationFilterTab.recents,
                        badgeCount: weatherVM.recents.length,
                        activeColor: const Color(0xFF0284C7),
                      ),
                    ],
                  ),
                );
              },
            ),

            // 3. Main Content: Search Results OR Aesthetic Cards
            Expanded(
              child: Consumer2<SearchViewModel, WeatherViewModel>(
                builder: (context, searchVM, weatherVM, _) {
                  // Jika ada teks pencarian aktif, tampilkan hasil pencarian
                  if (_searchController.text.trim().isNotEmpty && searchVM.currentQuery.isNotEmpty) {
                    return _buildSearchResultsView(context, searchVM, weatherVM);
                  }
                  // Jika tidak mencari atau setelah memilih tab, tampilkan kartu-kartu
                  return _buildFilteredCardsView(context, weatherVM);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // Filter Pill Button
  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    required IconData icon,
    required LocationFilterTab tab,
    int? badgeCount,
    Color activeColor = const Color(0xFF0284C7),
  }) {
    final isSelected = _selectedTab == tab && _searchController.text.trim().isEmpty;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Mengklik tab langsung membersihkan pencarian dan menampilkan konten tab tersebut
          _clearSearch(context);
          setState(() {
            _selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
              if (badgeCount != null && badgeCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Filtered Cards View according to selected tab
  Widget _buildFilteredCardsView(BuildContext context, WeatherViewModel weatherVM) {
    switch (_selectedTab) {
      case LocationFilterTab.all:
        return _buildAllView(context, weatherVM);
      case LocationFilterTab.favorites:
        return _buildFavoritesOnlyView(context, weatherVM);
      case LocationFilterTab.recents:
        return _buildRecentsOnlyView(context, weatherVM);
    }
  }

  // View: Tab "Semua"
  Widget _buildAllView(BuildContext context, WeatherViewModel weatherVM) {
    final currentLocation = weatherVM.currentLocation;
    final currentWeather = weatherVM.weather;
    final conditionDesc = currentWeather != null
        ? WeatherCodeHelper.getCondition(currentWeather.current.weatherCode).description
        : 'Memuat cuaca...';
    final currentTemp = currentWeather != null
        ? '${currentWeather.current.temperature.round()}°'
        : '--°';
    final currentCode = currentWeather?.current.weatherCode ?? 1;

    final favorites = weatherVM.favorites;
    final recents = weatherVM.recents;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        // 1. Lokasi Aktif Saat Ini
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF0284C7)),
              SizedBox(width: 6),
              Text(
                'Lokasi Aktif Saat Ini',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
        _buildGradientCard(
          context: context,
          cityName: currentLocation.name,
          subtitle: '${currentLocation.admin1 ?? ""}, ${currentLocation.country ?? ""} (${currentLocation.latitude.toStringAsFixed(2)}°, ${currentLocation.longitude.toStringAsFixed(2)}°)',
          condition: conditionDesc,
          temp: currentTemp,
          art: Weather3DArt.fromWeatherCode(currentCode, size: 90),
          gradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
          onTap: () => _selectLocation(context, currentLocation),
        ),
        const SizedBox(height: 24),

        // 2. Lokasi Favorit
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              const Text(
                'Lokasi Favorit Tersimpan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
              const Spacer(),
              Text(
                '${favorites.length} Kota',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        if (favorites.isEmpty)
          _buildEmptyCard(
            icon: Icons.favorite_border_rounded,
            iconColor: Colors.redAccent,
            title: 'Belum ada kota favorit',
            description: 'Cari kota di atas lalu tekan ikon hati ❤️ untuk menyimpannya sebagai favorit.',
          )
        else
          ...favorites.asMap().entries.map((entry) {
            final index = entry.key;
            final fav = entry.value;
            final isCurrent = fav == currentLocation;
            final favWeather = weatherVM.getFavoriteWeather(fav);
            final condition = favWeather != null
                ? WeatherCodeHelper.getCondition(favWeather.current.weatherCode).description
                : (isCurrent ? conditionDesc : 'Memuat cuaca...');
            final temp = favWeather != null
                ? '${favWeather.current.temperature.round()}°'
                : (isCurrent ? currentTemp : '--°');
            final code = favWeather?.current.weatherCode ?? (isCurrent ? (currentWeather?.current.weatherCode ?? 1) : 1);
            final gradient = _cardGradients[(index + 1) % _cardGradients.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGradientCard(
                context: context,
                cityName: fav.name,
                subtitle: fav.displayName,
                condition: condition,
                temp: temp,
                art: Weather3DArt.fromWeatherCode(code, size: 85),
                gradient: gradient,
                onDelete: () => weatherVM.removeFavorite(fav),
                onTap: () => _selectLocation(context, fav),
              ),
            );
          }),
        const SizedBox(height: 24),

        // 3. Riwayat Pencarian Terakhir
        if (recents.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, size: 16, color: Color(0xFF0284C7)),
                const SizedBox(width: 6),
                const Text(
                  'Riwayat Pencarian',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => weatherVM.clearRecents(),
                  child: const Text(
                    'Hapus Semua',
                    style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          ...recents.map((loc) => _buildRecentCard(context, loc, weatherVM)),
        ],
      ],
    );
  }

  // View: Tab "Favorit" Saja
  Widget _buildFavoritesOnlyView(BuildContext context, WeatherViewModel weatherVM) {
    final favorites = weatherVM.favorites;
    final currentLocation = weatherVM.currentLocation;
    final currentWeather = weatherVM.weather;
    final conditionDesc = currentWeather != null
        ? WeatherCodeHelper.getCondition(currentWeather.current.weatherCode).description
        : 'Memuat cuaca...';
    final currentTemp = currentWeather != null
        ? '${currentWeather.current.temperature.round()}°'
        : '--°';

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildEmptyCard(
            icon: Icons.favorite_border_rounded,
            iconColor: Colors.redAccent,
            title: 'Belum Ada Lokasi Favorit',
            description: 'Ketik nama kota di kolom pencarian di atas, lalu tekan ikon hati ❤️ untuk menambahkan kota ke daftar favoritmu.',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        final isCurrent = fav == currentLocation;
        final favWeather = weatherVM.getFavoriteWeather(fav);
        final condition = favWeather != null
            ? WeatherCodeHelper.getCondition(favWeather.current.weatherCode).description
            : (isCurrent ? conditionDesc : 'Memuat cuaca...');
        final temp = favWeather != null
            ? '${favWeather.current.temperature.round()}°'
            : (isCurrent ? currentTemp : '--°');
        final code = favWeather?.current.weatherCode ?? (isCurrent ? (currentWeather?.current.weatherCode ?? 1) : 1);
        final gradient = _cardGradients[index % _cardGradients.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildGradientCard(
            context: context,
            cityName: fav.name,
            subtitle: fav.displayName,
            condition: condition,
            temp: temp,
            art: Weather3DArt.fromWeatherCode(code, size: 85),
            gradient: gradient,
            onDelete: () => weatherVM.removeFavorite(fav),
            onTap: () => _selectLocation(context, fav),
          ),
        );
      },
    );
  }

  // View: Tab "Riwayat" Saja
  Widget _buildRecentsOnlyView(BuildContext context, WeatherViewModel weatherVM) {
    final recents = weatherVM.recents;

    if (recents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildEmptyCard(
            icon: Icons.history_rounded,
            iconColor: const Color(0xFF0284C7),
            title: 'Belum Ada Riwayat Pencarian',
            description: 'Kota yang kamu cari dan pilih melalui kolom pencarian di atas akan otomatis tercatat di sini.',
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Text(
                '${recents.length} Lokasi Terakhir',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => weatherVM.clearRecents(),
                icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: Colors.redAccent),
                label: const Text(
                  'Hapus Semua',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        ...recents.map((loc) => _buildRecentCard(context, loc, weatherVM)),
      ],
    );
  }

  // Card for Recent Searches
  Widget _buildRecentCard(BuildContext context, LocationModel loc, WeatherViewModel weatherVM) {
    final isFav = weatherVM.favorites.contains(loc);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.history_rounded, color: Color(0xFF0284C7), size: 22),
          ),
          title: Text(
            loc.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            loc.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : const Color(0xFF94A3B8),
                  size: 20,
                ),
                tooltip: isFav ? 'Hapus favorit' : 'Simpan favorit',
                onPressed: () => weatherVM.toggleFavorite(targetLocation: loc),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                tooltip: 'Hapus dari riwayat',
                onPressed: () => weatherVM.removeRecent(loc),
              ),
            ],
          ),
          onTap: () => _selectLocation(context, loc),
        ),
      ),
    );
  }

  // 4. Search Results View (Displayed as Aesthetic Floating Cards)
  Widget _buildSearchResultsView(
    BuildContext context,
    SearchViewModel searchVM,
    WeatherViewModel weatherVM,
  ) {
    if (searchVM.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0284C7)),
            SizedBox(height: 14),
            Text(
              'Mencari lokasi di Open-Meteo...',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    if (searchVM.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                searchVM.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _clearSearch(context),
                child: const Text('Kembali ke Daftar Kota'),
              ),
            ],
          ),
        ),
      );
    }

    if (searchVM.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'Tidak ditemukan lokasi untuk "${searchVM.currentQuery}"',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _clearSearch(context),
              child: const Text('Tutup Pencarian'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        // Header hasil pencarian dengan tombol Tutup
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Hasil untuk "${searchVM.currentQuery}" (${searchVM.results.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _clearSearch(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, size: 14, color: Color(0xFF475569)),
                      SizedBox(width: 3),
                      Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // List kartu hasil pencarian
        ...searchVM.results.map((loc) {
          final isFav = weatherVM.favorites.contains(loc);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _selectLocation(context, loc),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.location_city_rounded,
                        color: Color(0xFF0284C7),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            loc.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.explore_outlined, size: 12, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                '${loc.latitude.toStringAsFixed(2)}°, ${loc.longitude.toStringAsFixed(2)}°',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : const Color(0xFF94A3B8),
                        size: 24,
                      ),
                      tooltip: isFav ? 'Hapus favorit' : 'Simpan favorit',
                      onPressed: () {
                        weatherVM.toggleFavorite(targetLocation: loc);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Master Gradient Card Builder
  Widget _buildGradientCard({
    required BuildContext context,
    required String cityName,
    required String subtitle,
    required String condition,
    required String temp,
    required Widget art,
    required List<Color> gradient,
    VoidCallback? onDelete,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 126,
        padding: const EdgeInsets.fromLTRB(22, 16, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: City Info & Temp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    condition,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    temp,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Cute 3D Weather Art & delete button
            Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  width: 95,
                  height: 95,
                  child: Center(child: art),
                ),
                if (onDelete != null)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      tooltip: 'Hapus dari favorit',
                      onPressed: onDelete,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: iconColor.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

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
              _buildBottomNavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isActive: false,
                onTap: () => Navigator.pop(context),
              ),
              _buildBottomNavItem(
                icon: Icons.search_rounded,
                label: 'Cari Kota',
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
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
