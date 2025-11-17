# ✅ IoT Implementation Checklist

## 📦 Phase 1: Chuẩn bị (1-2 ngày)

### Mua sắm Linh kiện
- [ ] ESP32-CAM module (~100k)
- [ ] FTDI Programmer (~40k)
- [ ] RC522 RFID Reader + thẻ (~60k)
- [ ] LCD 16x2 I2C (~70k)
- [ ] Power Bank 10,000mAh (~200k)
- [ ] Breadboard + Dây nối (~60k)
- [ ] LED + Buzzer (optional, ~15k)

**Tổng: ~530,000 VNĐ**

### Setup Môi trường
- [ ] Cài đặt VS Code
- [ ] Cài đặt PlatformIO extension
- [ ] Cài đặt Flutter SDK
- [ ] Clone project code

## 🔌 Phase 2: Kết nối Phần cứng (30 phút)

### Kết nối RC522 → ESP32-CAM
- [ ] SDA → GPIO 13
- [ ] SCK → GPIO 14
- [ ] MOSI → GPIO 15
- [ ] MISO → GPIO 12
- [ ] RST → GPIO 2
- [ ] GND → GND
- [ ] 3.3V → 3.3V

### Kết nối LCD I2C → ESP32-CAM
- [ ] SDA → GPIO 14
- [ ] SCL → GPIO 15
- [ ] GND → GND
- [ ] VCC → 5V

### Kết nối Power
- [ ] Power Bank 5V → ESP32 5V
- [ ] Power Bank GND → ESP32 GND


## 💻 Phase 3: Upload Firmware (15 phút)

### Cấu hình
- [ ] Mở `features/iot/esp32_firmware/` trong VS Code
- [ ] Chỉnh sửa `include/config.h`:
  - [ ] WIFI_SSID
  - [ ] WIFI_PASSWORD
  - [ ] API_BASE_URL

### Upload
- [ ] Kết nối FTDI Programmer với ESP32-CAM
- [ ] Nối GPIO 0 với GND (programming mode)
- [ ] Nhấn nút Reset
- [ ] Click "Upload" trong PlatformIO
- [ ] Đợi upload hoàn tất
- [ ] Bỏ nối GPIO 0 với GND
- [ ] Nhấn Reset lại

### Verify
- [ ] Mở Serial Monitor (115200 baud)
- [ ] Thấy log "WiFi connected!"
- [ ] Thấy log "RFID reader initialized"
- [ ] LCD hiển thị "San sang!"

## 🧪 Phase 4: Test Phần cứng (30 phút)

### Test WiFi
- [ ] ESP32 kết nối WiFi thành công
- [ ] Serial Monitor hiển thị IP address
- [ ] Ping được IP từ máy tính

### Test RFID
- [ ] Đưa thẻ RFID lại gần RC522
- [ ] LCD hiển thị "Dang xu ly..."
- [ ] Serial Monitor hiển thị Card UID
- [ ] LED nhấp nháy (nếu có)

### Test LCD
- [ ] LCD hiển thị text rõ ràng
- [ ] Backlight hoạt động
- [ ] Hiển thị đúng 2 dòng 16 ký tự

## 🌐 Phase 5: Backend API (2-3 ngày)

### Database Migration
- [ ] Thêm cột `rfid_card_uid` vào bảng `users`
- [ ] Thêm cột `barcode` vào bảng `books`
- [ ] Tạo bảng `iot_devices`
- [ ] Tạo bảng `iot_scan_logs`

### API Endpoints
- [ ] POST `/api/iot/scan-student-card`
- [ ] POST `/api/iot/scan-book-barcode`
- [ ] POST `/api/iot/heartbeat`
- [ ] WebSocket `/ws/iot`

### Test API
- [ ] Test với Postman
- [ ] Test với ESP32 thật
- [ ] Verify database logs

## 📱 Phase 6: Flutter Integration (1 ngày)

### Dependencies
- [ ] Thêm `web_socket_channel: ^2.4.0` vào pubspec.yaml
- [ ] Run `flutter pub get`

### Setup IoTBloc
- [ ] Thêm IoTBloc vào main.dart
- [ ] Configure WebSocket URL
- [ ] Test connection

### Modify BorrowFormScreen
- [ ] Wrap với IoTScanListener
- [ ] Add IoTStatusIndicator
- [ ] Implement onStudentScanned callback
- [ ] Implement onBookScanned callback
- [ ] Test auto-fill form

## 🎯 Phase 7: End-to-End Testing (1 ngày)

### Test Flow: Quét Thẻ Sinh Viên
- [ ] Quét thẻ RFID trên trạm IoT
- [ ] ESP32 gửi request lên API
- [ ] Backend trả về thông tin sinh viên
- [ ] LCD hiển thị thông tin
- [ ] Flutter app nhận WebSocket event
- [ ] Form tự động điền thông tin
- [ ] SnackBar hiển thị thành công

### Test Flow: Quét Sách (nếu có camera)
- [ ] Nhấn nút quét
- [ ] Camera chụp ảnh barcode
- [ ] Decode barcode
- [ ] ESP32 gửi request lên API
- [ ] Backend trả về thông tin sách
- [ ] LCD hiển thị thông tin
- [ ] Flutter app nhận event
- [ ] Form tự động điền

### Test Error Handling
- [ ] Quét thẻ không tồn tại → Hiển thị lỗi
- [ ] Mất kết nối WiFi → Auto reconnect
- [ ] API timeout → Retry
- [ ] WebSocket disconnect → Reconnect

## 🚀 Phase 8: Deployment (1-2 ngày)

### Đăng ký Thẻ RFID
- [ ] Mua/phát thẻ RFID cho sinh viên
- [ ] Quét và lưu UID vào database
- [ ] Link UID với MSSV

### In Barcode cho Sách
- [ ] Generate barcode từ mã sách
- [ ] In barcode stickers
- [ ] Dán lên tất cả sách

### Lắp đặt Trạm IoT
- [ ] Đặt trạm tại quầy thư viện
- [ ] Kết nối WiFi ổn định
- [ ] Sạc đầy power bank
- [ ] Test hoạt động

### Training
- [ ] Đào tạo thủ thư sử dụng
- [ ] Tạo user manual
- [ ] Setup support channel

## 📊 Progress Tracking

- [ ] Phase 1: Chuẩn bị (0%)
- [ ] Phase 2: Kết nối phần cứng (0%)
- [ ] Phase 3: Upload firmware (0%)
- [ ] Phase 4: Test phần cứng (0%)
- [ ] Phase 5: Backend API (0%)
- [ ] Phase 6: Flutter integration (0%)
- [ ] Phase 7: End-to-end testing (0%)
- [ ] Phase 8: Deployment (0%)

**Tổng tiến độ: 0% → 100%**

## 🎓 Notes

- Mỗi phase có thể làm song song nếu có nhiều người
- Backend API có thể làm trước khi có phần cứng
- Flutter integration có thể test với mock data
- Camera barcode là optional, có thể bỏ qua

## 📞 Support

Nếu gặp vấn đề:
1. Check Serial Monitor logs
2. Xem Troubleshooting trong README
3. Review code comments
4. Check hardware connections

---

**Good luck! 🚀**
