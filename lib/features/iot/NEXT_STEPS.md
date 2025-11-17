# 🚀 Bước Tiếp Theo - Upload Code lên ESP32-CAM

## 📍 Bạn đang ở đây

Bạn đã có:
- ✅ VS Code với PlatformIO
- ✅ ESP32-CAM firmware code
- ✅ Board Explorer đã tìm thấy AI Thinker ESP32-CAM

## 🎯 Tiếp theo làm gì?

### Option 1: Dùng PlatformIO (Bạn đang dùng) ⭐

### Option 2: Chuyển sang Arduino IDE (Dễ hơn)

---

## 🔧 OPTION 1: PlatformIO trong VS Code

### Bước 1: Mở Project ESP32 Firmware

1. **Trong VS Code:**
   - Click `File → Open Folder`
   - Chọn folder: `lib/features/iot/esp32_firmware/`
   - Click **Select Folder**

2. **PlatformIO sẽ tự động:**
   - Detect file `platformio.ini`
   - Download ESP32 platform
   - Download libraries (MFRC522, LiquidCrystal_I2C, ArduinoJson)
   - Đợi 2-3 phút lần đầu

3. **Kiểm tra:**
   - Bạn sẽ thấy thanh công cụ PlatformIO ở dưới cùng
   - Có các icon: ✓ (Build), → (Upload), 🔌 (Monitor), 🗑️ (Clean)

### Bước 2: Cấu hình WiFi & API

1. **Mở file:** `include/config.h`

2. **Tìm và sửa:**
   ```cpp
   // Line 10-12
   #define WIFI_SSID "YOUR_WIFI_SSID"          // ← Sửa thành tên WiFi của bạn
   #define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"  // ← Sửa thành mật khẩu WiFi
   
   // Line 18
   #define API_BASE_URL "http://192.168.1.100:3000"  // ← Sửa thành IP máy server
   ```

3. **Tìm IP máy tính:**
   - Windows: Mở CMD → gõ `ipconfig` → tìm IPv4 Address
   - Ví dụ: `192.168.1.105`

4. **Save file** (`Ctrl+S`)

### Bước 3: Kết nối FTDI Programmer

#### 🔌 Sơ đồ kết nối:

```
FTDI Programmer          ESP32-CAM
----------------         ----------
TX (TXD)        ──────→  RX (GPIO 3 / U0RXD)
RX (RXD)        ──────→  TX (GPIO 1 / U0TXD)
GND             ──────→  GND
5V              ──────→  5V (VCC)
```

#### ⚠️ QUAN TRỌNG: Vào Programming Mode

```
GPIO 0          ──────→  GND (nối tạm thời bằng dây jumper)
```

#### 📝 Các bước:

1. **Cắm FTDI vào USB máy tính**
   - Đợi máy tính nhận diện
   - Windows: Mở Device Manager → Ports (COM & LPT)
   - Ghi nhớ số COM (VD: COM3, COM4, COM5)

2. **Kết nối 4 dây chính:**
   ```
   FTDI TX  → ESP32 RX (GPIO 3)
   FTDI RX  → ESP32 TX (GPIO 1)
   FTDI GND → ESP32 GND
   FTDI 5V  → ESP32 5V
   ```

3. **Vào Programming Mode:**
   - **Nối GPIO 0 với GND** (dùng dây jumper)
   - **Nhấn nút RESET** trên ESP32-CAM
   - **Giữ GPIO 0 nối với GND**

4. **Kiểm tra:**
   - LED trên ESP32-CAM sẽ sáng yếu (đang ở programming mode)

### Bước 4: Cấu hình COM Port

1. **Mở file:** `platformio.ini`

2. **Tìm dòng:**
   ```ini
   upload_port = COM3  ; Thay đổi theo port của bạn
   ```

3. **Sửa thành port của bạn:**
   ```ini
   upload_port = COM4  ; Ví dụ nếu FTDI của bạn là COM4
   ```

4. **Save file**

### Bước 5: Build Project

1. **Click icon ✓ (Build)** ở thanh PlatformIO dưới cùng
   - Hoặc nhấn `Ctrl+Alt+B`

2. **Đợi build:**
   ```
   Building...
   Compiling .pio/build/esp32cam/src/main.cpp.o
   Compiling .pio/build/esp32cam/src/wifi_handler.cpp.o
   Compiling .pio/build/esp32cam/src/lcd_handler.cpp.o
   Compiling .pio/build/esp32cam/src/rfid_handler.cpp.o
   Compiling .pio/build/esp32cam/src/api_client.cpp.o
   Linking .pio/build/esp32cam/firmware.elf
   Building .pio/build/esp32cam/firmware.bin
   ========================= [SUCCESS] Took X.XX seconds =========================
   ```

