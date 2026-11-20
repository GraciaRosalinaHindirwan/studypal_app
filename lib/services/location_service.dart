import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:studypal/models/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
