import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/iot_bloc.dart';
import '../bloc/iot_state.dart';

class IoTStatusIndicator extends StatelessWidget {
  const IoTStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IoTBloc, IoTState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBackgroundColor(state),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(state),
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(state),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(IoTState state) {
    if (state is IoTConnected || state is IoTScanReceived) {
      return Colors.green;
    } else if (state is IoTConnecting) {
      return Colors.orange;
    } else if (state is IoTError) {
      return Colors.red;
    }
    return Colors.grey;
  }

  IconData _getIcon(IoTState state) {
    if (state is IoTConnected || state is IoTScanReceived) {
      return Icons.check_circle;
    } else if (state is IoTConnecting) {
      return Icons.sync;
    } else if (state is IoTError) {
      return Icons.error;
    }
    return Icons.cloud_off;
  }

  String _getStatusText(IoTState state) {
    if (state is IoTConnected || state is IoTScanReceived) {
      return 'Trạm IoT: Kết nối';
    } else if (state is IoTConnecting) {
      return 'Đang kết nối...';
    } else if (state is IoTError) {
      return 'Lỗi kết nối';
    }
    return 'Chưa kết nối';
  }
}
