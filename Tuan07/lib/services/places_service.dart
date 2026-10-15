import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../api_key.dart';

/// Một địa điểm trả về từ Places API.
class PlaceResult {
  final String name;
  final String address;
  final LatLng location;

  const PlaceResult({
    required this.name,
    required this.address,
    required this.location,
  });
}

/// Tìm kiếm địa điểm (khách sạn, quán ăn, bệnh viện, trường học...)
/// bằng Google Places API (Text Search).
class PlacesService {
  static Future<List<PlaceResult>> searchPlaces(
    String query, {
    LatLng? bias,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=${Uri.encodeComponent(q)}'
        '&key=$googleMapsApiKey';
    if (bias != null) {
      url += '&location=${bias.latitude},${bias.longitude}&radius=50000';
    }

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return [];

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final results = data['results'] as List? ?? [];

    return results.map((e) {
      final geo = e['geometry']['location'];
      return PlaceResult(
        name: (e['name'] ?? '').toString(),
        address: (e['formatted_address'] ?? '').toString(),
        location: LatLng(
          (geo['lat'] as num).toDouble(),
          (geo['lng'] as num).toDouble(),
        ),
      );
    }).toList();
  }
}
