import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/iot_scan_event_model.dart';

class IoTWebSocketDataSource {
  WebSocketChannel? _channel;
  final String wsUrl;
  final _scanEventController = StreamController<IoTScanEventModel>.broadcast();
  bool _isConnected = false;

  IoTWebSocketDataSource({required this.wsUrl});

  Stream<IoTScanEventModel> get scanEvents => _scanEventController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          _isConnected = false;
          print('[IoT WebSocket] Error: $error');
        },
        onDone: () {
          _isConnected = false;
          print('[IoT WebSocket] Connection closed');
        },
      );

      print('[IoT WebSocket] Connected to $wsUrl');
    } catch (e) {
      _isConnected = false;
      print('[IoT WebSocket] Connection failed: $e');
      rethrow;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> json = jsonDecode(message);
      final event = IoTScanEventModel.fromJson(json);
      _scanEventController.add(event);
    } catch (e) {
      print('[IoT WebSocket] Failed to parse message: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _scanEventController.close();
  }
}
