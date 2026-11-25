import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cari nama kota (misal: Jakarta, Bandung)...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      Provider.of<SearchViewModel>(context, listen: false).clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() {});
            Provider.of<SearchViewModel>(context, listen: false).search(val);
          },
        ),
      ),
      body: Consumer2<SearchViewModel, WeatherViewModel>(
        builder: (context, searchVM, weatherVM, _) {
          // If user hasn't typed anything, show Favorite Locations
          if (searchVM.currentQuery.isEmpty) {
            return _buildFavoritesView(context, weatherVM);
          }

          if (searchVM.isSearching) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Mencari lokasi di Open-Meteo...'),
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
                      style: const TextStyle(color: Colors.grey),
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
                  const Icon(Icons.location_off_rounded, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ditemukan lokasi untuk "${searchVM.currentQuery}"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: searchVM.results.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final loc = searchVM.results[index];
              final isFav = weatherVM.favorites.contains(loc);

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.location_city_rounded, color: Colors.blueAccent),
                ),
                title: Text(
                  loc.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  loc.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.grey,
                  ),
                  tooltip: isFav ? 'Hapus dari favorit' : 'Simpan sebagai favorit',
                  onPressed: () {
                    weatherVM.toggleFavorite(targetLocation: loc);
                  },
                ),
                onTap: () => _selectLocation(context, loc),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoritesView(BuildContext context, WeatherViewModel weatherVM) {
    final favorites = weatherVM.favorites;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Lokasi Favorit Anda',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${favorites.length} Lokasi',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (favorites.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border_rounded, size: 56, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada lokasi favorit',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ketik nama kota di atas lalu tekan ikon hati untuk menyimpannya sebagai lokasi favorit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final loc = favorites[index];
                final isCurrent = weatherVM.currentLocation == loc;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrent ? Colors.blueAccent : Colors.grey[200],
                    child: Icon(
                      Icons.place_rounded,
                      color: isCurrent ? Colors.white : Colors.grey[700],
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        loc.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Aktif',
                            style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    loc.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    tooltip: 'Hapus dari favorit',
                    onPressed: () {
                      weatherVM.removeFavorite(loc);
                    },
                  ),
                  onTap: () => _selectLocation(context, loc),
                );
              },
            ),
          ),
      ],
    );
  }
}
