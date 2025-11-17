# ESP32-S3-CAM IoT Station - Arduino Version

## 📝 Giới thiệu

Đây là **phiên bản Arduino IDE** của ESP32-S3-CAM firmware, dễ sử dụng hơn cho người quen với Arduino.

**Ưu điểm ESP32-S3-CAM:**
- ✅ USB-C built-in (không cần FTDI Programmer!)
- ✅ Upload code dễ dàng hơn
- ✅ Mạnh hơn ESP32-CAM thường

## 🔧 Yêu cầu

### Hardware
- ESP32-S3-CAM (with USB-C built-in)
- USB-C Cable (không cần FTDI!)
- RC522 RFID Reader
- LCD 16x2 I2C
- Breadboard + Dây nối

### Software
- Arduino IDE 1.8.x hoặc 2.x
- ESP32 Board Package
- Libraries: MFRC522, LiquidCrystal_I2C, ArduinoJson

## 🚀 Quick Start

### 1. Cài đặt Arduino IDE

Download từ: https://www.arduino.cc/en/software

### 2. Thêm ESP32 Board

1. Mở Arduino IDE
2. `File → Preferences`
3. Thêm URL vào **Additional Board Manager URLs:**
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. `Tools → Board → Boards Manager`
5. Tìm và cài: **esp32 by Espressif Systems**

### 3. Cài đặt Libraries

`Sketch → Include Library → Manage Libraries`

Cài các libraries sau:
- **MFRC522** by GithubCommunity
- **LiquidCrystal I2C** by Frank de Brabander  
- **ArduinoJson** by Benoit Blanchon

### 4. Mở Sketch

1. `File → Open`
2. Chọn: `esp32_iot_station.ino`

### 5. Cấu hình

Sửa phần **CONFIGURATION** ở đầu file:

```cpp
// WiFi credentials
const char* WIFI_SSID = "TenWiFiCuaBan";        // ← Sửa đây
const char* WIFI_PASSWORD = "MatKhauWiFi";      // ← Sửa đây

// API endpoint
const char* API_BASE_URL = "http://192.168.1.100:3000"; // ← Sửa đây
```

### 6. Chọn Board & Port

- `Tools → Board → ESP32 Arduino → ESP32S3 Dev Module`
- `Tools → USB CDC On Boot → Enabled` (Quan trọng!)
- `Tools → Port → COM3` (chọn port của bạn)
- `Tools → Upload Speed → 921600`

### 7. Kết nối USB-C

```
USB-C Cable → ESP32-S3-CAM
-----------------------------
Cắm trực tiếp vào cổng USB-C của ESP32-S3-CAM
Không cần FTDI Programmer!

Programming Mode (nếu cần):
- Giữ nút BOOT
- Nhấn nút RESET
- Thả RESET
- Thả BOOT
```

### 8. Upload

1. Cắm USB-C vào ESP32-S3-CAM
2. Click **Upload** (→)
3. Nếu lỗi, thử: Giữ BOOT → Nhấn RESET → Thả RESET → Thả BOOT
4. Đợi upload xong
5. Nhấn RESET để chạy code

### 9. Kiểm tra

1. Mở Serial Monitor (`Tools → Serial Monitor`)
2. Chọn baud rate: **115200**
3. Bạn sẽ thấy:

```
========================================
  ESP32-S3-CAM IoT Station
  Tram Quet The & Sach Tu dong
========================================
Device ID: IOT_STATION_01
Location: Quay Thu Vien Tang 1
========================================

[INIT] Initializing LCD...
[INIT] Connecting to WiFi...
WiFi connected! IP: 192.168.1.50
[INIT] Initializing RFID reader...
RFID reader initialized. Version: 0x92
[SYSTEM] System ready!
========================================
```

## 🔌 Sơ đồ Kết nối

### RC522 RFID → ESP32-S3-CAM
```
SDA  → GPIO 10
SCK  → GPIO 12
MOSI → GPIO 11
MISO → GPIO 13
RST  → GPIO 9
GND  → GND
3.3V → 3.3V
```

