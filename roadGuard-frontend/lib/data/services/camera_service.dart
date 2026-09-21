import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  // Initialize cameras
  Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      throw Exception('Failed to initialize cameras: $e');
    }
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

  // Initialize camera controller
  Future<void> initializeCameraController(CameraDescription description) async {
    if (_cameraController != null) {
      await disposeCameraController();
    }

    _cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
    } catch (e) {
      throw Exception('Failed to initialize camera controller: $e');
    }
  }

  // Get camera controller
  CameraController? get cameraController => _cameraController;

  // Get available cameras
  List<CameraDescription>? get cameras => _cameras;

  // Take picture using camera controller (ensures camera-only)
  Future<File> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      return File(image.path);
    } catch (e) {
      throw Exception('Failed to take picture: $e');
    }
  }

  // Pick image from gallery (for testing only - should be disabled in production)
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick image from camera (using image picker as alternative)
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Validate image is from camera (basic check)
  Future<bool> isImageFromCamera(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return false;
      }

      // Check EXIF data if possible (simplified check)
      // In production, you'd want to use a proper EXIF reader
      // to verify the image was taken with a camera
      
      // For now, we'll trust that if it was picked via camera source, it's valid
      return true;
    } catch (e) {
      return false;
    }
  }

  // Dispose camera controller
  Future<void> disposeCameraController() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  // Switch between front and back camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('No alternative camera available');
    }

    final currentCameraIndex = _cameras!.indexOf(_cameraController!.description);
    final newCameraIndex = (currentCameraIndex + 1) % _cameras!.length;
    
    await initializeCameraController(_cameras![newCameraIndex]);
  }

  // Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_cameraController == null) return;
    
    try {
      await _cameraController!.setFlashMode(mode);
    } catch (e) {
      throw Exception('Failed to set flash mode: $e');
    }
  }

  // Get current flash mode
  FlashMode? getFlashMode() {
    return _cameraController?.value.flashMode;
  }

  // Check if flash is available
  bool isFlashAvailable() {
    return _cameraController?.value.flashMode == FlashMode.off ||
           _cameraController?.value.flashMode == FlashMode.always ||
           _cameraController?.value.flashMode == FlashMode.auto;
  }

  // Zoom control
  Future<void> setZoomLevel(double zoom) async {
    if (_cameraController == null) return;
    
    try {
      final maxZoom = await _cameraController!.getMaxZoomLevel();
      final minZoom = await _cameraController!.getMinZoomLevel();
      
      if (zoom >= minZoom && zoom <= maxZoom) {
        await _cameraController!.setZoomLevel(zoom);
      }
    } catch (e) {
      throw Exception('Failed to set zoom level: $e');
    }
  }

  // Dispose all resources
  Future<void> dispose() async {
    await disposeCameraController();
  }
}