3. **Nếu thành công:**
   - Thấy `[SUCCESS]` màu xanh
   - Sẵn sàng upload!

4. **Nếu có lỗi:**
   - Đọc error message
   - Thường là thiếu library → PlatformIO sẽ tự download
   - Build lại

### Bước 6: Upload Code

1. **Đảm bảo:**
   - ✅ GPIO 0 đã nối với GND
   - ✅ Đã nhấn Reset
   - ✅ FTDI đã cắm USB

2. **Click icon → (Upload)** ở thanh PlatformIO
   - Hoặc nhấn `Ctrl+Alt+U`

3. **Xem progress:**
   ```
   Uploading .pio/build/esp32cam/firmware.bin
   esptool.py v4.5.1
   Serial port COM4
   Connecting....
   Chip is ESP32-D0WDQ6 (revision v1.0)
   Features: WiFi, BT, Dual Core, 240MHz, VRef calibration in efuse, Coding Scheme None
   Crystal is 40MHz
   MAC: xx:xx:xx:xx:xx:xx
   Uploading stub...
   Running stub...
   Stub running...
   Changing baud rate to 460800
   Changed.
   Writing at 0x00001000... (10 %)
   Writing at 0x00005000... (20 %)
   ...
   Writing at 0x000f0000... (100 %)
   Wrote 1234567 bytes (654321 compressed) at 0x00010000 in 15.2 seconds
   Hash of data verified.
   
   Leaving...
   Hard resetting via RTS pin...
   ========================= [SUCCESS] Took XX.XX seconds =========================
   ```

4. **Nếu thành công:**
   - Thấy `[SUCCESS]` màu xanh
   - Upload xong!

5. **Nếu lỗi "Failed to connect":**
   - Kiểm tra GPIO 0 đã nối GND chưa
   - Nhấn Reset lại
   - Thử lại

### Bước 7: Thoát Programming Mode

1. **Bỏ nối GPIO 0 với GND** (rút dây jumper)
2. **Nhấn nút RESET** lại 1 lần
3. **ESP32 sẽ chạy code** vừa upload

### Bước 8: Kiểm tra Code Hoạt động

1. **Click icon 🔌 (Monitor)** ở thanh PlatformIO
   - Hoặc nhấn `Ctrl+Alt+S`

