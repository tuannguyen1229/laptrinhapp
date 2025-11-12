import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';
import '../errors/exceptions.dart' as app_exceptions;

@singleton
class CameraService {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitialized = false;

  // Khởi tạo camera
  Future<void> initialize() async {
    try {
      // Kiểm tra quyền camera
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        throw app_exceptions.CameraException('Không có quyền truy cập camera');
      }

      // Lấy danh sách camera có sẵn
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        throw app_exceptions.CameraException('Không tìm thấy camera nào trên thiết bị');
      }

      _isInitialized = true;
    } catch (e) {
      throw app_exceptions.CameraException('Không thể khởi tạo camera service: $e');
    }
  }

  // Kiểm tra quyền camera
  Future<bool> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      
      return false;
    } catch (e) {
      throw app_exceptions.PermissionException('Không thể kiểm tra quyền camera: $e');
    }
  }

  // Khởi tạo camera controller
  Future<CameraController> initializeCameraController({
    CameraLensDirection direction = CameraLensDirection.back,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Tìm camera phù hợp
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == direction,
        orElse: () => _cameras!.first,
      );

      // Tạo controller mới
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      // Khởi tạo controller
      await _controller!.initialize();

      return _controller!;
    } catch (e) {
      throw app_exceptions.CameraException('Không thể khởi tạo camera controller: $e');
    }
  }

  // Chụp ảnh
  Future<XFile> takePicture() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw app_exceptions.CameraException('Camera chưa được khởi tạo');
      }

      final image = await _controller!.takePicture();
      return image;
    } catch (e) {
      throw app_exceptions.CameraException('Không thể chụp ảnh: $e');
    }
  }

  // Bật/tắt flash
  Future<void> setFlashMode(FlashMode mode) async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw app_exceptions.CameraException('Camera chưa được khởi tạo');
      }

      await _controller!.setFlashMode(mode);
    } catch (e) {
      throw app_exceptions.CameraException('Không thể thay đổi chế độ flash: $e');
    }
  }

  // Zoom camera
  Future<void> setZoomLevel(double zoom) async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw app_exceptions.CameraException('Camera chưa được khởi tạo');
      }

      final maxZoom = await _controller!.getMaxZoomLevel();
      final minZoom = await _controller!.getMinZoomLevel();
      
      final clampedZoom = zoom.clamp(minZoom, maxZoom);
      await _controller!.setZoomLevel(clampedZoom);
    } catch (e) {
      throw app_exceptions.CameraException('Không thể thay đổi mức zoom: $e');
    }
  }

  // Lấy mức zoom hiện tại
  Future<double> getCurrentZoomLevel() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw app_exceptions.CameraException('Camera chưa được khởi tạo');
      }

      // Camera package không có zoomLevel trong value, trả về 1.0 mặc định
      return 1.0;
    } catch (e) {
      throw app_exceptions.CameraException('Không thể lấy mức zoom hiện tại: $e');
    }
  }

  // Lấy mức zoom tối đa
  Future<double> getMaxZoomLevel() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw app_exceptions.CameraException('Camera chưa được khởi tạo');
      }

      return await _controller!.getMaxZoomLevel();
    } catch (e) {
      throw app_exceptions.CameraException('Không thể lấy mức zoom tối đa: $e');
    }
  }

  // Lấy mức zoom tối thiểu
  Future<double> getMinZoomLevel() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw app_exceptions.CameraException('Camera chưa được khởi tạo');
      }

      return await _controller!.getMinZoomLevel();
    } catch (e) {
      throw app_exceptions.CameraException('Không thể lấy mức zoom tối thiểu: $e');
    }
  }

  // Chuyển đổi camera (trước/sau)
  Future<CameraController> switchCamera() async {
    try {
      if (_controller == null) {
        throw app_exceptions.CameraException('Camera chưa được khởi tạo');
      }

      final currentDirection = _controller!.description.lensDirection;
      final newDirection = currentDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      // Dispose controller cũ
      await _controller!.dispose();

      // Tạo controller mới với camera khác
      return await initializeCameraController(direction: newDirection);
    } catch (e) {
      throw app_exceptions.CameraException('Không thể chuyển đổi camera: $e');
    }
  }

  // Kiểm tra camera có sẵn
  bool get isInitialized => _isInitialized;

  // Lấy controller hiện tại
  CameraController? get controller => _controller;

  // Lấy danh sách camera
  List<CameraDescription>? get cameras => _cameras;

  // Kiểm tra có camera trước không
  bool get hasFrontCamera {
    if (_cameras == null) return false;
    return _cameras!.any(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
  }

  // Kiểm tra có camera sau không
  bool get hasBackCamera {
    if (_cameras == null) return false;
    return _cameras!.any(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
  }

  // Kiểm tra có flash không
  bool get hasFlash {
    if (_controller == null) return false;
    return _controller!.value.isInitialized;
  }

  // Dispose resources
  Future<void> dispose() async {
    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }
    } catch (e) {
      // Log error nhưng không throw exception khi dispose
      print('Lỗi khi dispose camera: $e');
    }
  }

  // Yêu cầu quyền camera
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      throw app_exceptions.PermissionException('Không thể yêu cầu quyền camera: $e');
    }
  }

  // Kiểm tra trạng thái quyền camera
  Future<PermissionStatus> getCameraPermissionStatus() async {
    try {
      return await Permission.camera.status;
    } catch (e) {
      throw app_exceptions.PermissionException('Không thể kiểm tra trạng thái quyền camera: $e');
    }
  }
}