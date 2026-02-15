import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/road_segment_service.dart';
import '../models/road_segment.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const LatLng _kKozhikode = LatLng(11.2588, 75.7804);
  static const double _defaultZoom = 13;
  static const double _userZoom = 16;

  GoogleMapController? _mapController;
  LatLng? _currentPosition;

  bool _permissionGranted = false;
  bool _mapReady = false;
  bool _animationDone = false;

  double _currentZoom = _defaultZoom;
  LatLng _mapCenter = _kKozhikode;

  final RoadSegmentService _service = RoadSegmentService();
  final Set<Polyline> _polylines = {};

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // -------------------------
  // LOCATION
  // -------------------------
  Future<void> _initLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.deniedForever) return;

    _permissionGranted = true;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(pos.latitude, pos.longitude);

    if (_mapReady && !_animationDone) {
      _animationDone = true;
      _animateTo(_currentPosition!);
    }

    if (mounted) setState(() {});
  }

  // -------------------------
  // CAMERA
  // -------------------------
  Future<void> _animateTo(LatLng target) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: _userZoom),
      ),
    );
  }

  // -------------------------
  // API FETCH
  // -------------------------
  void _fetchSegments() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final segments = await _service.fetchSegments(
          latitude: _mapCenter.latitude,
          longitude: _mapCenter.longitude,
          zoom: _currentZoom.round(),
        );
        _drawPolylines(segments);
      } catch (e) {
        debugPrint("API error: $e");
      }
    });
  }

  // -------------------------
  // DRAW POLYLINES
  // -------------------------
  void _drawPolylines(List<RoadSegment> segments) {
    final polylines = segments.map((segment) {
      return Polyline(
        polylineId: PolylineId('segment_${segment.id}'),
        points: segment.points,
        width: 6,
        color: _severityColor(segment.severity),
        geodesic: true,
      );
    }).toSet();

    if (!mounted) return;

    setState(() {
      _polylines
        ..clear()
        ..addAll(polylines);
    });
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.yellow;
    }
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final initialTarget = _currentPosition ?? _kKozhikode;
    final initialZoom = _currentPosition == null ? _defaultZoom : _userZoom;

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialTarget,
          zoom: initialZoom,
        ),
        myLocationEnabled: _permissionGranted,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        polylines: _polylines,
        onMapCreated: (controller) {
          _mapController = controller;
          _mapReady = true;
          if (_currentPosition != null && !_animationDone) {
            _animationDone = true;
            _animateTo(_currentPosition!);
          }
        },
        onCameraMove: (position) {
          _currentZoom = position.zoom;
          _mapCenter = position.target;
        },
        onCameraIdle: _fetchSegments,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: Colors.blue),
        onPressed: () {
          if (_currentPosition != null) {
            _animateTo(_currentPosition!);
          }
        },
      ),
    );
  }
}
