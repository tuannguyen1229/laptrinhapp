# 🔌 Hướng dẫn Kết nối Phần cứng ESP32-CAM

## 🎯 2 Cách Upload Code lên ESP32-CAM

### ✅ CÁCH 1: Dùng PlatformIO trong VS Code (Khuyến nghị)
### ✅ CÁCH 2: Dùng Arduino IDE (Nếu bạn quen)

---

## 📱 CÁCH 1: PlatformIO trong VS Code

### Bước 1: Cài đặt PlatformIO Extension (5 phút)

1. **Mở VS Code** (hoặc Kiro IDE nếu có extension support)

2. **Cài extension PlatformIO:**
   - Nhấn `Ctrl+Shift+X` (Windows) hoặc `Cmd+Shift+X` (Mac)
   - Tìm kiếm: `PlatformIO IDE`
   - Click **Install**
   - Đợi cài đặt xong (có thể mất 2-3 phút)
   - **Restart VS Code**

3. **Verify cài đặt:**
   - Sau khi restart, bạn sẽ thấy icon PlatformIO (con kiến) ở sidebar bên trái
   - Hoặc nhấn `Ctrl+Shift+P` và gõ `PlatformIO`

### Bước 2: Mở Project ESP32 (1 phút)

1. **Mở folder ESP32:**
   ```
   File → Open Folder → Chọn: lib/features/iot/esp32_firmware/
   ```

2. **PlatformIO sẽ tự động:**
   - Detect file `platformio.ini`
   - Download các libraries cần thiết
   - Setup build environment
   - Đợi 2-3 phút lần đầu

3. **Kiểm tra:**
   - Bạn sẽ thấy thanh công cụ PlatformIO ở dưới cùng màn hình
   - Có các nút: Build, Upload, Monitor, Clean, etc.

### Bước 3: Cấu hình WiFi & API (2 phút)

1. **Mở file:** `include/config.h`

2. **Chỉnh sửa:**
   ```cpp
   // Thay đổi thông tin WiFi của bạn
   #define WIFI_SSID "TenWiFiCuaBan"           // ← Sửa đây
   #define WIFI_PASSWORD "MatKhauWiFi"         // ← Sửa đây
   
   // Thay đổi địa chỉ server (IP máy tính chạy backend)
   #define API_BASE_URL "http://192.168.1.100:3000"  // ← Sửa đây
   ```

3. **Tìm IP máy tính:**
   - Windows: Mở CMD → gõ `ipconfig` → tìm IPv4 Address
   - Mac/Linux: Mở Terminal → gõ `ifconfig` → tìm inet

4. **Save file** (`Ctrl+S`)

### Bước 4: Kết nối FTDI Programmer với ESP32-CAM (5 phút)

#### 🔌 Sơ đồ kết nối:

```
FTDI Programmer          ESP32-CAM
----------------         ----------
TX (TXD)        ──────→  RX (GPIO 3 / U0RXD)
RX (RXD)        ──────→  TX (GPIO 1 / U0TXD)
GND             ──────→  GND
5V              ──────→  5V (VCC)

Để vào Programming Mode:
GPIO 0          ──────→  GND (nối tạm thời)
```

#### 📝 Chi tiết từng bước:

1. **Cắm FTDI vào USB máy tính**
   - Đợi máy tính nhận diện (driver tự động cài)
   - Windows: Kiểm tra Device Manager → Ports (COM & LPT) → ghi nhớ số COM (VD: COM3)

2. **Kết nối dây:**
   ```
   FTDI TX  → ESP32 RX (GPIO 3)
   FTDI RX  → ESP32 TX (GPIO 1)
   FTDI GND → ESP32 GND
   FTDI 5V  → ESP32 5V
   ```

3. **Vào Programming Mode:**
   - **Nối GPIO 0 với GND** (dùng dây jumper)
   - **Nhấn nút RESET** trên ESP32-CAM (nút nhỏ trên board)
   - **Giữ GPIO 0 nối với GND** trong khi nhấn Reset

4. **Kiểm tra kết nối:**
   - LED trên ESP32-CAM sẽ sáng yếu (đang ở programming mode)

