# ✅ Đã Thay Đổi Sang ESP32-S3-CAM

## 🎉 Hoàn thành!

Tất cả code đã được cập nhật từ **ESP32-CAM** sang **ESP32-S3-CAM**!

---

## 📝 Những gì đã thay đổi:

### 1. GPIO Pins (Quan trọng nhất!)

| Chức năng | ESP32-CAM (Cũ) | ESP32-S3-CAM (Mới) |
|-----------|-----------------|---------------------|
| **RFID CS** | GPIO 13 | GPIO 10 ✅ |
| **RFID RST** | GPIO 2 | GPIO 9 ✅ |
| **RFID SCK** | GPIO 14 | GPIO 12 ✅ |
| **RFID MOSI** | GPIO 15 | GPIO 11 ✅ |
| **RFID MISO** | GPIO 12 | GPIO 13 ✅ |
| **LCD SDA** | GPIO 14 | GPIO 4 ✅ |
| **LCD SCL** | GPIO 15 | GPIO 5 ✅ |
| **Button** | GPIO 0 | GPIO 0 (giữ nguyên) |

### 2. Files đã cập nhật:

✅ **lib/features/iot/esp32_firmware/include/config.h**
- Đã sửa RFID pins
- Đã sửa LCD I2C pins
- Đã sửa camera model

✅ **lib/features/iot/esp32_firmware/platformio.ini**
- Board: `esp32cam` → `esp32-s3-devkitc-1`

✅ **lib/features/iot/esp32_firmware/src/main.cpp**
- Title: "ESP32-CAM" → "ESP32-S3-CAM"

✅ **lib/features/iot/esp32_firmware/src/lcd_handler.cpp**
- Thêm `Wire.begin(LCD_SDA_PIN, LCD_SCL_PIN)` để init I2C với pins mới

✅ **lib/features/iot/esp32_firmware_arduino/esp32_iot_station.ino**
- Đã sửa tất cả GPIO pins
- Đã thêm I2C initialization
- Title: "ESP32-CAM" → "ESP32-S3-CAM"

✅ **lib/features/iot/esp32_firmware/README.md**
- Cập nhật hardware list
- Cập nhật connection diagram
- Thêm note về USB-C

✅ **lib/features/iot/esp32_firmware_arduino/README.md**
- Cập nhật board selection
- Cập nhật upload instructions
- Không cần FTDI nữa!

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

### Power
```
Power Bank     ESP32-S3-CAM
----------     -------------
5V OUT ──────→ 5V (VCC)
GND    ──────→ GND
```

---

## 🚀 Upload Code (Dễ hơn!)

### ✅ Ưu điểm ESP32-S3-CAM:

**KHÔNG CẦN FTDI PROGRAMMER!**

ESP32-S3-CAM có **USB-C built-in**, chỉ cần:

1. **Cắm USB-C cable** trực tiếp vào ESP32-S3-CAM
2. **Cắm đầu kia** vào máy tính
3. **Upload code** ngay!

### PlatformIO

1. Mở folder: `lib/features/iot/esp32_firmware/`
2. Sửa `include/config.h` (WiFi, API)
3. Click icon → (Upload)
4. Nếu lỗi: Giữ BOOT → Nhấn RESET → Upload

### Arduino IDE

1. Mở file: `esp32_iot_station.ino`
2. Sửa WiFi và API ở đầu file
3. `Tools → Board → ESP32S3 Dev Module`
4. `Tools → USB CDC On Boot → Enabled` ⚠️ Quan trọng!
5. `Tools → Port → COM4`
6. Click Upload (→)
7. Nếu lỗi: Giữ BOOT → Nhấn RESET → Upload

---

## 📊 So sánh

| Tính năng | ESP32-CAM | ESP32-S3-CAM |
|-----------|-----------|--------------|
| **Upload** | Cần FTDI | ✅ USB-C trực tiếp |
| **GPIO** | Khác | Khác (đã sửa) |
| **RAM** | 520KB | 512KB |
| **Flash** | 4MB | 8MB |
| **CPU** | 240MHz | 240MHz |
| **Giá** | ~100k | ~150k |
| **Dễ dùng** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## ✅ Checklist

### Code đã sửa:
- [x] GPIO pins cho RFID (10, 9, 12, 11, 13)
- [x] GPIO pins cho LCD I2C (4, 5)
- [x] I2C initialization với pins mới
- [x] Board config trong platformio.ini
- [x] Tất cả README files
- [x] Tất cả comments trong code

### Bạn cần làm:
- [ ] Kết nối RC522 theo pins mới
- [ ] Kết nối LCD theo pins mới
- [ ] Sửa WiFi SSID và Password
- [ ] Sửa API_BASE_URL
- [ ] Cắm USB-C vào ESP32-S3-CAM
- [ ] Upload code
- [ ] Test!

---

## 🎯 Bước Tiếp Theo

### 1. Kết nối Phần cứng

Kết nối RC522 và LCD theo sơ đồ mới ở trên.

### 2. Sửa Config

**File:** `lib/features/iot/esp32_firmware/include/config.h`

```cpp
#define WIFI_SSID "TenWiFiCuaBan"
#define WIFI_PASSWORD "MatKhauWiFi"
#define API_BASE_URL "http://192.168.1.100:3000"
```

### 3. Upload Code

**PlatformIO:**
```bash
cd lib/features/iot/esp32_firmware
pio run --target upload
```

**Arduino IDE:**
- Mở `esp32_iot_station.ino`
- Chọn board: ESP32S3 Dev Module
- Enable USB CDC On Boot
- Click Upload

### 4. Test

Mở Serial Monitor (115200 baud):
```
========================================
  ESP32-S3-CAM IoT Station
  Tram Quet The & Sach Tu dong
========================================
WiFi connected! IP: 192.168.1.50
RFID reader initialized. Version: 0x92
System ready!
========================================
```

---

## 💡 Tips

1. **USB-C cable chất lượng tốt** - Một số cable chỉ sạc, không truyền data
2. **Enable USB CDC On Boot** - Quan trọng cho Arduino IDE
3. **Giữ BOOT + Nhấn RESET** - Nếu upload lỗi
4. **Test từng bước** - WiFi → RFID → LCD

---

## 🐛 Troubleshooting

### Lỗi: "Failed to connect"
- Giữ nút BOOT
- Nhấn nút RESET
- Thả RESET
- Thả BOOT
- Upload lại

### Lỗi: "RFID not found"
- Kiểm tra kết nối theo pins mới:
  - SDA → GPIO 10
  - SCK → GPIO 12
  - MOSI → GPIO 11
  - MISO → GPIO 13
  - RST → GPIO 9

### Lỗi: "LCD not responding"
- Kiểm tra I2C pins:
  - SDA → GPIO 4
  - SCL → GPIO 5
- Thử đổi địa chỉ: 0x27 hoặc 0x3F

---

## 📞 Tài liệu

- **Upload guide:** [NEXT_STEPS.md](NEXT_STEPS.md)
- **Hardware setup:** [HARDWARE_SETUP_GUIDE.md](HARDWARE_SETUP_GUIDE.md)
- **Quick reference:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

**Tất cả đã sẵn sàng cho ESP32-S3-CAM! 🎉**

**Bước tiếp theo:** Kết nối phần cứng và upload code! 🚀
