import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../api_key.dart';

/// Chuyển địa chỉ dạng chữ (VD: "227 Nguyễn Văn Cừ, TP.HCM")
/// thành tọa độ bằng Google Geocoding API.
class GeocodingService {
  static Future<LatLng?> geocodeAddress(String address) async {
    final q = address.trim();
    if (q.isEmpty) return null;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(q)}'
      '&key=$googleMapsApiKey',
    );

    final resp = await http.get(url);
    if (resp.statusCode != 200) return null;

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) return null;

    final geo = results[0]['geometry']['location'];
    return LatLng(
      (geo['lat'] as num).toDouble(),
      (geo['lng'] as num).toDouble(),
    );
  }
}