### LCD I2C → ESP32-S3-CAM
```
SDA → GPIO 4
SCL → GPIO 5
GND → GND
VCC → 5V
```

## 🐛 Troubleshooting

### LCD không hiển thị

Thử đổi địa chỉ I2C:

```cpp
#define LCD_ADDRESS 0x27  // Thử 0x3F nếu không hoạt động
```

Hoặc chạy I2C Scanner:
```
File → Examples → Wire → i2c_scanner
```

### RFID không đọc được

1. Kiểm tra kết nối 7 dây
2. Đảm bảo nguồn 3.3V (không phải 5V!)
3. Thử module RC522 khác

### WiFi không kết nối

1. Kiểm tra SSID và Password
2. Đảm bảo WiFi là 2.4GHz (ESP32 không hỗ trợ 5GHz)
3. Đặt ESP32 gần router

### Upload failed

1. Kiểm tra GPIO 0 đã nối GND chưa
2. Nhấn Reset trong khi GPIO 0 nối GND
3. Thử đổi USB cable
4. Kiểm tra TX/RX không nhầm

## 📚 Code Structure

```cpp
// Configuration
const char* WIFI_SSID = "...";
const char* API_BASE_URL = "...";

// Global objects
MFRC522 rfid(...);
LiquidCrystal_I2C lcd(...);

// Setup
void setup() {
  // Initialize WiFi, RFID, LCD
}

// Main loop
void loop() {
  // Check RFID card
  // Send to API
  // Display on LCD
}

// Helper functions
String getCardUID();
void scanStudentCard(String uid);
void displayStudent(String name, String mssv);
```

## 🎯 Features

✅ WiFi connection với auto-reconnect  
✅ RFID RC522 reader với debounce  
✅ LCD 16x2 I2C display  
✅ HTTP REST API client  
✅ JSON parsing  
✅ Heartbeat monitoring  
✅ Error handling  

## 📝 API Format

### Request: Scan Student Card
```json
POST /api/iot/scan-student-card
{
  "card_uid": "A1B2C3D4",
  "device_id": "IOT_STATION_01",
  "timestamp": 1234567890
}
```

### Response: Success
```json
{
  "success": true,
  "student": {
    "mssv": "2021001234",
    "name": "Nguyen Van A",
    "class": "CNTT-K15",
    "phone": "0912345678",
    "email": "nguyenvana@example.com"
  }
}
```

### Response: Error
```json
{
  "success": false,
  "error": "Khong tim thay"
}
```

## 🔄 Workflow

1. ESP32 khởi động → Kết nối WiFi
2. Khởi tạo RFID reader và LCD
3. Hiển thị "San sang!" trên LCD
4. Chờ quét thẻ RFID
5. Khi có thẻ → Đọc UID
6. Gửi request lên API
7. Nhận response và hiển thị trên LCD
8. Sau 5 giây → Quay lại bước 3

## 💡 Tips

1. **Luôn mở Serial Monitor** để debug
2. **Test từng bước** - WiFi → RFID → LCD → API
3. **Backup code** trước khi sửa
4. **Ghi nhớ COM Port** của FTDI
5. **Kiểm tra kết nối** nếu có lỗi

## 📞 Support

- **Arduino Forum:** https://forum.arduino.cc/
- **ESP32 Forum:** https://www.esp32.com/
- **MFRC522 Library:** https://github.com/miguelbalboa/rfid

## 🎓 Next Steps

1. ✅ Upload code thành công
2. ✅ Test RFID reader
3. ✅ Test LCD display
4. ⏳ Implement Backend API
5. ⏳ Tích hợp Flutter app
6. ⏳ Test end-to-end

---

**Chúc bạn thành công! 🚀**

Xem hướng dẫn chi tiết tại: [HARDWARE_SETUP_GUIDE.md](../HARDWARE_SETUP_GUIDE.md)
