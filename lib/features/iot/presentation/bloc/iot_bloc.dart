import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/iot_websocket_datasource.dart';
import 'iot_event.dart';
import 'iot_state.dart';

class IoTBloc extends Bloc<IoTEvent, IoTState> {
  final IoTWebSocketDataSource webSocketDataSource;
  StreamSubscription? _scanEventSubscription;

  IoTBloc({required this.webSocketDataSource}) : super(IoTInitial()) {
    on<IoTConnectRequested>(_onConnectRequested);
    on<IoTDisconnectRequested>(_onDisconnectRequested);
    on<IoTScanEventReceived>(_onScanEventReceived);
    on<IoTStatusCheckRequested>(_onStatusCheckRequested);
  }

  Future<void> _onConnectRequested(
    IoTConnectRequested event,
    Emitter<IoTState> emit,
  ) async {
    emit(IoTConnecting());

    try {
      await webSocketDataSource.connect();

      // Lắng nghe scan events
      _scanEventSubscription = webSocketDataSource.scanEvents.listen(
        (scanEvent) {
          add(IoTScanEventReceived(scanEvent));
        },
      );

      emit(IoTConnected());
    } catch (e) {
      emit(IoTError('Không thể kết nối: $e'));
    }
  }

  Future<void> _onDisconnectRequested(
    IoTDisconnectRequested event,
    Emitter<IoTState> emit,
  ) async {
    await _scanEventSubscription?.cancel();
    webSocketDataSource.disconnect();
    emit(IoTDisconnected());
  }

  Future<void> _onScanEventReceived(
    IoTScanEventReceived event,
    Emitter<IoTState> emit,
  ) async {
    emit(IoTScanReceived(scanEvent: event.scanEvent));
  }

  Future<void> _onStatusCheckRequested(
    IoTStatusCheckRequested event,
    Emitter<IoTState> emit,
  ) async {
    // TODO: Implement status check
  }

  @override
  Future<void> close() {
    _scanEventSubscription?.cancel();
    webSocketDataSource.dispose();
    return super.close();
  }
}
