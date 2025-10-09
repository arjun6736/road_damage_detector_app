// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

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
      // Check location permission
      if (!await _handleLocationPermission(context)) return;

      // Take picture directly (no need to re-init)
      final picture = await widget.controller.takePicture();

      // Ensure location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enable GPS to capture location")),
          );
        }
        return;
      }

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
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
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

  // Check permission
  permission = await Geolocator.checkPermission();
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
