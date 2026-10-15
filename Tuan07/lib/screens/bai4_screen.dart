import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/directions_service.dart';
import '../services/places_service.dart';

/// BÀI TẬP 4 (trên lớp): Nâng cấp chức năng tìm đường của Bài tập 2:
/// 1. Nút lấy vị trí hiện tại làm điểm đích.
/// 2. Hiển thị khoảng cách và thời gian di chuyển (Directions API).
/// 3. Click trực tiếp lên bản đồ để chọn điểm đích.
/// 4. Tìm kiếm địa điểm (khách sạn, quán ăn, bệnh viện, trường học...)
///    bằng Google Places API.
class Bai4Screen extends StatefulWidget {
  const Bai4Screen({super.key});

  @override
  State<Bai4Screen> createState() => _Bai4ScreenState();
}

class _Bai4ScreenState extends State<Bai4Screen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _currentPosition;

  String _distanceText = '';
  String _durationText = '';
  bool _loading = false;
  List<PlaceResult> _places = [];

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(10.7769, 106.7009),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<LatLng?> _ensureLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng bật dịch vụ vị trí (GPS)')),
        );
      }
      return null;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  Future<void> _initPosition() async {
    final current = await _ensureLocation();
    if (current == null || !mounted) return;
    setState(() {
      _currentPosition = current;
      _startController.text = '${current.latitude}, ${current.longitude}';
    });
    _moveCamera(current);
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

  LatLng? _parseLatLng(String text) {
    final parts = text.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  String _fmt(LatLng p) => '${p.latitude}, ${p.longitude}';

  /// (1) Lấy vị trí hiện tại làm điểm đích.
  Future<void> _useCurrentAsDestination() async {
    final current = await _ensureLocation();
    if (current == null || !mounted) return;
    setState(() {
      _currentPosition = current;
      _endController.text = _fmt(current);
      _addMarker(current, 'dest', 'Đích đến (vị trí hiện tại)',
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen));
    });
    _moveCamera(current);
  }

  /// (3) Click lên bản đồ để chọn điểm đích.
  void _onMapTap(LatLng point) {
    setState(() {
      _endController.text = _fmt(point);
      _addMarker(point, 'dest', 'Đích đến',
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen));
    });
  }

  /// (4) Tìm kiếm địa điểm bằng Places API.
  Future<void> _searchPlaces() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _loading = true);
    try {
      final results = await PlacesService.searchPlaces(
        query,
        bias: _currentPosition,
      );
      if (!mounted) return;
      setState(() {
        _places = results;
        _loading = false;
      });
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy địa điểm')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tìm kiếm địa điểm')),
      );
    }
  }

  /// Chọn một địa điểm trong kết quả tìm kiếm làm điểm đích.
  void _pickPlace(PlaceResult place) {
    setState(() {
      _endController.text = _fmt(place.location);
      _addMarker(place.location, 'dest', place.name,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen));
      _places = [];
      _searchController.clear();
    });
    _moveCamera(place.location);
  }

  /// Tìm đường đi và hiển thị khoảng cách + thời gian (2).
  Future<void> _findRoute() async {
    final start = _parseLatLng(_startController.text);
    final end = _parseLatLng(_endController.text);

    if (start == null || end == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập cả hai điểm dạng "lat, lng"')),
      );
      return;
    }

    setState(() => _loading = true);
    RouteResult? result;
    try {
      result = await DirectionsService.fetchRoute(
        origin: start,
        destination: end,
      );
    } catch (_) {
      result = null;
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy tuyến đường')),
      );
      return;
    }

    setState(() {
      _markers.clear();
      _polylines.clear();
      _addMarker(start, 'start', 'Xuất phát');
      _addMarker(end, 'dest', 'Đích đến',
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen));
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: result!.points,
          color: Colors.blue,
          width: 5,
        ),
      );
      _distanceText = result.distanceText;
      _durationText = result.durationText;
    });
    _moveCamera(start);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài 4 - Tìm đường nâng cao')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // (4) Tìm kiếm địa điểm
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Tìm địa điểm (khách sạn, quán ăn...)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _searchPlaces(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _searchPlaces,
                      icon: const Icon(Icons.search),
                      tooltip: 'Tìm kiếm',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _startController,
                  decoration: const InputDecoration(
                    labelText: 'Điểm xuất phát (lat, lng)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _endController,
                        decoration: const InputDecoration(
                          labelText: 'Điểm đích (lat, lng)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _useCurrentAsDestination,
                      icon: const Icon(Icons.my_location),
                      tooltip: 'Lấy vị trí hiện tại làm điểm đích',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _findRoute,
                        child: const Text('Tìm đường đi'),
                      ),
                    ),
                  ],
                ),
                // (2) Khoảng cách + thời gian
                if (_distanceText.isNotEmpty || _durationText.isNotEmpty)
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
                              Text(_distanceText,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ]),
                            Row(children: [
                              const Icon(Icons.access_time,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(_durationText,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Mẹo: chạm vào bản đồ để chọn điểm đích',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCamera,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: _onMapTap,
                  onMapCreated: (controller) =>
                      _controller.complete(controller),
                ),
                // Kết quả tìm kiếm địa điểm
                if (_places.isNotEmpty)
                  Positioned(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 8,
                    child: Card(
                      elevation: 6,
                      child: ListView.separated(
                        itemCount: _places.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final p = _places[i];
                          return ListTile(
                            leading: const Icon(Icons.place,
                                color: Colors.red),
                            title: Text(p.name),
                            subtitle: Text(p.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            onTap: () => _pickPlace(p),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
