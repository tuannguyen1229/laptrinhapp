# ESP32-S3-CAM Firmware - Trạm Quét IoT

## 📋 Tổng quan

Firmware cho ESP32-S3-CAM để:
- Đọc thẻ RFID (RC522)
- Quét barcode bằng camera OV2640
- Hiển thị thông tin trên LCD 16x2 I2C
- Gửi dữ liệu lên server qua WiFi

## 🛠️ Phần cứng Cần thiết

### Linh kiện Chính
1. **ESP32-S3-CAM** (with USB-C) - ~150,000 VNĐ
2. **USB-C Cable** (không cần FTDI!) - ~20,000 VNĐ
3. **RC522 RFID Reader** - ~60,000 VNĐ
4. **LCD 16x2 I2C** - ~70,000 VNĐ
5. **Power Bank 10,000mAh** - ~200,000 VNĐ
6. **Breadboard + Dây nối** - ~60,000 VNĐ

**Tổng: ~560,000 VNĐ**

**Ưu điểm ESP32-S3-CAM:**
- ✅ USB-C built-in (không cần FTDI Programmer!)
- ✅ Upload code dễ dàng hơn
- ✅ Mạnh hơn, nhiều RAM hơn

### Sơ đồ Kết nối

```
RC522 RFID Reader → ESP32-CAM
----------------------------------
SDA    → GPIO 13 (CS)
SCK    → GPIO 14 (SCK)
MOSI   → GPIO 15 (MOSI)
MISO   → GPIO 12 (MISO)
RST    → GPIO 2
GND    → GND
3.3V   → 3.3V

LCD 16x2 I2C → ESP32-CAM
----------------------------------
SDA    → GPIO 14 (Software I2C)
SCL    → GPIO 15 (Software I2C)
GND    → GND
VCC    → 5V

Power Bank → ESP32-CAM
----------------------------------
5V OUT → 5V (VCC)
GND    → GND
```

## 🔧 Setup Môi trường Phát triển

### 1. Cài đặt PlatformIO

**Option A: VS Code Extension**
1. Mở VS Code
2. Cài extension "PlatformIO IDE"
3. Restart VS Code

**Option B: CLI**
```bash
pip install platformio
```

### 2. Clone và Mở Project

```bash
cd features/iot/esp32_firmware
pio init
```

### 3. Cài đặt Dependencies

Dependencies đã được config trong `platformio.ini`:
- MFRC522 (RFID)
- LiquidCrystal_I2C (LCD)
- ArduinoJson (JSON parsing)
- PubSubClient (MQTT - optional)

PlatformIO sẽ tự động tải khi build.

## 📝 Cấu hình

### 1. WiFi Configuration

Chỉnh sửa file `include/config.h`:

```cpp
// WiFi credentials
#define WIFI_SSID "TenWiFi"
#define WIFI_PASSWORD "MatKhauWiFi"

// API endpoint
#define API_BASE_URL "http://192.168.1.100:3000"
#define API_SCAN_STUDENT "/api/iot/scan-student-card"
#define API_SCAN_BOOK "/api/iot/scan-book-barcode"

// Device ID
#define DEVICE_ID "IOT_STATION_01"
```

### 2. Pin Configuration

Đã được config sẵn trong `include/config.h`. Chỉ thay đổi nếu cần:

```cpp
// RFID RC522 pins
#define RFID_CS_PIN 13
#define RFID_RST_PIN 2
#define RFID_SCK_PIN 14
#define RFID_MOSI_PIN 15
#define RFID_MISO_PIN 12

// LCD I2C pins
#define LCD_SDA_PIN 14
#define LCD_SCL_PIN 15
#define LCD_ADDRESS 0x27

// Button pin
#define SCAN_BUTTON_PIN 0  // Boot button
```

## 🚀 Build và Upload

### 1. Kết nối FTDI Programmer

```
FTDI → ESP32-CAM
-----------------
TX   → RX (GPIO 3)
RX   → TX (GPIO 1)
GND  → GND
5V   → 5V

Để vào chế độ programming:
- Nối GPIO 0 với GND
- Nhấn nút Reset
- Bỏ nối GPIO 0 với GND
```

### 2. Build Project

```bash
pio run
```

### 3. Upload Firmware

```bash
pio run --target upload
```

### 4. Monitor Serial

```bash
pio device monitor
```

## 🧪 Testing

### Test 1: WiFi Connection
1. Upload firmware
2. Mở Serial Monitor
3. Kiểm tra log: "WiFi connected! IP: xxx.xxx.xxx.xxx"