2. **Serial Monitor sẽ mở và hiển thị:**
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
   Connecting to WiFi...
   .....
   WiFi connected! IP: 192.168.1.50
   [INIT] Initializing RFID reader...
   RFID reader initialized. Version: 0x92
   [SYSTEM] System ready!
   ========================================
   ```

3. **Nếu thấy log trên:**
   - ✅ Upload thành công!
   - ✅ WiFi đã kết nối!
   - ✅ RFID reader đã khởi tạo!
   - ✅ Hệ thống sẵn sàng!

### ✅ Xong! ESP32 đã hoạt động!

---

## 🎨 OPTION 2: Arduino IDE (Dễ hơn)

### Bước 1: Download Arduino IDE

1. Tải từ: https://www.arduino.cc/en/software
2. Cài đặt bình thường

### Bước 2: Thêm ESP32 Board

1. Mở Arduino IDE
2. `File → Preferences`
3. Thêm URL vào **Additional Board Manager URLs:**
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Click OK
5. `Tools → Board → Boards Manager`
6. Tìm: `esp32`
7. Cài: **esp32 by Espressif Systems**
8. Đợi 5-10 phút

### Bước 3: Cài Libraries

1. `Sketch → Include Library → Manage Libraries`
2. Tìm và cài:
   - **MFRC522** by GithubCommunity
   - **LiquidCrystal I2C** by Frank de Brabander
   - **ArduinoJson** by Benoit Blanchon

### Bước 4: Mở Sketch

1. `File → Open`
2. Chọn: `lib/features/iot/esp32_firmware_arduino/esp32_iot_station.ino`

### Bước 5: Cấu hình

Sửa phần đầu file:
```cpp
const char* WIFI_SSID = "TenWiFiCuaBan";        // ← Sửa đây
const char* WIFI_PASSWORD = "MatKhauWiFi";      // ← Sửa đây
const char* API_BASE_URL = "http://192.168.1.100:3000"; // ← Sửa đây
```

### Bước 6: Chọn Board & Port

1. `Tools → Board → ESP32 Arduino → AI Thinker ESP32-CAM`
2. `Tools → Port → COM4` (chọn port của bạn)
3. `Tools → Upload Speed → 115200`

### Bước 7: Kết nối FTDI (giống Option 1)

### Bước 8: Upload

1. Nối GPIO 0 với GND
2. Nhấn Reset
3. Click **Upload** (→)
4. Đợi upload xong
5. Bỏ nối GPIO 0 với GND
6. Nhấn Reset

### Bước 9: Kiểm tra

1. `Tools → Serial Monitor`
2. Chọn baud: **115200**
3. Xem log như Option 1

---

## 🐛 Troubleshooting

### Lỗi: "Failed to connect to ESP32"

**Giải pháp:**
1. Kiểm tra GPIO 0 đã nối GND chưa
2. Nhấn Reset trong khi GPIO 0 nối GND
3. Thử đổi USB cable
4. Thử đổi USB port

### Lỗi: "A fatal error occurred: Timed out"

**Giải pháp:**
1. Kiểm tra kết nối FTDI:
   - FTDI TX → ESP32 RX
   - FTDI RX → ESP32 TX
   - Đừng nhầm TX-TX, RX-RX!
2. Thử swap TX/RX

### Lỗi: "WiFi connection timeout"

**Giải pháp:**
1. Kiểm tra SSID và Password
2. Đảm bảo WiFi là 2.4GHz (ESP32 không hỗ trợ 5GHz)
3. Đặt ESP32 gần router

### Lỗi: "RFID reader not found"

**Giải pháp:**
1. Chưa kết nối RC522 → Bình thường!
2. Kết nối RC522 sau khi test WiFi thành công

---

## 📊 Checklist

### Trước khi Upload
- [ ] Đã cài PlatformIO hoặc Arduino IDE
- [ ] Đã sửa WiFi SSID và Password
- [ ] Đã sửa API_BASE_URL
- [ ] Đã có FTDI Programmer

### Kết nối FTDI
- [ ] FTDI TX → ESP32 RX
- [ ] FTDI RX → ESP32 TX
- [ ] FTDI GND → ESP32 GND
- [ ] FTDI 5V → ESP32 5V
- [ ] GPIO 0 → GND (tạm thời)

### Upload
- [ ] Đã nhấn Reset
- [ ] Upload thành công
- [ ] Đã bỏ nối GPIO 0 với GND
- [ ] Đã nhấn Reset lại

### Kiểm tra
- [ ] Serial Monitor hiển thị log
- [ ] WiFi connected
- [ ] RFID initialized (nếu đã kết nối RC522)
- [ ] System ready

---

## 🎯 Bước Tiếp Theo Sau Khi Upload Thành Công

### 1. Kết nối RC522 RFID Reader

```
RC522          ESP32-CAM
------         ----------
SDA    ──────→ GPIO 13
SCK    ──────→ GPIO 14
MOSI   ──────→ GPIO 15
MISO   ──────→ GPIO 12
RST    ──────→ GPIO 2
GND    ──────→ GND
3.3V   ──────→ 3.3V
```

### 2. Kết nối LCD 16x2 I2C

```
LCD I2C        ESP32-CAM
--------       ----------
SDA    ──────→ GPIO 14
SCL    ──────→ GPIO 15
GND    ──────→ GND
VCC    ──────→ 5V
```

### 3. Test RFID

1. Reset ESP32
2. Đưa thẻ RFID lại gần RC522
3. Serial Monitor sẽ hiển thị: `[RFID] Card detected: A1B2C3D4`
4. LCD hiển thị: `Dang xu ly...`

### 4. Implement Backend API

Xem hướng dẫn trong: `INTEGRATION_GUIDE.md`

### 5. Tích hợp Flutter App

Xem hướng dẫn trong: `INTEGRATION_GUIDE.md`

---

## 💡 Tips

1. **Luôn mở Serial Monitor** để debug
2. **Test WiFi trước** rồi mới kết nối RC522 và LCD
3. **Backup code** trước khi sửa
4. **Ghi nhớ COM Port** để không phải tìm lại

---

## 📞 Cần Hỗ trợ?

- **Xem:** [HARDWARE_SETUP_GUIDE.md](HARDWARE_SETUP_GUIDE.md) - Chi tiết hơn
- **Xem:** [TROUBLESHOOTING section](HARDWARE_SETUP_GUIDE.md#troubleshooting)
- **Check:** Serial Monitor logs

---

**Chúc bạn thành công! 🚀**
