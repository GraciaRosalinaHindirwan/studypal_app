import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:studypal/models/location.dart';

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
}