### Test 2: RFID Reader
1. Đưa thẻ RFID lại gần RC522
2. Kiểm tra LCD hiển thị: "Dang xu ly..."
3. Kiểm tra Serial log: "Card UID: A1B2C3D4"

### Test 3: Camera Barcode Scan
1. Nhấn nút SCAN (GPIO 0)
2. Đưa barcode vào trước camera
3. Kiểm tra LCD hiển thị kết quả
4. Kiểm tra Serial log: "Barcode: BK001234"

### Test 4: API Communication
1. Đảm bảo backend API đang chạy
2. Quét thẻ RFID
3. Kiểm tra Serial log: "API Response: 200 OK"
4. Kiểm tra LCD hiển thị thông tin sinh viên

## 📊 Serial Monitor Output Mẫu

```
=== ESP32-CAM IoT Station ===
Device ID: IOT_STATION_01
Connecting to WiFi...
WiFi connected! IP: 192.168.1.50
RFID Reader initialized
Camera initialized
LCD initialized
System ready!

[RFID] Card detected: A1B2C3D4
[API] Sending request to: http://192.168.1.100:3000/api/iot/scan-student-card
[API] Response: 200 OK
[API] Student: Nguyen Van A - MSSV: 2021001234
[LCD] Displaying student info

[CAMERA] Scan button pressed
[CAMERA] Capturing image...
[CAMERA] Decoding barcode...
[CAMERA] Barcode found: BK001234
[API] Sending request to: http://192.168.1.100:3000/api/iot/scan-book-barcode
[API] Response: 200 OK
[API] Book: Lap trinh Flutter - Code: BK001234
[LCD] Displaying book info
```

## 🐛 Troubleshooting

### Lỗi: "WiFi connection failed"
- Kiểm tra SSID và password trong `config.h`
- Đảm bảo WiFi là 2.4GHz (ESP32 không hỗ trợ 5GHz)
- Kiểm tra tín hiệu WiFi

### Lỗi: "RFID reader not found"
- Kiểm tra kết nối dây RC522
- Kiểm tra nguồn 3.3V
- Thử đổi pin CS (GPIO 13)

### Lỗi: "Camera initialization failed"
- Reset ESP32-CAM
- Kiểm tra camera module đã cắm chặt chưa
- Thử giảm resolution trong code

### Lỗi: "LCD not responding"
- Kiểm tra địa chỉ I2C (0x27 hoặc 0x3F)
- Chạy I2C scanner để tìm địa chỉ đúng
- Kiểm tra kết nối SDA/SCL

### Lỗi: "API timeout"
- Kiểm tra backend API đang chạy
- Kiểm tra URL trong `config.h`
- Ping server từ ESP32: `ping 192.168.1.100`

## 📚 Code Structure

```
src/
├── main.cpp                 # Entry point, setup() và loop()
├── rfid_handler.cpp         # Xử lý RFID RC522
├── camera_handler.cpp       # Xử lý Camera + quét barcode
├── barcode_decoder.cpp      # Decode barcode từ ảnh
├── lcd_handler.cpp          # Xử lý LCD display
├── wifi_handler.cpp         # Xử lý WiFi connection
└── api_client.cpp           # HTTP client gọi API

include/
├── config.h                 # Configuration constants
├── rfid_handler.h
├── camera_handler.h
├── barcode_decoder.h
├── lcd_handler.h
├── wifi_handler.h
└── api_client.h
```

## 🔄 Workflow

1. **Khởi động**: ESP32 kết nối WiFi, khởi tạo RFID, Camera, LCD
2. **Chờ quét**: Hiển thị "San sang" trên LCD
3. **Quét thẻ RFID**: 
   - Đọc UID → Gửi API → Nhận thông tin sinh viên → Hiển thị LCD
4. **Quét barcode**:
   - Nhấn nút → Chụp ảnh → Decode → Gửi API → Nhận thông tin sách → Hiển thị LCD
5. **Lặp lại**: Quay về bước 2

## 📞 Support

Nếu gặp vấn đề, kiểm tra:
1. Serial Monitor output
2. LED status trên ESP32-CAM
3. Kết nối phần cứng
4. Backend API logs

## 🎯 Next Steps

1. ✅ Setup phần cứng theo sơ đồ
2. ✅ Upload firmware
3. ✅ Test từng module
4. ✅ Tích hợp với backend API
5. ✅ Test end-to-end với Flutter app
