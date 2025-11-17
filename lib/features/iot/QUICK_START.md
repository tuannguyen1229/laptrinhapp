# 🚀 Quick Start - IoT Feature

## Bạn đã có gì?

✅ **ESP32-CAM** (OV2640 camera)  
✅ **RC522 RFID Reader** + thẻ từ  
✅ **LCD 16x2 I2C** (4 chân)  

## Bắt đầu ngay!

### 1️⃣ Setup ESP32-CAM (10 phút)

```bash
# 1. Mở VS Code
# 2. Cài extension "PlatformIO IDE"
# 3. Mở folder: features/iot/esp32_firmware/
# 4. Chỉnh sửa file: include/config.h
```

**Thay đổi trong config.h:**
```cpp
#define WIFI_SSID "TenWiFiCuaBan"
#define WIFI_PASSWORD "MatKhauWiFi"
#define API_BASE_URL "http://192.168.1.100:3000"  // IP máy server
```

### 2️⃣ Kết nối Phần cứng (15 phút)

**RC522 → ESP32-CAM:**
```
SDA  → GPIO 13
SCK  → GPIO 14
MOSI → GPIO 15
MISO → GPIO 12
RST  → GPIO 2
GND  → GND
3.3V → 3.3V
```

**LCD I2C → ESP32-CAM:**
```
SDA → GPIO 14
SCL → GPIO 15
GND → GND
VCC → 5V
```

**Power Bank → ESP32-CAM:**
```
5V OUT → 5V
GND    → GND
```

### 3️⃣ Upload Firmware (5 phút)

```bash
# Trong VS Code với PlatformIO:
# 1. Kết nối FTDI Programmer
# 2. Nối GPIO 0 với GND (để vào programming mode)
# 3. Nhấn nút Reset
# 4. Click "Upload" trong PlatformIO
# 5. Đợi upload xong
# 6. Bỏ nối GPIO 0 với GND
# 7. Nhấn Reset lại
```

### 4️⃣ Test ESP32 (2 phút)

```bash
# Mở Serial Monitor (115200 baud)
# Bạn sẽ thấy:
```

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

**LCD sẽ hiển thị:**
```
San sang!
Quet the/sach
```

### 5️⃣ Test Quét Thẻ RFID (1 phút)

1. Đưa thẻ RFID lại gần RC522
2. LCD hiển thị: "Dang xu ly..."
3. Serial Monitor hiển thị: "Card UID: A1B2C3D4"
4. ESP32 gửi request lên API

**Nếu chưa có backend API:**
- Sẽ báo lỗi "Connection failed"
- Đây là bình thường! Tiếp tục bước 6

### 6️⃣ Setup Backend API (30 phút)

**Tạo file test API đơn giản (Node.js):**

```javascript
// test-api.js
const express = require('express');
const app = express();
app.use(express.json());

// Mock data
const students = {
  'A1B2C3D4': {
    mssv: '2021001234',
    name: 'Nguyen Van A',
    class: 'CNTT-K15',
    phone: '0912345678',
    email: 'nguyenvana@example.com'
  }
};

app.post('/api/iot/scan-student-card', (req, res) => {
  const { card_uid } = req.body;
  const student = students[card_uid];
  
  if (student) {
    res.json({ success: true, student });
  } else {
    res.json({ success: false, error: 'Khong tim thay' });
  }
});

app.listen(3000, () => {
  console.log('API running on http://localhost:3000');
});
```

**Chạy:**
```bash
npm install express
node test-api.js
```

### 7️⃣ Test Lại với API (1 phút)

1. Đảm bảo API đang chạy
2. Quét thẻ RFID lại
3. LCD hiển thị thông tin sinh viên!

```
Nguyen Van A
MSSV:2021001234
```

### 8️⃣ Setup Flutter App (10 phút)

**Thêm vào pubspec.yaml:**
```yaml
dependencies:
  web_socket_channel: ^2.4.0
```

**Chạy:**
```bash
flutter pub get
```

**Xem hướng dẫn chi tiết:**
```
lib/features/iot/INTEGRATION_GUIDE.md
```

## ✅ Checklist

- [ ] ESP32-CAM đã kết nối WiFi
- [ ] RFID reader hoạt động
- [ ] LCD hiển thị "San sang!"
- [ ] Quét thẻ RFID thành công
- [ ] API trả về thông tin sinh viên
- [ ] LCD hiển thị thông tin đúng
- [ ] Flutter app đã thêm dependencies

## 🎯 Tiếp theo?

### Nếu mọi thứ hoạt động:
1. ✅ Đọc `INTEGRATION_GUIDE.md` để tích hợp vào Flutter app
2. ✅ Implement backend API thật
3. ✅ Đăng ký thẻ RFID cho sinh viên
4. ✅ Test end-to-end

### Nếu gặp lỗi:
1. ❌ Xem `esp32_firmware/README.md` → Troubleshooting
2. ❌ Check Serial Monitor output
3. ❌ Kiểm tra kết nối phần cứng
4. ❌ Kiểm tra WiFi và API URL

## 📊 Tiến độ Hiện tại

| Tính năng | Trạng thái |
|-----------|------------|
| ESP32 WiFi | ✅ Hoàn thành |
| RFID Reader | ✅ Hoàn thành |
| LCD Display | ✅ Hoàn thành |
| API Client | ✅ Hoàn thành |
| Camera Barcode | ⏳ Chưa có (cần implement) |
| Flutter Integration | ✅ Hoàn thành (code) |
| Backend API | ⏳ Cần implement |

## 💡 Tips

### Tip 1: Debug với Serial Monitor
Luôn mở Serial Monitor để xem log realtime

### Tip 2: Test từng bước
Đừng test tất cả cùng lúc. Test từng module riêng lẻ

### Tip 3: Kiểm tra địa chỉ I2C của LCD
Nếu LCD không hiển thị, thử đổi địa chỉ:
```cpp
#define LCD_ADDRESS 0x27  // Hoặc 0x3F
```

### Tip 4: Power Bank "Always On"
Chọn power bank có chế độ "always on" để không tự tắt

### Tip 5: Static IP cho ESP32
Trong code WiFi, có thể set static IP để dễ quản lý

## 🎓 Học thêm

- **PlatformIO:** https://platformio.org/
- **ESP32-CAM:** https://randomnerdtutorials.com/esp32-cam-video-streaming-face-recognition-arduino-ide/
- **MFRC522:** https://github.com/miguelbalboa/rfid
- **LiquidCrystal_I2C:** https://github.com/johnrickman/LiquidCrystal_I2C

## 📞 Cần giúp?

1. Xem `IMPLEMENTATION_STATUS.md` - Trạng thái tổng quan
2. Xem `esp32_firmware/README.md` - Chi tiết ESP32
3. Xem `INTEGRATION_GUIDE.md` - Tích hợp Flutter
4. Check code comments - Giải thích chi tiết

---

**Chúc bạn thành công! 🎉**
