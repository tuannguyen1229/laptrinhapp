# 🔧 Cấu hình cho ESP32-S3-CAM

## ⚠️ QUAN TRỌNG: ESP32-S3-CAM khác với ESP32-CAM!

ESP32-S3-CAM có:
- ✅ USB built-in (không cần FTDI!)
- ✅ GPIO pins khác
- ✅ Mạnh hơn (dual-core Xtensa LX7)
- ✅ RAM nhiều hơn (512KB SRAM)

---

## 🔌 So sánh GPIO Pins

### ESP32-CAM (AI-Thinker) - Code hiện tại
```cpp
// RFID RC522 (SPI)
#define RFID_CS_PIN 13
#define RFID_RST_PIN 2
#define RFID_SCK_PIN 14
#define RFID_MOSI_PIN 15
#define RFID_MISO_PIN 12

// LCD I2C
#define LCD_SDA_PIN 14
#define LCD_SCL_PIN 15

// Button
#define SCAN_BUTTON_PIN 0
```

### ESP32-S3-CAM (Freenove/XIAO) - Cần thay đổi
```cpp
// RFID RC522 (SPI)
#define RFID_CS_PIN 10      // ← Thay đổi
#define RFID_RST_PIN 9      // ← Thay đổi
#define RFID_SCK_PIN 12     // ← Thay đổi
#define RFID_MOSI_PIN 11    // ← Thay đổi
#define RFID_MISO_PIN 13    // ← Thay đổi

// LCD I2C
#define LCD_SDA_PIN 4       // ← Thay đổi
#define LCD_SCL_PIN 5       // ← Thay đổi

// Button
#define SCAN_BUTTON_PIN 0   // ← Giữ nguyên (Boot button)
```

---

## 📝 Thay đổi Code

### Option 1: Sửa file config.h (PlatformIO)

Mở file: `lib/features/iot/esp32_firmware/include/config.h`

**Tìm dòng 40-50 và thay đổi:**

```cpp
// ============================================
// RFID RC522 Pin Configuration (SPI)
// ============================================
// ESP32-CAM (AI-Thinker) - Comment out
// #define RFID_CS_PIN 13
// #define RFID_RST_PIN 2
// #define RFID_SCK_PIN 14
// #define RFID_MOSI_PIN 15
// #define RFID_MISO_PIN 12

// ESP32-S3-CAM - Uncomment
#define RFID_CS_PIN 10      // ← Dùng cho S3
#define RFID_RST_PIN 9      // ← Dùng cho S3
#define RFID_SCK_PIN 12     // ← Dùng cho S3
#define RFID_MOSI_PIN 11    // ← Dùng cho S3
#define RFID_MISO_PIN 13    // ← Dùng cho S3

// ============================================
// LCD 16x2 I2C Configuration
// ============================================
// ESP32-CAM (AI-Thinker) - Comment out
// #define LCD_SDA_PIN 14
// #define LCD_SCL_PIN 15

// ESP32-S3-CAM - Uncomment
#define LCD_SDA_PIN 4       // ← Dùng cho S3
#define LCD_SCL_PIN 5       // ← Dùng cho S3
```

### Option 2: Sửa file Arduino .ino

Mở file: `lib/features/iot/esp32_firmware_arduino/esp32_iot_station.ino`

**Tìm dòng 35-45 và thay đổi:**

```cpp
// Pin configuration
// ESP32-CAM (AI-Thinker) - Comment out
// #define RFID_CS_PIN 13
// #define RFID_RST_PIN 2
// #define RFID_SCK_PIN 14
// #define RFID_MOSI_PIN 15
// #define RFID_MISO_PIN 12

// ESP32-S3-CAM - Uncomment
#define RFID_CS_PIN 10
#define RFID_RST_PIN 9
#define RFID_SCK_PIN 12
#define RFID_MOSI_PIN 11
#define RFID_MISO_PIN 13

// LCD I2C
// ESP32-CAM (AI-Thinker) - Comment out
// #define LCD_SDA_PIN 14
// #define LCD_SCL_PIN 15

// ESP32-S3-CAM - Uncomment
#define LCD_SDA_PIN 4
#define LCD_SCL_PIN 5
```

---

## 🔌 Sơ đồ Kết nối Mới

### RC522 RFID → ESP32-S3-CAM

```
RC522          ESP32-S3-CAM
------         -------------
SDA    ──────→ GPIO 10 (CS)
SCK    ──────→ GPIO 12 (SCK)
MOSI   ──────→ GPIO 11 (MOSI)
MISO   ──────→ GPIO 13 (MISO)
RST    ──────→ GPIO 9
GND    ──────→ GND
3.3V   ──────→ 3.3V
```

### LCD 16x2 I2C → ESP32-S3-CAM

```
LCD I2C        ESP32-S3-CAM
--------       -------------
SDA    ──────→ GPIO 4
SCL    ──────→ GPIO 5
GND    ──────→ GND
VCC    ──────→ 5V
```

---

## 📤 Upload Code (ESP32-S3-CAM)

### ✅ Ưu điểm: KHÔNG CẦN FTDI!

ESP32-S3-CAM có **USB built-in**, bạn chỉ cần:
1. Cắm USB-C cable trực tiếp vào ESP32-S3-CAM
2. Không cần FTDI Programmer!

### Bước 1: Kết nối USB

1. **Cắm USB-C cable** vào ESP32-S3-CAM
2. **Cắm đầu kia** vào máy tính
3. **Đợi** máy tính nhận diện (1-2 giây)

### Bước 2: Vào Programming Mode

