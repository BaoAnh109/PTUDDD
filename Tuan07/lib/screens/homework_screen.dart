import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/directions_service.dart';
import '../services/favorites_db.dart';
import '../services/geocoding_service.dart';
import 'favorites_screen.dart';

/// BÀI TẬP VỀ NHÀ:
/// 1. Tìm kiếm địa chỉ bằng Geocoding API (nhập địa chỉ chữ thay vì tọa độ).
/// 2. Chọn loại phương tiện (ô tô / xe máy / đi bộ) khi tìm đường đi.
/// 3. Vẽ đường đi trên bản đồ.
/// 4. Tìm tuyến đường tối ưu theo phương tiện đã chọn (Directions API).
/// 5. Lưu tuyến đường đã tìm vào danh sách yêu thích (SQLite)
///    và hiển thị lại khi cần.
class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final TextEditingController _startAddrController =
      TextEditingController();
  final TextEditingController _endAddrController = TextEditingController();

  LatLng? _startLatLng;
  LatLng? _endLatLng;
  RouteResult? _lastRoute;
  String _mode = 'driving';
  bool _loading = false;

  static const Map<String, String> _modeLabels = {
    'driving': 'Ô tô',
    'motorbike': 'Xe máy',
    'walking': 'Đi bộ',
  };

  /// Directions API không có mode riêng cho xe máy nên dùng 'driving'.
  String get _apiMode => _mode == 'walking' ? 'walking' : 'driving';

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(10.7769, 106.7009),
    zoom: 12,
  );

  @override
  void dispose() {
    _startAddrController.dispose();
    _endAddrController.dispose();
    super.dispose();
  }

  void _addMarker(LatLng position, String id, String title,
      {BitmapDescriptor? icon}) {
    _markers.removeWhere((m) => m.markerId.value == id);
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: icon ?? BitmapDescriptor.defaultMarker,
      ),
    );
  }

  Future<void> _moveCamera(LatLng target, {double zoom = 14}) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// (1) Tìm tọa độ từ địa chỉ bằng Geocoding API.
  /// [isStart]: true = đặt làm điểm xuất phát, false = điểm đích.
  Future<void> _geocode(bool isStart) async {
    final text = isStart
        ? _startAddrController.text
        : _endAddrController.text;
    if (text.trim().isEmpty) {
      _snack('Vui lòng nhập địa chỉ');
      return;
    }
    setState(() => _loading = true);
    LatLng? point;
    try {
      point = await GeocodingService.geocodeAddress(text);
    } catch (_) {
      point = null;
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (point == null) {
      _snack('Không tìm thấy địa chỉ "$text"');
      return;
    }
    setState(() {
      if (isStart) {
        _startLatLng = point;
        _addMarker(point!, 'start', 'Xuất phát: $text');
      } else {
        _endLatLng = point;
        _addMarker(point!, 'dest', 'Đích đến: $text',
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen));
      }
    });
    _moveCamera(point);
  }

  /// (2)(3)(4) Tìm đường đi theo phương tiện đã chọn và vẽ lên bản đồ.
  Future<void> _findRoute() async {
    final start = _startLatLng;
    final end = _endLatLng;
    if (start == null || end == null) {
      _snack('Hãy tìm địa chỉ cho cả điểm xuất phát và điểm đích trước');
      return;
    }

    setState(() => _loading = true);
    RouteResult? result;
    try {
      result = await DirectionsService.fetchRoute(
        origin: start,
        destination: end,
        mode: _apiMode,
      );
    } catch (_) {
      result = null;
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (result == null || result.points.isEmpty) {
      _snack('Không tìm thấy tuyến đường');
      return;
    }

    setState(() {
      _lastRoute = result;
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route_${_mode}_${DateTime.now()}'),
          points: result!.points,
          color: _mode == 'walking' ? Colors.green : Colors.blue,
          width: 5,
        ),
      );
    });
  }

  /// (5) Lưu tuyến đường hiện tại vào danh sách yêu thích (SQLite).
  Future<void> _saveFavorite() async {
    final route = _lastRoute;
    final start = _startLatLng;
    final end = _endLatLng;
    if (route == null || start == null || end == null) {
      _snack('Chưa có tuyến đường nào để lưu');
      return;
    }

    final nameController = TextEditingController(
      text:
          '${_startAddrController.text.trim()} → ${_endAddrController.text.trim()}',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lưu tuyến đường yêu thích'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên tuyến đường',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    nameController.dispose();
    if (name == null || name.isEmpty || !mounted) return;

    // Mã hóa lại polyline để lưu gọn: lưu danh sách điểm dạng text.
    final encoded = route.points
        .map((p) => '${p.latitude},${p.longitude}')
        .join(';');

    await FavoritesDb.instance.insert(
      FavoriteRoute(
        name: name,
        startLat: start.latitude,
        startLng: start.longitude,
        endLat: end.latitude,
        endLng: end.longitude,
        mode: _mode,
        distanceText: route.distanceText,
        durationText: route.durationText,
        encodedPolyline: encoded,
      ),
    );
    _snack('Đã lưu "$name" vào danh sách yêu thích');
  }

  /// Mở màn hình danh sách yêu thích, vẽ lại tuyến đường được chọn.
  Future<void> _openFavorites() async {
    final fav = await Navigator.push<FavoriteRoute>(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
    if (fav == null || !mounted) return;

    final points = fav.encodedPolyline.split(';').map((s) {
      final p = s.split(',');
      return LatLng(double.parse(p[0]), double.parse(p[1]));
    }).toList();
    final start = LatLng(fav.startLat, fav.startLng);
    final end = LatLng(fav.endLat, fav.endLng);

    setState(() {
      _markers.clear();
      _polylines.clear();
      _startLatLng = start;
      _endLatLng = end;
      _mode = fav.mode;
      _addMarker(start, 'start', 'Xuất phát: ${fav.name}');
      _addMarker(end, 'dest', 'Đích đến: ${fav.name}',
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen));
      _polylines.add(
        Polyline(
          polylineId: PolylineId('fav_${fav.id}'),
          points: points,
          color: Colors.purple,
          width: 5,
        ),
      );
      _lastRoute = RouteResult(
        points: points,
        distanceText: fav.distanceText,
        durationText: fav.durationText,
      );
    });
    _moveCamera(start);
  }

  Widget _addressRow({
    required TextEditingController controller,
    required String label,
    required bool isStart,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: 'VD: 227 Nguyễn Văn Cừ, TP.HCM',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _geocode(isStart),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _geocode(isStart),
          icon: const Icon(Icons.search),
          tooltip: 'Tìm địa chỉ',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = _lastRoute;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài tập về nhà'),
        actions: [
          IconButton(
            onPressed: _openFavorites,
            icon: const Icon(Icons.favorite),
            tooltip: 'Tuyến đường yêu thích',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _addressRow(
                  controller: _startAddrController,
                  label: 'Địa chỉ xuất phát',
                  isStart: true,
                ),
                const SizedBox(height: 8),
                _addressRow(
                  controller: _endAddrController,
                  label: 'Địa chỉ đích',
                  isStart: false,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Phương tiện: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _mode,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: _modeLabels.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _mode = v);
                        },
                      ),
                    ),
                  ],
                ),
                if (_mode == 'motorbike')
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Ghi chú: Directions API không có chế độ xe máy riêng, '
                      'nên dùng tuyến đường của ô tô.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _findRoute,
                        icon: const Icon(Icons.directions),
                        label: const Text('Tìm đường đi'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _lastRoute == null ? null : _saveFavorite,
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Lưu yêu thích'),
                      ),
                    ),
                  ],
                ),
                if (route != null &&
                    (route.distanceText.isNotEmpty ||
                        route.durationText.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(children: [
                              const Icon(Icons.directions,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(route.distanceText,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ]),
                            Row(children: [
                              const Icon(Icons.access_time,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(route.durationText,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) =>
                  _controller.complete(controller),
            ),
          ),
        ],
      ),
    );
  }
}
