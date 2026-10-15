import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/directions_service.dart';

/// BÀI TẬP 2 (hướng dẫn): Nhập 2 điểm (xuất phát, đích đến) dạng tọa độ
/// "lat, lng" để tìm đường đi, đánh dấu marker và vẽ polyline.
class Bai2Screen extends StatefulWidget {
  const Bai2Screen({super.key});

  @override
  State<Bai2Screen> createState() => _Bai2ScreenState();
}

class _Bai2ScreenState extends State<Bai2Screen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(10.7769, 106.7009),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    final current = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _addMarker(current, 'Xuất phát');
      _startController.text = '${current.latitude}, ${current.longitude}';
    });
    _moveCamera(current);
  }

  void _addMarker(LatLng position, String title) {
    _markers.add(
      Marker(
        markerId: MarkerId(title),
        position: position,
        infoWindow: InfoWindow(title: title),
      ),
    );
  }

  Future<void> _moveCamera(LatLng target) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(target, 14));
  }

  LatLng? _parseLatLng(String text) {
    final parts = text.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  Future<void> _findRoute() async {
    final start = _parseLatLng(_startController.text);
    final end = _parseLatLng(_endController.text);

    if (start == null || end == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập cả hai điểm dạng "lat, lng"'),
        ),
      );
      return;
    }

    late final RouteResult? result;
    try {
      result = await DirectionsService.fetchRoute(
        origin: start,
        destination: end,
      );
    } catch (_) {
      result = null;
    }

    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy tuyến đường')),
      );
      return;
    }

    setState(() {
      _markers.clear();
      _polylines.clear();
      _addMarker(start, 'Xuất phát');
      _addMarker(end, 'Đích đến');
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: result!.points,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
    _moveCamera(start);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Finder')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _startController,
                  decoration: const InputDecoration(
                    labelText: 'Điểm xuất phát (lat, lng)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _endController,
                  decoration: const InputDecoration(
                    labelText: 'Điểm đích (lat, lng)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _findRoute,
                  child: const Text('Tìm đường đi'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              onMapCreated: (controller) => _controller.complete(controller),
            ),
          ),
        ],
      ),
    );
  }
}
