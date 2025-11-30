import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Kozhikode (Calicut), Kerala as default center
  static const LatLng _kDefaultCenter = LatLng(11.2588, 75.7804);
  static const double _kDefaultZoom = 2;
  static const double _kUserZoom = 16;

  final Location _locationService = Location();

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

  // Initialize: if GPS enabled -> request permission & get location.
  // If GPS disabled -> leave default center (no prompt here).
  Future<void> _initLocationAndMap() async {
    try {
      // Check service (do not force-enable here)
      _serviceEnabled = await _locationService.serviceEnabled();

      if (!_serviceEnabled) {
        // keep default map center, no prompt at app start
        if (mounted) {
          setState(() {
            _permissionGranted = false;
            _currentPosition = null;
          });
        }
        return;
      }

      // Service enabled -> check permission
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

        if (_mapController != null) {
          _animateTo(_currentPosition!, zoom: _kUserZoom);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  // Use Geolocator for permission request (keeps previous logic)
  Future<bool> _handleLocationPermission() async {
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
    } catch (_) {}
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // if we already have user location, animate to it
    if (_currentPosition != null) {
      _animateTo(_currentPosition!, zoom: _kUserZoom);
    }
  }

  // Called when user taps the my-location button
  Future<void> _onMyLocationPressed() async {
    // If service already enabled and permission granted -> animate to current position
    if (_serviceEnabled && _permissionGranted && _currentPosition != null) {
      _animateTo(_currentPosition!, zoom: _kUserZoom);
      return;
    }

    // Otherwise show native enable-GPS dialog
    try {
      bool enabled = await _locationService
          .requestService(); // shows native dialog on Android
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('GPS not enabled')));
        }
        return;
      }

      // If user enabled GPS, re-init permissions and fetch location
      await _initLocationAndMap();

      if (_currentPosition != null) {
        _animateTo(_currentPosition!, zoom: _kUserZoom);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get location')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error enabling GPS: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _currentPosition ?? _kDefaultCenter;
    final initialZoom = _currentPosition == null ? _kDefaultZoom : _kUserZoom;

    return Scaffold(
      body: _error != null
          ? Center(child: Text('Error: $_error'))
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.satellite,
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: initialZoom,
                  ),
                  myLocationEnabled: _permissionGranted,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: _onMapCreated,
                ),
                Positioned(
                  bottom: 30,
                  right: 15,
                  child: FloatingActionButton(
                    onPressed: _onMyLocationPressed,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),
              ],
            ),
    );
  }
}
