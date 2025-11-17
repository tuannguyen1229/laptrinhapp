# ⚡ Quick Reference - ESP32-CAM Upload

## 🎯 Bạn cần gì?

### Hardware
- ✅ ESP32-CAM
- ✅ FTDI Programmer (FT232RL hoặc CH340G)
- ✅ Dây jumper (4-5 sợi)
- ✅ USB cable

### Software
- ✅ VS Code + PlatformIO (hoặc Arduino IDE)
- ✅ Code đã có sẵn trong `lib/features/iot/`

---

## 🔌 Kết nối FTDI → ESP32-CAM

```
FTDI          ESP32-CAM
----          ---------
TX    ──────→ RX (GPIO 3)
RX    ──────→ TX (GPIO 1)
GND   ──────→ GND
5V    ──────→ 5V

Programming Mode:
GPIO 0 ─────→ GND (nối tạm)
```

---

## ⚙️ Cấu hình Code

### File: `include/config.h` (PlatformIO)
```cpp
#define WIFI_SSID "TenWiFi"
#define WIFI_PASSWORD "MatKhau"
#define API_BASE_URL "http://192.168.1.100:3000"
```

### File: `esp32_iot_station.ino` (Arduino)
```cpp
const char* WIFI_SSID = "TenWiFi";
const char* WIFI_PASSWORD = "MatKhau";
const char* API_BASE_URL = "http://192.168.1.100:3000";
```

---

## 📤 Upload Steps

### PlatformIO
1. Mở folder: `lib/features/iot/esp32_firmware/`
2. Sửa `include/config.h`
3. Sửa `platformio.ini` → `upload_port = COM4`
4. Nối GPIO 0 → GND
5. Nhấn Reset
6. Click icon → (Upload)
7. Bỏ nối GPIO 0 → GND
8. Nhấn Reset

### Arduino IDE
1. Mở file: `esp32_iot_station.ino`
2. Sửa WiFi & API ở đầu file
3. `Tools → Board → AI Thinker ESP32-CAM`
4. `Tools → Port → COM4`
5. Nối GPIO 0 → GND
6. Nhấn Reset
7. Click Upload (→)
8. Bỏ nối GPIO 0 → GND
9. Nhấn Reset

---

## 🔍 Kiểm tra

### Serial Monitor (115200 baud)
```
========================================
  ESP32-CAM IoT Station
========================================
[INIT] Connecting to WiFi...
WiFi connected! IP: 192.168.1.50
[INIT] Initializing RFID reader...
RFID reader initialized. Version: 0x92
[SYSTEM] System ready!
========================================
```

### LCD Display
```
San sang!
Quet the/sach
```

---

## 🐛 Lỗi Thường Gặp

| Lỗi | Giải pháp |
|-----|-----------|
| Failed to connect | GPIO 0 → GND, nhấn Reset |
| Timed out | Check TX/RX, thử swap |
| WiFi timeout | Check SSID/Password, dùng 2.4GHz |
| RFID not found | Chưa kết nối RC522 → OK |

---

## 📊 Kết nối Đầy đủ

### RC522 RFID → ESP32-CAM
```
SDA  → GPIO 13
SCK  → GPIO 14
MOSI → GPIO 15
MISO → GPIO 12
RST  → GPIO 2
GND  → GND
3.3V → 3.3V
```

### LCD I2C → ESP32-CAM
```
SDA → GPIO 14
SCL → GPIO 15
GND → GND
VCC → 5V
```

---

## 🚀 Commands

### PlatformIO Terminal
```bash
# Build
pio run

# Upload
pio run --target upload

# Monitor
pio device monitor

# Clean
pio run --target clean
```

### Arduino IDE
```
Ctrl+R  - Verify/Compile
Ctrl+U  - Upload
Ctrl+Shift+M - Serial Monitor
```

---

## 📁 Files Quan trọng

| File | Mục đích |
|------|----------|
| `NEXT_STEPS.md` | Hướng dẫn chi tiết |
| `HARDWARE_SETUP_GUIDE.md` | Setup đầy đủ |
| `QUICK_START.md` | Bắt đầu nhanh |
| `include/config.h` | Cấu hình WiFi/API |

---

## 💡 Tips

1. **Luôn nối GPIO 0 → GND** trước khi upload
2. **Nhấn Reset** sau khi nối GPIO 0
3. **Bỏ nối GPIO 0** sau khi upload xong
4. **Nhấn Reset** lại để chạy code
5. **Mở Serial Monitor** để debug

---

## 🎯 Workflow

```
1. Sửa config.h (WiFi, API)
   ↓
2. Kết nối FTDI
   ↓
3. Nối GPIO 0 → GND
   ↓
4. Nhấn Reset
   ↓
5. Upload code
   ↓
6. Bỏ nối GPIO 0
   ↓
7. Nhấn Reset
   ↓
8. Mở Serial Monitor
   ↓
9. Kiểm tra log
```

---

## 📞 Tài liệu Chi tiết

- **Upload code:** [NEXT_STEPS.md](NEXT_STEPS.md)
- **Hardware setup:** [HARDWARE_SETUP_GUIDE.md](HARDWARE_SETUP_GUIDE.md)
- **Quick start:** [QUICK_START.md](QUICK_START.md)
- **Troubleshooting:** [HARDWARE_SETUP_GUIDE.md#troubleshooting](HARDWARE_SETUP_GUIDE.md#troubleshooting)

---

**Print this page for quick reference! 📄**
