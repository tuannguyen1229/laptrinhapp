import '../../data/models/iot_scan_event_model.dart';

abstract class IoTEvent {}

class IoTConnectRequested extends IoTEvent {}

class IoTDisconnectRequested extends IoTEvent {}

class IoTScanEventReceived extends IoTEvent {
  final IoTScanEventModel scanEvent;

  IoTScanEventReceived(this.scanEvent);
}

class IoTStatusCheckRequested extends IoTEvent {}
