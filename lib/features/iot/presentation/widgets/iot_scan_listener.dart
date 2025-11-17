import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/iot_bloc.dart';
import '../bloc/iot_state.dart';
import '../../data/models/iot_scan_event_model.dart';

/// Widget để lắng nghe sự kiện quét từ trạm IoT
/// Sử dụng trong BorrowFormScreen để auto-fill form
class IoTScanListener extends StatelessWidget {
  final Widget child;
  final Function(Map<String, dynamic> studentInfo)? onStudentScanned;
  final Function(Map<String, dynamic> bookInfo)? onBookScanned;
  final Function(String error)? onScanError;

  const IoTScanListener({
    Key? key,
    required this.child,
    this.onStudentScanned,
    this.onBookScanned,
    this.onScanError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<IoTBloc, IoTState>(
      listener: (context, state) {
        if (state is IoTScanReceived) {
          _handleScanEvent(context, state.scanEvent);
        }
      },
      child: child,
    );
  }

  void _handleScanEvent(BuildContext context, IoTScanEventModel event) {
    if (event.success) {
      if (event.isStudentScan && event.studentInfo != null) {
        // Quét thẻ sinh viên thành công
        _showSuccessSnackBar(
          context,
          '✅ Đã quét thẻ sinh viên: ${event.studentInfo!['name']}',
        );
        onStudentScanned?.call(event.studentInfo!);
      } else if (event.isBookScan && event.bookInfo != null) {
        // Quét sách thành công
        _showSuccessSnackBar(
          context,
          '✅ Đã quét sách: ${event.bookInfo!['title']}',
        );
        onBookScanned?.call(event.bookInfo!);
      }
    } else {
      // Quét thất bại
      _showErrorSnackBar(
        context,
        '❌ ${event.error ?? "Không tìm thấy thông tin"}',
      );
      onScanError?.call(event.error ?? 'Unknown error');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
