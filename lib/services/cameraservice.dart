import 'package:camera/camera.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _controller;
  Future<void>? _initFuture;

  Future<void> init(CameraDescription camera) async {
    if (_controller != null && _controller!.value.isInitialized) {
      return; // Already initialized
    }
    _controller = CameraController(camera, ResolutionPreset.medium);
    _initFuture = _controller!.initialize();
    await _initFuture;
  }

  CameraController? get controller => _controller;
  Future<void>? get initFuture => _initFuture;

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _initFuture = null;
  }
}
