# Hướng dẫn Tích hợp IoT vào BorrowFormScreen

## 1. Thêm Dependencies vào pubspec.yaml

```yaml
dependencies:
  web_socket_channel: ^2.4.0
  flutter_bloc: ^8.1.3  # Đã có
```

Chạy:
```bash
flutter pub get
```

## 2. Khởi tạo IoTBloc trong main.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/iot/data/datasources/iot_websocket_datasource.dart';
import 'features/iot/presentation/bloc/iot_bloc.dart';
import 'features/iot/presentation/bloc/iot_event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ... các BlocProvider khác ...
        
        // Thêm IoTBloc
        BlocProvider(
          create: (context) => IoTBloc(
            webSocketDataSource: IoTWebSocketDataSource(
              wsUrl: 'ws://192.168.1.100:3000/ws/iot', // Thay bằng URL server của bạn
            ),
          )..add(IoTConnectRequested()), // Tự động kết nối khi khởi động
        ),
      ],
      child: MaterialApp(
        // ...
      ),
    );
  }
}
```

## 3. Tích hợp vào BorrowFormScreen

### File: `lib/features/tuan_borrow_management/presentation/screens/borrow_form_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../iot/presentation/widgets/iot_scan_listener.dart';
import '../../../iot/presentation/widgets/iot_status_indicator.dart';
import '../../../iot/presentation/bloc/iot_bloc.dart';
import '../../../iot/presentation/bloc/iot_state.dart';

class BorrowFormScreen extends StatefulWidget {
  @override
  _BorrowFormScreenState createState() => _BorrowFormScreenState();
}

class _BorrowFormScreenState extends State<BorrowFormScreen> {
  // Controllers cho form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mssvController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _bookCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Thẻ Mượn Sách'),
        actions: [
          // Hiển thị trạng thái kết nối IoT
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IoTStatusIndicator(),
          ),
        ],
      ),
      body: IoTScanListener(
        // Callback khi quét thẻ sinh viên
        onStudentScanned: (studentInfo) {
          _autoFillStudentInfo(studentInfo);
        },
        // Callback khi quét sách
        onBookScanned: (bookInfo) {
          _autoFillBookInfo(bookInfo);
        },
        // Callback khi có lỗi
        onScanError: (error) {
          print('Scan error: $error');
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin người mượn
              _buildSectionTitle('Thông tin người mượn'),
              SizedBox(height: 8),
              _buildTextField('Tên người mượn', _nameController),
              _buildTextField('MSSV', _mssvController),
              _buildTextField('Lớp', _classController),
              _buildTextField('Số điện thoại', _phoneController),
              _buildTextField('Email', _emailController),
              
              SizedBox(height: 24),
              
              // Thông tin sách
              _buildSectionTitle('Thông tin sách'),
              SizedBox(height: 8),
              _buildTextField('Tên sách', _bookTitleController),
              _buildTextField('Mã sách', _bookCodeController),
              
              SizedBox(height: 24),
              
              // Nút tạo thẻ mượn
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createBorrowCard,
                  child: Text('Tạo Thẻ Mượn'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // Auto-fill thông tin sinh viên từ IoT scan
  void _autoFillStudentInfo(Map<String, dynamic> studentInfo) {
    setState(() {
      _nameController.text = studentInfo['name'] ?? '';
      _mssvController.text = studentInfo['mssv'] ?? '';
      _classController.text = studentInfo['class'] ?? '';
      _phoneController.text = studentInfo['phone'] ?? '';
      _emailController.text = studentInfo['email'] ?? '';
    });
  }

  // Auto-fill thông tin sách từ IoT scan
  void _autoFillBookInfo(Map<String, dynamic> bookInfo) {
    setState(() {
      _bookTitleController.text = bookInfo['title'] ?? '';
      _bookCodeController.text = bookInfo['code'] ?? '';
    });
  }

  void _createBorrowCard() {
    // TODO: Implement tạo thẻ mượn
    print('Creating borrow card...');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mssvController.dispose();
    _classController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bookTitleController.dispose();
    _bookCodeController.dispose();
    super.dispose();
  }
}
```

## 4. Cấu hình Backend API

Backend cần có các endpoints sau:

### POST /api/iot/scan-student-card
Request:
```json
{
  "card_uid": "A1B2C3D4",
  "device_id": "IOT_STATION_01",
  "timestamp": 1234567890
}
```

Response (Success):
```json
{
  "success": true,
  "student": {
    "mssv": "2021001234",
    "name": "Nguyễn Văn A",
    "class": "CNTT-K15",
    "phone": "0912345678",
    "email": "nguyenvana@example.com"
  }
}
```

Response (Error):
```json
{
  "success": false,
  "error": "Không tìm thấy thông tin sinh viên"
}
```

### POST /api/iot/scan-book-barcode
Request:
```json
{
  "barcode": "BK001234",
  "device_id": "IOT_STATION_01",
  "timestamp": 1234567890
}
```

Response (Success):
```json
{
  "success": true,
  "book": {
    "id": "123",
    "title": "Lập trình Flutter",
    "code": "BK001234",
    "author": "Nguyễn Văn B",
    "available": true
  }
}
```

### WebSocket /ws/iot
Backend push realtime events đến Flutter app:

```json
{
  "device_id": "IOT_STATION_01",
  "scan_type": "student_card",
  "scan_data": "A1B2C3D4",
  "success": true,
  "data": {
    "mssv": "2021001234",
    "name": "Nguyễn Văn A",
    "class": "CNTT-K15",
    "phone": "0912345678",
    "email": "nguyenvana@example.com"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 5. Testing

### Test 1: Kết nối WebSocket
1. Chạy backend server
2. Chạy Flutter app
3. Kiểm tra IoTStatusIndicator hiển thị "Kết nối"

### Test 2: Quét thẻ sinh viên
1. Quét thẻ RFID trên trạm IoT
2. Kiểm tra SnackBar hiển thị "✅ Đã quét thẻ sinh viên"
3. Kiểm tra form tự động điền thông tin

### Test 3: Quét sách
1. Quét barcode sách trên trạm IoT
2. Kiểm tra SnackBar hiển thị "✅ Đã quét sách"
3. Kiểm tra form tự động điền thông tin sách

## 6. Troubleshooting

### Lỗi: "WebSocket connection failed"
- Kiểm tra URL WebSocket trong main.dart
- Kiểm tra backend server đang chạy
- Kiểm tra firewall

### Lỗi: "IoT status: Chưa kết nối"
- Kiểm tra IoTBloc đã được khởi tạo trong main.dart
- Kiểm tra IoTConnectRequested event đã được gọi

### Form không tự động điền
- Kiểm tra IoTScanListener đã wrap BorrowFormScreen
- Kiểm tra callbacks onStudentScanned và onBookScanned
- Kiểm tra data format từ backend

## 7. Next Steps

1. ✅ Implement backend API endpoints
2. ✅ Setup WebSocket server
3. ✅ Test với ESP32-CAM thật
4. ✅ Thêm sound effects khi quét thành công
5. ✅ Thêm vibration feedback