### Bước 5: Upload Code (3 phút)

#### Option A: Dùng PlatformIO GUI (Dễ nhất)

1. **Chọn COM Port:**
   - Mở file `platformio.ini`
   - Tìm dòng: `upload_port = COM3`
   - Sửa `COM3` thành port của bạn (VD: COM4, COM5)
   - Save file

2. **Upload:**
   - Click nút **Upload** (→) ở thanh công cụ dưới cùng
   - Hoặc nhấn `Ctrl+Alt+U`
   - Đợi build và upload (2-3 phút lần đầu)

3. **Xem progress:**
   ```
   Building...
   Compiling...
   Linking...
   Uploading...
   Success! ✓
   ```

#### Option B: Dùng Terminal (Nếu GUI không hoạt động)

```bash
# Trong VS Code Terminal (Ctrl+`)
cd lib/features/iot/esp32_firmware

# Build project
pio run

# Upload (thay COM3 bằng port của bạn)
pio run --target upload --upload-port COM3

# Hoặc để PlatformIO tự detect port
pio run --target upload
```

### Bước 6: Thoát Programming Mode (30 giây)

1. **Bỏ nối GPIO 0 với GND** (rút dây jumper)
2. **Nhấn nút RESET** lại 1 lần
3. **ESP32 sẽ chạy code** vừa upload

### Bước 7: Kiểm tra Code Hoạt động (2 phút)

1. **Mở Serial Monitor:**
   - Click nút **Monitor** (🔌) ở thanh PlatformIO
   - Hoặc nhấn `Ctrl+Alt+S`
   - Chọn baud rate: **115200**

2. **Bạn sẽ thấy:**
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

3. **Kiểm tra LCD:**
   - LCD sẽ hiển thị:
   ```
   San sang!
   Quet the/sach
   ```

4. **Test RFID:**
   - Đưa thẻ RFID lại gần RC522
   - Serial Monitor sẽ hiển thị: `[RFID] Card detected: A1B2C3D4`
   - LCD hiển thị: `Dang xu ly...`

### ✅ Xong! ESP32 đã hoạt động!

---

## 🎨 CÁCH 2: Dùng Arduino IDE (Nếu bạn quen)

### Bước 1: Cài đặt Arduino IDE & ESP32 Board (10 phút)

1. **Download Arduino IDE:**
   - Tải từ: https://www.arduino.cc/en/software
   - Cài đặt bình thường

2. **Thêm ESP32 Board:**
   - Mở Arduino IDE
   - `File → Preferences`
   - Trong **Additional Board Manager URLs**, thêm:
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
   - Click OK

3. **Cài ESP32 Board:**
   - `Tools → Board → Boards Manager`
   - Tìm: `esp32`
   - Cài đặt: **esp32 by Espressif Systems**
   - Đợi download xong (có thể mất 5-10 phút)

4. **Chọn Board:**
   - `Tools → Board → ESP32 Arduino → AI Thinker ESP32-CAM`

### Bước 2: Cài đặt Libraries (5 phút)

1. **Mở Library Manager:**
   - `Sketch → Include Library → Manage Libraries`

2. **Cài các libraries sau:**
   - Tìm và cài: `MFRC522` (by GithubCommunity)
   - Tìm và cài: `LiquidCrystal I2C` (by Frank de Brabander)
   - Tìm và cài: `ArduinoJson` (by Benoit Blanchon)

### Bước 3: Chuyển Code từ PlatformIO sang Arduino (10 phút)

**Tôi sẽ tạo file Arduino sketch cho bạn:**

1. **Tạo folder mới:**
   ```
   lib/features/iot/esp32_firmware_arduino/
   ```

2. **Copy tất cả code từ `src/` và `include/`**

3. **Tạo file `.ino` chính**

Để tôi tạo version Arduino cho bạn:



### Bước 4: Upload Code Arduino (5 phút)

1. **Mở file sketch:**
   - `File → Open`
   - Chọn: `lib/features/iot/esp32_firmware_arduino/esp32_iot_station.ino`

2. **Chỉnh sửa WiFi & API:**
   - Tìm phần `CONFIGURATION` ở đầu file
   - Sửa:
   ```cpp
   const char* WIFI_SSID = "TenWiFiCuaBan";
   const char* WIFI_PASSWORD = "MatKhauWiFi";
   const char* API_BASE_URL = "http://192.168.1.100:3000";
   ```

3. **Chọn Board & Port:**
   - `Tools → Board → ESP32 Arduino → AI Thinker ESP32-CAM`
   - `Tools → Port → COM3` (chọn port của bạn)
   - `Tools → Upload Speed → 115200`

4. **Kết nối FTDI** (giống Cách 1):
   - Nối GPIO 0 với GND
   - Nhấn Reset
   - Giữ GPIO 0 nối GND

5. **Upload:**
   - Click nút **Upload** (→) hoặc `Ctrl+U`
   - Đợi compile và upload (2-3 phút)
   - Thấy "Done uploading" là thành công

6. **Thoát Programming Mode:**
   - Bỏ nối GPIO 0 với GND
   - Nhấn Reset

7. **Mở Serial Monitor:**
   - `Tools → Serial Monitor`
   - Chọn baud rate: **115200**
   - Xem log như Cách 1

### ✅ Xong! Code Arduino đã chạy!

---

## 🔧 Troubleshooting

### Lỗi: "Failed to connect to ESP32"

**Nguyên nhân:** Không vào được programming mode

**Giải pháp:**
1. Kiểm tra GPIO 0 đã nối với GND chưa
2. Nhấn Reset trong khi GPIO 0 nối GND
3. Thử đổi USB cable
4. Thử đổi USB port khác

### Lỗi: "A fatal error occurred: Timed out waiting for packet header"

**Nguyên nhân:** Kết nối FTDI không đúng

**Giải pháp:**
1. Kiểm tra lại kết nối:
   - FTDI TX → ESP32 RX
   - FTDI RX → ESP32 TX
   - Đừng nhầm TX-TX, RX-RX!
2. Kiểm tra nguồn 5V
3. Thử swap TX/RX nếu vẫn lỗi

### Lỗi: "WiFi connection timeout"

**Nguyên nhân:** Sai SSID/Password hoặc WiFi 5GHz

**Giải pháp:**
1. Kiểm tra SSID và Password trong code
2. Đảm bảo WiFi là 2.4GHz (ESP32 không hỗ trợ 5GHz)
3. Đặt ESP32 gần router
4. Thử restart router

### Lỗi: "RFID reader not found"

**Nguyên nhân:** Kết nối RC522 sai hoặc lỏng

**Giải pháp:**
1. Kiểm tra lại tất cả dây kết nối RC522
2. Đảm bảo nguồn 3.3V (không phải 5V!)
3. Kiểm tra SPI pins đúng chưa
4. Thử module RC522 khác nếu có

### Lỗi: "LCD not responding"

**Nguyên nhân:** Địa chỉ I2C sai

**Giải pháp:**
1. Thử đổi địa chỉ trong code:
   ```cpp
   #define LCD_ADDRESS 0x27  // Thử 0x3F nếu không hoạt động
   ```
2. Chạy I2C Scanner để tìm địa chỉ đúng:
   ```cpp
   // Upload sketch I2C Scanner từ Arduino Examples
   File → Examples → Wire → i2c_scanner
   ```
3. Kiểm tra kết nối SDA/SCL

### Lỗi: "API connection failed"

**Nguyên nhân:** Backend chưa chạy hoặc sai URL

**Giải pháp:**
1. Kiểm tra backend API đang chạy
2. Ping IP server từ máy tính:
   ```bash
   ping 192.168.1.100
   ```
3. Kiểm tra firewall không block port 3000
4. Thử truy cập API từ browser:
   ```
   http://192.168.1.100:3000/api/iot/heartbeat
   ```

---

## 📊 So sánh 2 Cách

| Tiêu chí | PlatformIO | Arduino IDE |
|----------|------------|-------------|
| **Dễ cài đặt** | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Dễ sử dụng** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Tốc độ compile** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Quản lý libraries** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Code organization** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Debugging** | ⭐⭐⭐⭐ | ⭐⭐ |

**Khuyến nghị:**
- **Dùng PlatformIO** nếu bạn quen VS Code và muốn code chuyên nghiệp
- **Dùng Arduino IDE** nếu bạn đã quen và muốn đơn giản

---

## 🎯 Checklist Hoàn chỉnh

### Trước khi Upload
- [ ] Đã cài PlatformIO hoặc Arduino IDE
- [ ] Đã cài các libraries cần thiết
- [ ] Đã sửa WiFi SSID và Password trong code
- [ ] Đã sửa API_BASE_URL đúng IP máy server
- [ ] Đã kiểm tra địa chỉ I2C của LCD (0x27 hoặc 0x3F)

### Kết nối Phần cứng
- [ ] FTDI TX → ESP32 RX
- [ ] FTDI RX → ESP32 TX
- [ ] FTDI GND → ESP32 GND
- [ ] FTDI 5V → ESP32 5V
- [ ] RC522 đã kết nối đúng (7 dây)
- [ ] LCD I2C đã kết nối đúng (4 dây)

### Upload Code
- [ ] Đã nối GPIO 0 với GND
- [ ] Đã nhấn Reset
- [ ] Đã chọn đúng COM Port
- [ ] Upload thành công
- [ ] Đã bỏ nối GPIO 0 với GND
- [ ] Đã nhấn Reset lại

### Kiểm tra Hoạt động
- [ ] Serial Monitor hiển thị "WiFi connected"
- [ ] Serial Monitor hiển thị "RFID reader initialized"
- [ ] Serial Monitor hiển thị "System ready"
- [ ] LCD hiển thị "San sang!"
- [ ] Quét thẻ RFID → LCD hiển thị "Dang xu ly..."
- [ ] Serial Monitor hiển thị Card UID

---

## 💡 Tips Hữu ích

### Tip 1: Luôn mở Serial Monitor
Để debug dễ dàng, luôn mở Serial Monitor khi test

### Tip 2: Test từng bước
- Test WiFi trước
- Test RFID sau
- Test LCD cuối
- Test API cuối cùng

### Tip 3: Backup code
Trước khi sửa code, backup lại để dễ rollback

### Tip 4: Ghi chú COM Port
Ghi nhớ COM Port của FTDI để không phải tìm lại

### Tip 5: Dùng Power Bank tốt
Chọn power bank có chế độ "always on" để không tự tắt

### Tip 6: Kiểm tra kết nối
Nếu có lỗi, kiểm tra lại tất cả dây kết nối trước

### Tip 7: Đọc Serial Log
Serial Monitor sẽ cho biết chính xác lỗi ở đâu

---

## 📞 Cần Hỗ trợ?

### Tài liệu tham khảo:
- **PlatformIO:** https://docs.platformio.org/
- **Arduino ESP32:** https://docs.espressif.com/projects/arduino-esp32/
- **MFRC522:** https://github.com/miguelbalboa/rfid
- **LiquidCrystal_I2C:** https://github.com/johnrickman/LiquidCrystal_I2C

### Video hướng dẫn:
- **ESP32-CAM Upload:** https://www.youtube.com/results?search_query=esp32+cam+upload+code
- **FTDI Programming:** https://www.youtube.com/results?search_query=esp32+cam+ftdi+programmer

### Community:
- **Arduino Forum:** https://forum.arduino.cc/
- **ESP32 Forum:** https://www.esp32.com/

---

## ✅ Tổng kết

Bạn đã biết cách:
1. ✅ Upload code lên ESP32-CAM bằng PlatformIO
2. ✅ Upload code lên ESP32-CAM bằng Arduino IDE
3. ✅ Kết nối FTDI Programmer
4. ✅ Vào Programming Mode
5. ✅ Kiểm tra code hoạt động
6. ✅ Debug và troubleshoot

**Bước tiếp theo:**
- Kết nối tất cả phần cứng (RC522, LCD)
- Test từng module
- Implement Backend API
- Tích hợp với Flutter app

**Chúc bạn thành công! 🚀**
