import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const LatLng _kGlobalCenter = LatLng(0, 0);
  static const double _kGlobalZoom = 2;
  static const double _kUserZoom = 16;

  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _permissionGranted = false;
  bool _serviceEnabled = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLocationAndMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndMap() async {
    try {
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();

      final granted = await _handleLocationPermission();
      if (!mounted) return;

      setState(() {
        _permissionGranted = granted;
      });

      if (granted && _serviceEnabled) {
        final pos = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high,
        );
        if (!mounted) return;
        setState(() {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
        });

        // If map already created, animate
        if (_mapController != null) {
          _animateTo(_currentPosition!, zoom: _kUserZoom);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<bool> _handleLocationPermission() async {
    // Check services
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable GPS.'),
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied. Open settings to enable.',
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _animateTo(LatLng target, {double zoom = _kUserZoom}) async {
    try {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom),
        ),
      );
    } catch (_) {
      // ignore animation errors
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _animateTo(_currentPosition!, zoom: _kUserZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _currentPosition ?? _kGlobalCenter;
    final initialZoom = _currentPosition == null ? _kGlobalZoom : _kUserZoom;

    return Scaffold(
      appBar: AppBar(title: const Text('Map view'), centerTitle: true),
      body: _error != null
          ? Center(child: Text('Error: $_error'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: initialZoom,
              ),
              myLocationEnabled: _permissionGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: _onMapCreated,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _animateTo(_currentPosition!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Waiting for location...')),
            );
            // attempt to fetch location again
            _initLocationAndMap();
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
