import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../api_key.dart';

/// Kết quả tuyến đường trả về từ Directions API.
class RouteResult {
  final List<LatLng> points;
  final String distanceText;
  final String durationText;

  const RouteResult({
    required this.points,
    required this.distanceText,
    required this.durationText,
  });
}

/// Gọi Google Directions API để lấy tuyến đường giữa 2 điểm.
class DirectionsService {
  /// [mode]: 'driving' (ô tô / xe máy — API không có mode riêng cho xe máy),
  /// 'walking' (đi bộ), 'bicycling' (xe đạp).
  static Future<RouteResult?> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=$mode'
      '&key=$googleMapsApiKey',
    );

    final resp = await http.get(url);
    if (resp.statusCode != 200) return null;

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final routes = data['routes'] as List?;
    if (routes == null || routes.isEmpty) return null;

    final route = routes[0] as Map<String, dynamic>;
    final encoded = route['overview_polyline']['points'] as String;

    String distance = '';
    String duration = '';
    final legs = route['legs'] as List?;
    if (legs != null && legs.isNotEmpty) {
      final leg = legs[0] as Map<String, dynamic>;
      distance = (leg['distance']?['text'] ?? '').toString();
      duration = (leg['duration']?['text'] ?? '').toString();
    }

    return RouteResult(
      points: decodePolyline(encoded),
      distanceText: distance,
      durationText: duration,
    );
  }

  /// Giải mã chuỗi polyline (thuật toán của Google) thành danh sách tọa độ.
  static List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
