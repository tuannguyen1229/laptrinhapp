import '../../data/models/iot_scan_event_model.dart';
import '../../data/models/iot_device_status_model.dart';

abstract class IoTState {}

class IoTInitial extends IoTState {}

class IoTConnecting extends IoTState {}

class IoTConnected extends IoTState {
  final List<IoTDeviceStatusModel> devices;

  IoTConnected({this.devices = const []});
}

class IoTDisconnected extends IoTState {}

class IoTError extends IoTState {
  final String message;

  IoTError(this.message);
}

class IoTScanReceived extends IoTState {
  final IoTScanEventModel scanEvent;
  final List<IoTDeviceStatusModel> devices;

  IoTScanReceived({
    required this.scanEvent,
    this.devices = const [],
  });
}
