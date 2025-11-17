class IoTScanEventModel {
  final String deviceId;
  final String scanType; // 'student_card' hoặc 'book_barcode'
  final String scanData; // UID hoặc barcode
  final bool success;
  final Map<String, dynamic>? data; // Thông tin sinh viên hoặc sách
  final String? error;
  final DateTime timestamp;

  IoTScanEventModel({
    required this.deviceId,
    required this.scanType,
    required this.scanData,
    required this.success,
    this.data,
    this.error,
    required this.timestamp,
  });

  factory IoTScanEventModel.fromJson(Map<String, dynamic> json) {
    return IoTScanEventModel(
      deviceId: json['device_id'] ?? '',
      scanType: json['scan_type'] ?? '',
      scanData: json['scan_data'] ?? '',
      success: json['success'] ?? false,
      data: json['data'],
      error: json['error'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'scan_type': scanType,
      'scan_data': scanData,
      'success': success,
      'data': data,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Helper getters
  bool get isStudentScan => scanType == 'student_card';
  bool get isBookScan => scanType == 'book_barcode';

  // Lấy thông tin sinh viên (nếu có)
  Map<String, dynamic>? get studentInfo =>
      isStudentScan && success ? data : null;

  // Lấy thông tin sách (nếu có)
  Map<String, dynamic>? get bookInfo => isBookScan && success ? data : null;
}
