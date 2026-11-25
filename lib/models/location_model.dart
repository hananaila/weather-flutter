class LocationModel {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String? ?? 'Tidak Diketahui',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
    };
  }

  String get displayName {
    final parts = [name];
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      parts.add(admin1!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          (name.toLowerCase() == other.name.toLowerCase() ||
              (latitude - other.latitude).abs() < 0.05 &&
                  (longitude - other.longitude).abs() < 0.05);

  @override
  int get hashCode => name.toLowerCase().hashCode;
}
