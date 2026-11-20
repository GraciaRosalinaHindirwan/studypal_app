import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:studypal/models/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;

  RouteResult({
    required this.points,
    required this.distanceMeters,
  });
}

class LocationService {
  Future<List<Location>> searchLocations( //mengembalikan kumpulan objek Location.
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return [];
    }

    //kalau pake cara MODUL V: HTTP Request
    // final apiUrl =
    //   'https://nominatim.openstreetmap.org/search'
    //   '?q=${Uri.encodeQueryComponent(query)}'
    //   '&format=jsonv2'
    //   '&addressdetails=1' //ribet harus pake ? dan &, encode manual. 
    //   '&limit=5'
    //   '&accept-language=id'
    //   '&countrycodes=id';

    // final response = await http.get(
    //   Uri.parse(apiUrl),
    //   headers: {
    //     'User-Agent': 'StudyPal/1.0',
    //   },
    // );

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': query.trim(),
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '5',
        'accept-language': 'id',
        'countrycodes': 'id',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'StudyPal/1.0', //identifikasi aplikasi, nominatimnya yang suruh 
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => Location.fromJson(item)) //setiap item JSON diubah ke object Location
          .toList();
    } else {
      throw Exception(
        'Gagal mengambil data lokasi: ${response.statusCode}',
      );
    }
  }

  Future<RouteResult?> getDrivingRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'StudyPal/1.0',
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic>? routes = data['routes'];
    if (routes == null || routes.isEmpty) {
      return null;
    }

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>?;
    final List<dynamic>? coordinates = geometry?['coordinates'];
    if (coordinates == null || coordinates.isEmpty) {
      return null;
    }

    // OSRM mengembalikan [longitude, latitude], sehingga dibalik menjadi LatLng(lat, lon)
    final points = coordinates.map<LatLng>((coord) {
      final pair = coord as List<dynamic>;
      final lon = (pair[0] as num).toDouble();
      final lat = (pair[1] as num).toDouble();
      return LatLng(lat, lon);
    }).toList();

    final distanceMeters = (route['distance'] as num?)?.toDouble() ??
        calculateDistanceMeters(
          startLat: start.latitude,
          startLng: start.longitude,
          endLat: end.latitude,
          endLng: end.longitude,
        );

    return RouteResult(
      points: points,
      distanceMeters: distanceMeters,
    );
  }

//LBSnya 
  Future<LatLng?> getCurrentUserPosition() async {

    //cek apakah gps dinyalain, kalau gak dibalikin null 
    final serviceEnable = await Geolocator.isLocationServiceEnabled(); 
    if(!serviceEnable) {
      return null;
    }

    //cek status izin lokasi 
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) { //minta izin kalau denied 
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) { //kalau user gak izinin samsek
      return null;
    }

    //ambil koordinat user saat ini 
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    //ubah data menjadi object latLng 
    return LatLng(position.latitude, position.longitude);
  }

  //hitung jarak
  double calculateDistanceMeters({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    final km = meters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }
}
