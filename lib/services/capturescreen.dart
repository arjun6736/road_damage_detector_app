// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import '../services/cameraservice.dart';

class CapturePage extends StatefulWidget {
  final CameraDescription camera;
  const CapturePage({super.key, required this.camera});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  CameraController? controller;
  bool loading = true;
  bool takingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await CameraService().init(widget.camera);
      controller = CameraService().controller;
      if (mounted) setState(() => loading = false);
    } catch (e) {
      debugPrint("Camera init failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Camera error: $e")));
      }
    }
  }

  @override
  void dispose() {
    CameraService().dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (takingPicture) return;
    takingPicture = true;
    setState(() {});

    try {
      // Location permission
      if (!await _checkGPS()) return;

      final picture = await controller!.takePicture();
      final pos = await Geolocator.getCurrentPosition();
      final time = DateTime.now().toIso8601String();

      context.pushNamed(
        'addDetails',
        extra: {
          "imageFile": File(picture.path),
          "gps": "${pos.latitude}, ${pos.longitude}",
          "time": time,
        },
      );
    } catch (e) {
      debugPrint("Capture error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      takingPicture = false;
      if (mounted) setState(() {});
    }
  }

  Future<bool> _checkGPS() async {
    Location location = Location();

    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      final req = await location.requestService();
      if (!req) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Enable GPS to continue")));
        return false;
      }
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return false;
    }
    if (perm == LocationPermission.deniedForever) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CameraPreview(controller!),
      floatingActionButton: FloatingActionButton(
        onPressed: takingPicture ? null : _capture,
        child: takingPicture
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.camera_alt),
      ),
    );
  }
}
