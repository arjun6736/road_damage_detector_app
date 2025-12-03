import 'package:camera/camera.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  List<CameraDescription>? availableCameras;

  CameraController? _controller;
  Future<void>? _initFuture;

  /// Call this from main.dart after fetching cameras
  void setCameras(List<CameraDescription> cams) {
    availableCameras = cams;
  }

  /// Initialize controller safely
  Future<void> init(CameraDescription camera) async {
    if (_controller != null && _controller!.value.isInitialized) return;

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initFuture = _controller!.initialize();
    await _initFuture;
  }

  CameraController? get controller => _controller;
  Future<void>? get initFuture => _initFuture;

  get future => null;

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _initFuture = null;
  }
}
