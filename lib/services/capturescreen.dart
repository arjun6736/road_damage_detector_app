// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart'; // <-- added to show native enable-GPS dialog

class CapturePage extends StatefulWidget {
  final CameraController controller; // ✅ Use pre-initialized controller
  const CapturePage({super.key, required this.controller});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  bool _isTakingPicture = false; // ✅ Prevent multi-clicks

  Future<void> _takePicture() async {
    if (_isTakingPicture) return; // block multiple clicks
    _isTakingPicture = true;
    setState(() {});

    try {
      // Check location permission & ensure service enabled (will show dialog)
      final ok = await _handleLocationPermission(context);
      if (!ok) return;

      // Take picture directly (no need to re-init)
      final picture = await widget.controller.takePicture();

      // Get GPS + timestamp
      final pos = await Geolocator.getCurrentPosition();
      final timestamp = DateTime.now().toIso8601String();

      if (!mounted) return;

      // Navigate with captured data
      context.pushNamed(
        'addDetails',
        extra: {
          'imageFile': File(picture.path),
          'gps': "${pos.latitude}, ${pos.longitude}",
          'time': timestamp,
        },
      );
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to capture photo: $e")));
      }
    } finally {
      _isTakingPicture = false; // reset after capture
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Photo")),
      body: CameraPreview(widget.controller), // ✅ Instant preview
      floatingActionButton: FloatingActionButton(
        onPressed: _isTakingPicture
            ? null
            : _takePicture, // ✅ Disable during capture
        child: _isTakingPicture
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.camera),
      ),
    );
  }
}

Future<bool> _handleLocationPermission(BuildContext context) async {
  final Location location = Location();

  // Check if location services are enabled; if not, request service (shows native dialog)
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    try {
      final requested = await location.requestService();
      if (!requested) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable the services',
            ),
          ),
        );
        return false;
      }
      // re-check serviceEnabled after requestService
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable the services',
            ),
          ),
        );
        return false;
      }
    } catch (e) {
      debugPrint('requestService error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to request enabling location services'),
        ),
      );
      return false;
    }
  }

  // Check permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are denied')),
      );
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permissions are permanently denied.'),
      ),
    );
    return false;
  }

  return true;
}
