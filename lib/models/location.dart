class Location {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Location({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? '',
      address: json['display_name'] ?? '',
      latitude: double.tryParse(json['lat'].toString()) ?? 0.0,
      longitude: double.tryParse(json['lon'].toString()) ?? 0.0,
    );
  }
}