**Cách 1: Nhấn nút Boot**
1. Giữ nút **BOOT** (hoặc GPIO 0)
2. Nhấn nút **RESET**
3. Thả nút RESET
4. Thả nút BOOT

**Cách 2: Tự động (nếu có)**
- Một số board S3 tự động vào programming mode
- Thử upload trực tiếp, nếu không được thì dùng Cách 1

### Bước 3: Chọn Board

#### PlatformIO

Sửa file `platformio.ini`:

```ini
[env:esp32s3cam]
platform = espressif32
board = esp32-s3-devkitc-1  ; ← Thay đổi board
framework = arduino

; Hoặc nếu có board cụ thể:
; board = freenove_esp32_s3_cam
; board = xiao_esp32s3

monitor_speed = 115200

lib_deps = 
    miguelbalboa/MFRC522@^1.4.11
    marcoschwartz/LiquidCrystal_I2C@^1.1.4
    bblanchon/ArduinoJson@^6.21.4

upload_speed = 921600
upload_port = COM4  ; Thay đổi theo port của bạn
```

#### Arduino IDE

1. `Tools → Board → ESP32 Arduino → ESP32S3 Dev Module`
2. Hoặc: `Tools → Board → ESP32 Arduino → Freenove ESP32-S3-CAM`
3. `Tools → Port → COM4` (chọn port của bạn)
4. `Tools → USB CDC On Boot → Enabled`
5. `Tools → Upload Speed → 921600`

### Bước 4: Upload

1. **PlatformIO:** Click icon → (Upload)
2. **Arduino IDE:** Click Upload (→)
3. Nếu lỗi, thử nhấn Boot + Reset như Bước 2

---

## 🔍 Kiểm tra

### Serial Monitor

Giống như ESP32-CAM thường:
```
========================================
  ESP32-CAM IoT Station
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

---

## 📊 So sánh ESP32-CAM vs ESP32-S3-CAM

| Tính năng | ESP32-CAM | ESP32-S3-CAM |
|-----------|-----------|--------------|
| **CPU** | Dual-core 240MHz | Dual-core 240MHz |
| **RAM** | 520KB SRAM | 512KB SRAM |
| **Flash** | 4MB | 8MB |
| **USB** | ❌ Cần FTDI | ✅ USB-C built-in |
| **Camera** | OV2640 | OV2640/OV5640 |
| **WiFi** | 2.4GHz | 2.4GHz |
| **Bluetooth** | BT 4.2 | BLE 5.0 |
| **GPIO** | Khác | Khác |
| **Giá** | ~100k | ~150-200k |

---

## ⚠️ Lưu ý Quan trọng

### 1. GPIO Pins khác nhau
- **Phải thay đổi** pin definitions trong code
- Không thể dùng code ESP32-CAM trực tiếp

### 2. USB built-in
- ✅ Không cần FTDI Programmer
- ✅ Dễ upload hơn
- ✅ Có thể debug qua USB

### 3. Board trong Arduino IDE
- Chọn đúng board: `ESP32S3 Dev Module`
- Hoặc board cụ thể nếu có (Freenove, XIAO)

### 4. Camera pins
- Camera pins cũng khác
- Nếu dùng camera, cần config riêng

---

## 🔧 Troubleshooting ESP32-S3-CAM

### Lỗi: "Failed to connect"

**Giải pháp:**
1. Nhấn Boot + Reset như hướng dẫn
2. Thử đổi USB cable
3. Thử đổi USB port
4. Enable "USB CDC On Boot" trong Arduino IDE

### Lỗi: "RFID reader not found"

**Giải pháp:**
1. Kiểm tra đã sửa GPIO pins chưa
2. Kiểm tra kết nối RC522:
   - SDA → GPIO 10
   - SCK → GPIO 12
   - MOSI → GPIO 11
   - MISO → GPIO 13
   - RST → GPIO 9

### Lỗi: "LCD not responding"

**Giải pháp:**
1. Kiểm tra đã sửa I2C pins chưa:
   - SDA → GPIO 4
   - SCL → GPIO 5
2. Thử đổi địa chỉ I2C (0x27 hoặc 0x3F)

---

## 📝 Checklist cho ESP32-S3-CAM

### Code Changes
- [ ] Đã sửa RFID pins (10, 9, 12, 11, 13)
- [ ] Đã sửa LCD I2C pins (4, 5)
- [ ] Đã sửa WiFi SSID và Password
- [ ] Đã sửa API_BASE_URL

### Hardware
- [ ] Có USB-C cable
- [ ] Không cần FTDI (S3 có USB built-in)
- [ ] RC522 kết nối đúng pins mới
- [ ] LCD I2C kết nối đúng pins mới

### Upload
- [ ] Chọn board: ESP32S3 Dev Module
- [ ] Chọn đúng COM Port
- [ ] Enable USB CDC On Boot
- [ ] Upload thành công

### Test
- [ ] Serial Monitor hiển thị log
- [ ] WiFi connected
- [ ] RFID initialized
- [ ] LCD hiển thị "San sang!"

---

## 🎯 Tóm tắt

**ESP32-S3-CAM khác ESP32-CAM:**
1. ✅ USB built-in (không cần FTDI)
2. ⚠️ GPIO pins khác (phải sửa code)
3. ✅ Mạnh hơn, nhiều RAM hơn
4. ✅ Upload dễ hơn

**Cần làm:**
1. Sửa GPIO pins trong code
2. Kết nối RC522 và LCD theo pins mới
3. Cắm USB-C trực tiếp
4. Upload code

---

**Chúc bạn thành công với ESP32-S3-CAM! 🚀**
