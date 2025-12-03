import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

  bool _locationLoaded = false;
  bool _permissionGranted = false;
  bool _mapReady = false;
  bool _animationDone = false; // Prevent duplicate animations

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // -------------------------
  // FAST LOCATION INITIALIZER
  // -------------------------
  Future<void> _initLocation() async {
    try {
      // 1. Check permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _permissionGranted = false);
        }
        return;
      }

      _permissionGranted = true;

      // 2. Get location
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _locationLoaded = true;

      if (mounted) {
        setState(() {});
        // Animate only if map is ready and animation hasn't been done
        if (_mapReady && !_animationDone) {
          _animationDone = true;
          await _animateTo(_currentPosition!);
        }
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // -------------------------
  // CAMERA ANIMATION
  // -------------------------
  Future<void> _animateTo(LatLng target) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: _userZoom),
      ),
    );
  }

  // -------------------------
  // MY LOCATION BUTTON (FAST)
  // -------------------------
  Future<void> _onMyLocationPressed() async {
    if (!_permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enable location permission")),
      );
      return;
    }

    if (_currentPosition != null) {
      // Instant response
      _animateTo(_currentPosition!);
      return;
    }

    // If location not yet loaded → fetch quickly
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      _currentPosition = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {});
        _animateTo(_currentPosition!);
      }
    } catch (e) {
      debugPrint("Location fetch error: $e");
    }
  }

  // -------------------------
  // MAIN UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final initialLatLng = _currentPosition ?? _kKozhikode;
    final initialZoom = _currentPosition == null ? _defaultZoom : _userZoom;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: _permissionGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: initialLatLng,
              zoom: initialZoom,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _mapReady = true;

              // Animate only once
              if (_locationLoaded &&
                  _currentPosition != null &&
                  !_animationDone) {
                _animationDone = true;
                _animateTo(_currentPosition!);
              }
            },
          ),

          // Floating my location button
          Positioned(
            bottom: 30,
            right: 15,
            child: FloatingActionButton(
              onPressed: _onMyLocationPressed,
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
