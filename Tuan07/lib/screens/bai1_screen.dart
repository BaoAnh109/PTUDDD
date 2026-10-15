import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/directions_service.dart';

/// BÀI TẬP 1 (hướng dẫn): Hiển thị bản đồ Google Maps, đánh dấu vị trí
/// hiện tại và vẽ đường đi tới điểm đích cố định (TP.HCM).
class Bai1Screen extends StatefulWidget {
  const Bai1Screen({super.key});

  @override
  State<Bai1Screen> createState() => _Bai1ScreenState();
}

class _Bai1ScreenState extends State<Bai1Screen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LatLng? _currentPosition;

  // Điểm đích cố định theo đề bài.
  final LatLng _destination = const LatLng(10.7769, 106.7009);

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(10.7769, 106.7009),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng bật dịch vụ vị trí (GPS)')),
      );
      return;
    }

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
      _currentPosition = current;
      _addMarker(current, 'Vị trí của bạn');
    });
    _moveCamera(current);
    _getDirections();
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
    controller.animateCamera(CameraUpdate.newLatLngZoom(target, 15));
  }

  Future<void> _getDirections() async {
    final origin = _currentPosition;
    if (origin == null) return;

    final result = await DirectionsService.fetchRoute(
      origin: origin,
      destination: _destination,
    );

    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy tuyến đường')),
      );
      return;
    }

    setState(() {
      _addMarker(_destination, 'Đích đến');
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: result.points,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Navigator')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _controller.complete(controller),
          ),
        ],
      ),
    );
  }
}
