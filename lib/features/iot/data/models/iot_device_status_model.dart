class IoTDeviceStatusModel {
  final String deviceId;
  final String deviceName;
  final String location;
  final String status; // 'online', 'offline', 'error'
  final DateTime? lastHeartbeat;
  final int? signalStrength;
  final String? ipAddress;

  IoTDeviceStatusModel({
    required this.deviceId,
    required this.deviceName,
    required this.location,
    required this.status,
    this.lastHeartbeat,
    this.signalStrength,
    this.ipAddress,
  });

  factory IoTDeviceStatusModel.fromJson(Map<String, dynamic> json) {
    return IoTDeviceStatusModel(
      deviceId: json['device_id'] ?? '',
      deviceName: json['device_name'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'offline',
      lastHeartbeat: json['last_heartbeat'] != null
          ? DateTime.parse(json['last_heartbeat'])
          : null,
      signalStrength: json['signal_strength'],
      ipAddress: json['ip_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'location': location,
      'status': status,
      'last_heartbeat': lastHeartbeat?.toIso8601String(),
      'signal_strength': signalStrength,
      'ip_address': ipAddress,
    };
  }

  bool get isOnline => status == 'online';
  bool get isOffline => status == 'offline';
  bool get hasError => status == 'error';
}
