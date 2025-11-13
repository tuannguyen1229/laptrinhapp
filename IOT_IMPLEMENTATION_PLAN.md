# Kế hoạch Triển khai Hệ thống IoT - Trạm Quét Thẻ & Sách Tự động

## 📋 Tổng quan Hệ thống

### Kiến trúc Tổng thể (Dùng ESP32-CAM)
```
[Thẻ RFID sinh viên] ──→ [RFID Reader RC522] ──┐
                                                │
[Barcode trên sách]  ──→ [ESP32-CAM]  ─────────┤──→ [WiFi] ──→ [Backend API] ──→ [Flutter App]
                         (Quét barcode)         │                                        ↓
                                                │                                  [Realtime Update]
                                                └──→ [OLED Display] (Hiển thị realtime)
```

### Mô tả Hoạt động
1. **Trạm IoT di động** với ESP32-CAM + sạc dự phòng
2. Thủ thư quét thẻ RFID sinh viên → hiển thị thông tin trên OLED
3. Quét barcode sách bằng camera ESP32-CAM → xử lý ảnh → hiển thị trên OLED
4. ESP32-CAM gửi dữ liệu lên server qua WiFi
5. App Flutter nhận realtime update và tự động điền form

---

## 🎯 Hệ thống IoT với ESP32 (Phương án Chuyên nghiệp)

### Ưu điểm Hệ thống IoT Độc lập:
- ✅ **Chuyên nghiệp**: Trạm quét cố định tại quầy thư viện
- ✅ **Nhanh**: Không phụ thuộc vào điện thoại
- ✅ **Chính xác**: Phần cứng chuyên dụng cho quét thẻ/barcode
- ✅ **Realtime**: Cập nhật tức thì lên app
- ✅ **Tiện lợi**: Thủ thư chỉ cần quét, không cần thao tác trên điện thoại
- ✅ **Mở rộng**: Có thể thêm nhiều trạm IoT

### Nhược điểm:
- ⚠️ Chi phí phần cứng (~1-2 triệu VNĐ)
- ⚠️ Cần setup và cấu hình
- ⚠️ Cần kết nối WiFi ổn định

---

## 🛠️ Danh sách Phần cứng Cần thiết (ESP32-CAM)

### 1. ESP32-CAM Module (Bắt buộc) ⭐
**Model:** ESP32-CAM (AI-Thinker hoặc tương đương)
- **Giá:** ~80,000 - 120,000 VNĐ
- **Tính năng:**
  - WiFi built-in
  - Camera OV2640 (2MP) tích hợp
  - Hỗ trợ quét barcode/QR code
  - MicroSD card slot (lưu ảnh nếu cần)
  - GPIO pins cho RFID và OLED
- **Ưu điểm:** 
  - Tích hợp camera, không cần module riêng
  - Tiết kiệm chi phí (~300k so với dùng GM65)
  - Nhỏ gọn
- **Lưu ý:** Cần programmer FTDI hoặc USB-TTL để nạp code

### 2. FTDI Programmer / USB-TTL (Bắt buộc)
**Model:** FT232RL hoặc CH340G
- **Giá:** ~30,000 - 50,000 VNĐ
- **Dùng cho:** Nạp code vào ESP32-CAM (ESP32-CAM không có USB built-in)

### 3. Đầu đọc thẻ RFID (Bắt buộc)
**Model:** RC522 RFID Reader Module
- **Giá:** ~50,000 - 80,000 VNĐ
- **Tính năng:**
  - Đọc thẻ RFID 13.56MHz (Mifare)
  - Khoảng cách đọc: 0-6cm
  - Giao tiếp: SPI
  - Điện áp: 3.3V
- **Kèm theo:** 2-5 thẻ RFID và 1-2 móc khóa RFID

### 4. Màn hình OLED (Bắt buộc)
**Model:** OLED 0.96" I2C (128x64)
- **Giá:** ~60,000 - 80,000 VNĐ
- **Tính năng:**
  - Hiển thị rõ nét, đẹp
  - Tiết kiệm điện (quan trọng cho sạc di động)
  - Giao tiếp: I2C (chỉ cần 2 dây)
  - Nhỏ gọn
- **Hiển thị:**
  - Dòng 1: Tên sinh viên
  - Dòng 2: MSSV
  - Dòng 3: Tên sách
  - Dòng 4: Mã sách

### 5. Sạc Dự phòng / Power Bank (Bắt buộc) ⭐
**Khuyến nghị:** Power Bank 10,000 - 20,000 mAh
- **Giá:** ~150,000 - 300,000 VNĐ
- **Thời gian hoạt động:** 
  - ESP32-CAM tiêu thụ ~200-300mA
  - Thời gian: 8-15 giờ (tùy dung lượng)
- **Lưu ý:** Chọn loại có output 5V 2A

### 6. Phụ kiện Bổ sung

**Breadboard + Dây nối (Khuyến nghị cho prototype)**
- **Giá:** ~50,000 - 80,000 VNĐ
- **Dùng cho:** Test và kết nối linh kiện

**LED + Buzzer (Optional)**
- **Giá:** ~10,000 - 20,000 VNĐ
- **Dùng cho:** Báo hiệu khi quét thành công/thất bại

**Nút nhấn (Optional)**
- **Giá:** ~5,000 - 10,000 VNĐ
- **Dùng cho:** Trigger quét barcode, reset

**Vỏ hộp nhựa (Optional)**
- **Giá:** ~50,000 - 100,000 VNĐ
- **Dùng cho:** Bảo vệ linh kiện, trông chuyên nghiệp

**MicroSD Card (Optional)**
- **Giá:** ~50,000 - 100,000 VNĐ (8-16GB)
- **Dùng cho:** Lưu ảnh barcode để debug

---

## 💰 Tổng chi phí Ước tính (ESP32-CAM)

### Cấu hình Cơ bản (Đủ dùng) ⭐ Khuyến nghị
| Linh kiện | Giá (VNĐ) |
|-----------|-----------|
| ESP32-CAM Module | 100,000 |
| FTDI Programmer | 40,000 |
| RC522 RFID Reader | 60,000 |
| OLED 0.96" I2C | 70,000 |
| Power Bank 10,000mAh | 200,000 |
| Breadboard + Dây | 60,000 |
| LED + Buzzer | 15,000 |
| **TỔNG** | **~545,000 VNĐ** |

### Cấu hình Nâng cao (Hoàn thiện)
| Linh kiện | Giá (VNĐ) |
|-----------|-----------|
| ESP32-CAM Module | 100,000 |
| FTDI Programmer | 40,000 |
| RC522 RFID Reader | 60,000 |
| OLED 0.96" I2C | 70,000 |
| Power Bank 20,000mAh | 300,000 |
| MicroSD Card 16GB | 80,000 |
| Vỏ hộp nhựa | 80,000 |
| LED + Buzzer + Nút | 25,000 |
| **TỔNG** | **~755,000 VNĐ** |

**Tiết kiệm:** ~170,000 - 285,000 VNĐ so với dùng GM65 Barcode Scanner!

---

## 🔌 Sơ đồ Kết nối Phần cứng (ESP32-CAM)

### Kết nối ESP32-CAM với RC522 RFID Reader (SPI)
```
RC522          ESP32-CAM
------         ----------
SDA    ──────→ GPIO 13 (CS)
SCK    ──────→ GPIO 14 (SCK)
MOSI   ──────→ GPIO 15 (MOSI)
MISO   ──────→ GPIO 12 (MISO)
IRQ    ──────→ (Không dùng)
GND    ──────→ GND
RST    ──────→ GPIO 2
3.3V   ──────→ 3.3V
```

### Kết nối ESP32-CAM với OLED 0.96" I2C
```
OLED I2C       ESP32-CAM
--------       ----------
SDA    ──────→ GPIO 14 (SDA) *
SCL    ──────→ GPIO 15 (SCL) *
GND    ──────→ GND
VCC    ──────→ 3.3V
```
**Lưu ý:** GPIO 14/15 có thể dùng chung với SPI, cần config software I2C

### Kết nối LED + Buzzer (Optional)
```
LED            ESP32-CAM
------         ----------
Anode  ──────→ GPIO 33 (qua điện trở 220Ω)
Cathode ─────→ GND

Buzzer         ESP32-CAM
------         ----------
+      ──────→ GPIO 4 (Flash LED pin)
-      ──────→ GND
```

### Kết nối Nút nhấn (Optional - Trigger quét)
```
Button         ESP32-CAM
------         ----------
Pin 1  ──────→ GPIO 0 (Boot button - có sẵn)
Pin 2  ──────→ GND
```

### Kết nối Power Bank
```
Power Bank     ESP32-CAM
----------     ----------
5V OUT ──────→ 5V (VCC)
GND    ──────→ GND
```

### Sơ đồ Tổng thể
```
                    ┌─────────────────────────────────┐
                    │       ESP32-CAM                 │
                    │   ┌──────────┐                  │
                    │   │ Camera   │ ← Quét Barcode   │
                    │   │ OV2640   │                  │
                    │   └──────────┘                  │
                    │                                 │
   RC522 RFID ──────┤ GPIO 12,13,14,15,2 (SPI)       │
                    │                                 │──→ WiFi ──→ Internet
   OLED I2C ────────┤ GPIO 14,15 (I2C)               │
                    │                                 │
   LED ─────────────┤ GPIO 33                         │
                    │                                 │
   Buzzer ──────────┤ GPIO 4                          │
                    │                                 │
   Button ──────────┤ GPIO 0 (Boot)                   │
                    │                                 │
   Power Bank ──────┤ 5V, GND                         │
                    └─────────────────────────────────┘
```

### Lưu ý Quan trọng về GPIO ESP32-CAM
**GPIO có thể dùng:**
- GPIO 0, 2, 4, 12, 13, 14, 15, 33

**GPIO KHÔNG nên dùng:**
- GPIO 1, 3 (TX/RX - dùng cho Serial)
- GPIO 16 (PSRAM)
- GPIO 5, 18, 19, 21, 22, 23 (Camera pins)

---

## 🏗️ Kiến trúc Hệ thống

### 1. Kiến trúc Tổng thể

```
┌─────────────────────────────────────────────────────────────────┐
│                      TRẠM IoT (ESP32)                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ RFID Reader  │  │   Barcode    │  │  LCD Display │         │
│  │   (RC522)    │  │  Scanner     │  │   (16x2)     │         │
│  └──────┬───────┘  └──────┬───────┘  └──────▲───────┘         │
│         │                  │                  │                  │
│         └──────────────────┴──────────────────┘                 │
│                            │                                     │
│                    ┌───────▼────────┐                           │
│                    │     ESP32      │                           │
│                    │  (Controller)  │                           │
│                    └───────┬────────┘                           │
│                            │ WiFi                                │
└────────────────────────────┼─────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │   Internet     │
                    └────────┬───────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
    ┌───────────────────┐     ┌──────────────────┐
    │  Backend Server   │     │   MQTT Broker    │
    │  (REST API)       │     │  (Optional)      │
    └─────────┬─────────┘     └──────────┬───────┘
              │                           │
              └───────────┬───────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   Flutter App         │
              │  (Realtime Update)    │
              └───────────────────────┘
```

### 2. Luồng Dữ liệu

**Phương án A: REST API (Đơn giản)**
```
ESP32 → HTTP POST → Backend API → Database
                         ↓
                    Polling/SSE
                         ↓
                   Flutter App
```

**Phương án B: MQTT (Realtime tốt hơn)** ⭐ Khuyến nghị
```
ESP32 → MQTT Publish → MQTT Broker → MQTT Subscribe → Flutter App
              ↓
         Backend API
              ↓
          Database
```

### 3. Cấu trúc Code ESP32-CAM

```
esp32cam_iot_station/
├── src/
│   ├── main.cpp                    # Entry point
│   ├── config.h                    # WiFi, API config
│   ├── rfid_handler.cpp/h          # Xử lý RFID
│   ├── camera_handler.cpp/h        # Xử lý Camera + quét barcode
│   ├── barcode_decoder.cpp/h       # Decode barcode từ ảnh
│   ├── oled_handler.cpp/h          # Xử lý OLED display
│   ├── wifi_handler.cpp/h          # Xử lý WiFi
│   ├── api_client.cpp/h            # Gọi API
│   └── mqtt_client.cpp/h           # MQTT (optional)
├── lib/
│   ├── MFRC522/                    # Library RFID
│   ├── Adafruit_SSD1306/           # Library OLED
│   ├── esp32_camera/               # Library Camera (built-in)
│   ├── quirc/                      # Library decode QR code
│   └── PubSubClient/               # Library MQTT
└── platformio.ini                  # Config PlatformIO
```

### 4. Cấu trúc Flutter App (Thêm mới)

```
lib/
└── features/
    └── iot_realtime/                    # Feature mới
        ├── data/
        │   ├── datasources/
        │   │   ├── iot_websocket_datasource.dart
        │   │   └── iot_mqtt_datasource.dart
        │   ├── models/
        │   │   ├── iot_scan_event_model.dart
        │   │   └── iot_device_status_model.dart
        │   └── repositories/
        │       └── iot_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── iot_scan_event.dart
        │   │   └── iot_device_status.dart
        │   ├── repositories/
        │   │   └── iot_repository.dart
        │   └── usecases/
        │       ├── listen_iot_events_usecase.dart
        │       └── get_device_status_usecase.dart
        └── presentation/
            ├── bloc/
            │   ├── iot_bloc.dart
            │   ├── iot_event.dart
            │   └── iot_state.dart
            └── widgets/
                ├── iot_status_indicator.dart
                └── iot_scan_listener.dart
```

### 5. Tích hợp vào Form Mượn Sách

**File cần chỉnh sửa:**
- `lib/features/tuan_borrow_management/presentation/screens/borrow_form_screen.dart`

**Thay đổi:**
- Thêm `IoTScanListener` widget để lắng nghe sự kiện từ ESP32
- Khi nhận được event quét thẻ → tự động điền form người mượn
- Khi nhận được event quét sách → tự động điền form sách
- Hiển thị indicator trạng thái kết nối với trạm IoT

---

## 🔄 Luồng Hoạt động Chi tiết

### Flow 1: Quét Thẻ Sinh Viên

```
┌─────────────────────────────────────────────────────────────────┐
│                    TRẠM IoT (ESP32)                             │
└─────────────────────────────────────────────────────────────────┘

1. Sinh viên đưa thẻ RFID lại gần đầu đọc RC522
   ↓
2. RC522 đọc UID thẻ (VD: "A1B2C3D4")
   ↓
3. ESP32 nhận UID từ RC522
   ↓
4. ESP32 hiển thị "Đang xử lý..." trên LCD
   ↓
5. ESP32 gửi HTTP POST request đến Backend API:
   POST /api/iot/scan-student-card
   Body: { "card_uid": "A1B2C3D4", "device_id": "IOT_STATION_01" }
   ↓
6. Backend API query database để lấy thông tin sinh viên
   ↓
7. Backend trả về JSON:
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
   ↓
8. ESP32 nhận response và hiển thị trên LCD:
   Dòng 1: "Nguyen Van A"
   Dòng 2: "MSSV: 2021001234"
   ↓
9. ESP32 bật LED xanh + Buzzer "beep" 1 lần
   ↓
10. ESP32 publish MQTT message (nếu dùng MQTT):
    Topic: "library/iot/student-scanned"
    Payload: { "student": {...}, "timestamp": "..." }
    ↓
11. Backend lưu log scan vào database
    ↓
12. Backend push notification đến Flutter App (qua WebSocket/MQTT)

┌─────────────────────────────────────────────────────────────────┐
│                    FLUTTER APP                                  │
└─────────────────────────────────────────────────────────────────┘

13. Flutter App nhận realtime event
    ↓
14. IoTBloc xử lý event và emit state mới
    ↓
15. BorrowFormScreen lắng nghe state change
    ↓
16. Auto-fill form "Thông tin người mượn":
    - Tên người mượn: "Nguyễn Văn A"
    - Lớp: "CNTT-K15"
    - MSSV: "2021001234"
    - Số điện thoại: "0912345678"
    - Email: "nguyenvana@example.com"
    ↓
17. Hiển thị SnackBar: "✅ Đã quét thẻ sinh viên thành công!"
    ↓
18. Focus chuyển sang form "Thông tin sách" (chờ quét sách)
```

### Flow 2: Quét Barcode Sách (ESP32-CAM)

```
┌─────────────────────────────────────────────────────────────────┐
│                    TRẠM IoT (ESP32-CAM)                         │
└─────────────────────────────────────────────────────────────────┘

1. Thủ thư nhấn nút "Quét sách" (GPIO 0) hoặc tự động trigger
   ↓
2. ESP32-CAM bật camera và chụp ảnh barcode
   ↓
3. Xử lý ảnh và decode barcode (dùng quirc hoặc ZXing)
   ↓
4. ESP32-CAM hiển thị "Đang xử lý..." trên OLED
   ↓
5. Nếu decode thành công → lấy được mã sách (VD: "BK001234")
   ↓
6. ESP32-CAM gửi HTTP POST request đến Backend API:
   POST /api/iot/scan-book-barcode
   Body: { "barcode": "BK001234", "device_id": "IOT_STATION_01" }
   ↓
7. Backend API query database để lấy thông tin sách
   ↓
8. Backend trả về JSON:
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
   ↓
9. ESP32-CAM nhận response và hiển thị trên OLED:
   Dòng 1: "Lap trinh Flutter"
   Dòng 2: "Ma: BK001234"
   ↓
10. ESP32-CAM bật LED xanh + Buzzer "beep" 1 lần
    ↓
11. ESP32-CAM publish MQTT message:
    Topic: "library/iot/book-scanned"
    Payload: { "book": {...}, "timestamp": "..." }
    ↓
12. Backend lưu log scan vào database
    ↓
13. (Optional) Lưu ảnh barcode vào MicroSD card để debug

┌─────────────────────────────────────────────────────────────────┐
│                    FLUTTER APP                                  │
└─────────────────────────────────────────────────────────────────┘

12. Flutter App nhận realtime event
    ↓
13. IoTBloc xử lý event và emit state mới
    ↓
14. BorrowFormScreen lắng nghe state change
    ↓
15. Auto-fill form "Thông tin sách":
    - Tên sách: "Lập trình Flutter"
    - Mã sách: "BK001234"
    ↓
16. Hiển thị SnackBar: "✅ Đã quét sách thành công!"
    ↓
17. Enable nút "Tạo thẻ mượn" (vì đã có đủ thông tin)
```

### Flow 3: Xử lý Lỗi

```
┌─────────────────────────────────────────────────────────────────┐
│                    TRẠM IoT (ESP32)                             │
└─────────────────────────────────────────────────────────────────┘

1. Quét thẻ/sách không tìm thấy trong database
   ↓
2. Backend trả về:
   {
     "success": false,
     "error": "Không tìm thấy thông tin"
   }
   ↓
3. ESP32 hiển thị trên LCD:
   Dòng 1: "KHONG TIM THAY"
   Dòng 2: "Vui long thu lai"
   ↓
4. ESP32 bật LED đỏ + Buzzer "beep" 3 lần
   ↓
5. Sau 3 giây, LCD reset về trạng thái chờ

┌─────────────────────────────────────────────────────────────────┐
│                    FLUTTER APP                                  │
└─────────────────────────────────────────────────────────────────┘

6. Flutter App nhận error event
   ↓
7. Hiển thị SnackBar: "❌ Không tìm thấy thông tin. Vui lòng thử lại."
   ↓
8. Không auto-fill form
```

---

## 🗄️ Thay đổi Database

### 1. Bảng Users (Sinh viên)
```sql
-- Thêm cột để lưu UID thẻ RFID
ALTER TABLE users ADD COLUMN rfid_card_uid VARCHAR(50) UNIQUE;
ALTER TABLE users ADD COLUMN card_registered_at TIMESTAMP;

-- Index để tìm kiếm nhanh
CREATE INDEX idx_users_rfid_card_uid ON users(rfid_card_uid);
```

### 2. Bảng Books
```sql
-- Thêm cột barcode (nếu chưa có)
ALTER TABLE books ADD COLUMN barcode VARCHAR(50) UNIQUE;

-- Index để tìm kiếm nhanh
CREATE INDEX idx_books_barcode ON books(barcode);
```

### 3. Bảng IoT Devices (Mới)
```sql
CREATE TABLE iot_devices (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    device_type VARCHAR(20), -- 'scanning_station', 'kiosk', etc.
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'inactive', 'maintenance'
    last_heartbeat TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert trạm IoT mẫu
INSERT INTO iot_devices (id, name, location, device_type) 
VALUES ('IOT_STATION_01', 'Trạm quét chính', 'Quầy thư viện tầng 1', 'scanning_station');
```

### 4. Bảng IoT Scan Logs (Mới)
```sql
CREATE TABLE iot_scan_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_id VARCHAR(50) NOT NULL,
    scan_type VARCHAR(20) NOT NULL, -- 'student_card', 'book_barcode'
    scan_data VARCHAR(200) NOT NULL, -- UID hoặc barcode
    result VARCHAR(20) NOT NULL, -- 'success', 'not_found', 'error'
    user_id INT, -- Nếu quét thẻ sinh viên
    book_id INT, -- Nếu quét sách
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES iot_devices(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- Index để query nhanh
CREATE INDEX idx_scan_logs_device_id ON iot_scan_logs(device_id);
CREATE INDEX idx_scan_logs_scanned_at ON iot_scan_logs(scanned_at);
```

---

## 📦 Dependencies Cần Thêm

### 1. ESP32-CAM (PlatformIO)

**platformio.ini**
```ini
[env:esp32cam]
platform = espressif32
board = esp32cam
framework = arduino

lib_deps =
    # RFID Reader
    miguelbalboa/MFRC522@^1.4.10
    
    # OLED Display
    adafruit/Adafruit SSD1306@^2.5.7
    adafruit/Adafruit GFX Library@^1.11.5
    
    # Camera (built-in ESP32)
    # esp32_camera (built-in)
    
    # QR Code / Barcode decoder
    # quirc library hoặc ZXing-CPP
    
    # MQTT Client (nếu dùng MQTT)
    knolleary/PubSubClient@^2.8
    
    # HTTP Client (built-in)
    # WiFi (built-in)
    
    # JSON parsing
    bblanchon/ArduinoJson@^6.21.3

build_flags =
    -DBOARD_HAS_PSRAM
    -mfix-esp32-psram-cache-issue
```

### 2. Flutter App

**pubspec.yaml**
```yaml
dependencies:
  # Realtime communication
  web_socket_channel: ^2.4.0  # WebSocket
  mqtt_client: ^10.0.0        # MQTT (nếu dùng)
  
  # State management (đã có)
  flutter_bloc: ^8.1.3
  
  # HTTP client (đã có)
  http: ^1.1.0
  
  # Notification/Toast
  fluttertoast: ^8.2.4
  
  # Sound effect (optional)
  audioplayers: ^5.2.1
```

### 3. Backend API (Node.js/Express hoặc Laravel)

**Nếu dùng Node.js:**
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "mqtt": "^5.0.0",
    "ws": "^8.14.0",
    "mysql2": "^3.6.0",
    "dotenv": "^16.3.1"
  }
}
```

**Nếu dùng Laravel:**
```bash
composer require laravel/sanctum
composer require beyondcode/laravel-websockets
```

---

## 🎨 UI/UX Design

### 1. Nút Quét trên Form

**Vị trí:**
- Bên phải tiêu đề "Thông tin người mượn" → icon camera/QR
- Bên phải tiêu đề "Thông tin sách" → icon barcode

**Icon đề xuất:**
- `Icons.qr_code_scanner` - Quét thẻ sinh viên
- `Icons.barcode_reader` - Quét barcode sách
- `Icons.nfc` - Quét NFC (nếu có)

### 2. Scanner Screen

**Thiết kế:**
- Full screen camera view
- Overlay với khung quét (highlight area)
- Nút đóng ở góc trên
- Hướng dẫn ở dưới: "Đưa thẻ/sách vào khung quét"
- Hiệu ứng animation khi quét thành công

### 3. Feedback

**Khi quét thành công:**
- ✅ Rung nhẹ (vibration)
- ✅ Âm thanh "beep"
- ✅ Hiển thị checkmark animation
- ✅ Tự động đóng scanner
- ✅ Snackbar: "Đã quét thành công!"

**Khi quét thất bại:**
- ❌ Hiển thị lỗi: "Không tìm thấy thông tin"
- ❌ Cho phép quét lại hoặc nhập thủ công

---

## 🔐 Xử lý Permissions

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<!-- Camera permission -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- NFC permission (nếu dùng) -->
<uses-permission android:name="android.permission.NFC" />

<!-- Vibration -->
<uses-permission android:name="android.permission.VIBRATE" />
```

### iOS (ios/Runner/Info.plist)
```xml
<!-- Camera permission -->
<key>NSCameraUsageDescription</key>
<string>Cần quyền camera để quét mã thẻ và sách</string>

<!-- NFC permission (nếu dùng) -->
<key>NFCReaderUsageDescription</key>
<string>Cần quyền NFC để đọc thẻ sinh viên</string>
```

---

## 🧪 Kế hoạch Testing

### 1. Unit Tests
- Test parse dữ liệu từ barcode/QR
- Test validation mã thẻ/mã sách
- Test repository methods

### 2. Integration Tests
- Test flow quét → lấy dữ liệu từ API → auto-fill form
- Test xử lý lỗi khi không tìm thấy dữ liệu

### 3. Manual Tests
- Test trên thiết bị thật với camera
- Test với các loại barcode/QR khác nhau
- Test với ánh sáng khác nhau
- Test NFC (nếu có)

---

## 📝 Format Dữ liệu Đề xuất

### QR Code cho Thẻ Sinh Viên
```json
{
  "type": "student_card",
  "mssv": "2021001234",
  "name": "Nguyễn Văn A",
  "class": "CNTT-K15",
  "phone": "0912345678",
  "email": "nguyenvana@example.com"
}
```

**Hoặc format đơn giản:**
```
STUDENT:2021001234
```
→ Sau đó query database để lấy thông tin đầy đủ

### Barcode cho Sách
```
BOOK:BK001234
```
→ Query database để lấy thông tin sách

---

## 🚀 Roadmap Triển khai

### Phase 1: Chuẩn bị Phần cứng (1-2 tuần)
**Mục tiêu:** Mua sắm và test linh kiện

**Công việc:**
1. ✅ Đặt mua linh kiện (ESP32, RC522, GM65, LCD, etc.)
2. ✅ Chờ nhận hàng (3-7 ngày)
3. ✅ Test từng module riêng lẻ:
   - Test ESP32 kết nối WiFi
   - Test RC522 đọc thẻ RFID
   - Test GM65 quét barcode
   - Test LCD hiển thị text
4. ✅ Kết nối tất cả module lại với nhau
5. ✅ Test tích hợp cơ bản

**Output:** Trạm IoT hoạt động cơ bản (đọc được thẻ, quét được barcode, hiển thị LCD)

---

### Phase 2: Phát triển Firmware ESP32-CAM (5-7 ngày)
**Mục tiêu:** Code cho ESP32-CAM để xử lý quét và gửi dữ liệu

**Công việc:**
1. ✅ Setup PlatformIO project cho ESP32-CAM
2. ✅ Implement Camera handler:
   - Khởi tạo camera OV2640
   - Chụp ảnh với resolution phù hợp
   - Tối ưu ánh sáng và focus
3. ✅ Implement Barcode decoder:
   - Tích hợp quirc library (QR code)
   - Hoặc ZXing-CPP (barcode 1D/2D)
   - Xử lý ảnh và decode
   - Xử lý lỗi khi không decode được
4. ✅ Implement RFID handler:
   - Đọc UID thẻ RFID
   - Xử lý debounce (tránh đọc nhiều lần)
5. ✅ Implement OLED handler:
   - Hiển thị trạng thái
   - Hiển thị thông tin quét được
   - Hiển thị preview camera (optional)
6. ✅ Implement WiFi handler:
   - Kết nối WiFi
   - Auto reconnect
7. ✅ Implement API client:
   - HTTP POST request
   - Parse JSON response
8. ✅ Implement LED + Buzzer feedback
9. ✅ Implement Button handler (trigger quét)
10. ✅ Test tổng thể

**Output:** ESP32-CAM firmware hoàn chỉnh, có thể quét thẻ RFID và barcode, gửi dữ liệu lên server

**Lưu ý:** Phase này phức tạp hơn vì cần xử lý ảnh và decode barcode trên ESP32

---

### Phase 3: Phát triển Backend API (2-3 ngày)
**Mục tiêu:** Tạo API endpoints để nhận dữ liệu từ ESP32

**Công việc:**
1. ✅ Thiết kế database schema (thêm bảng mới)
2. ✅ Migrate database
3. ✅ Implement API endpoints:
   - `POST /api/iot/scan-student-card`
   - `POST /api/iot/scan-book-barcode`
   - `GET /api/iot/devices` (quản lý thiết bị)
   - `POST /api/iot/heartbeat` (check trạng thái)
4. ✅ Implement business logic:
   - Query thông tin sinh viên từ UID
   - Query thông tin sách từ barcode
   - Lưu scan logs
5. ✅ Setup WebSocket/MQTT server (cho realtime)
6. ✅ Test API với Postman

**Output:** Backend API hoàn chỉnh, sẵn sàng nhận dữ liệu từ ESP32

---

### Phase 4: Tích hợp Flutter App (3-4 ngày)
**Mục tiêu:** App nhận realtime update và auto-fill form

**Công việc:**
1. ✅ Tạo feature `iot_realtime`:
   - Data layer (WebSocket/MQTT datasource)
   - Domain layer (entities, usecases)
   - Presentation layer (bloc, widgets)
2. ✅ Implement WebSocket/MQTT client
3. ✅ Implement IoTBloc:
   - Listen to scan events
   - Emit states
4. ✅ Modify BorrowFormScreen:
   - Add IoTScanListener widget
   - Auto-fill form khi nhận event
   - Hiển thị IoT status indicator
5. ✅ Implement UI feedback:
   - SnackBar notifications
   - Sound effects (optional)
6. ✅ Test tích hợp end-to-end

**Output:** Flutter app nhận được realtime update từ trạm IoT

---

### Phase 5: Testing & Optimization (2-3 ngày)
**Mục tiêu:** Test toàn bộ hệ thống và tối ưu

**Công việc:**
1. ✅ Test scenarios:
   - Quét thẻ sinh viên → auto-fill form
   - Quét sách → auto-fill form
   - Quét thẻ không tồn tại → hiển thị lỗi
   - Quét sách không tồn tại → hiển thị lỗi
   - Mất kết nối WiFi → xử lý lỗi
   - Nhiều người dùng cùng lúc
2. ✅ Optimize performance:
   - Giảm độ trễ
   - Tối ưu battery (nếu dùng power bank)
3. ✅ Fix bugs
4. ✅ Viết documentation
5. ✅ Tạo user manual

**Output:** Hệ thống hoàn chỉnh, ổn định, sẵn sàng deploy

---

### Phase 6: Deployment & Training (1-2 ngày)
**Mục tiêu:** Deploy và đào tạo người dùng

**Công việc:**
1. ✅ Lắp đặt trạm IoT tại quầy thư viện
2. ✅ Cấu hình WiFi production
3. ✅ Deploy backend API lên server
4. ✅ Deploy Flutter app (APK hoặc App Store)
5. ✅ Đăng ký thẻ RFID cho sinh viên:
   - Quét thẻ và link với MSSV
   - Lưu vào database
6. ✅ In và dán barcode lên sách
7. ✅ Đào tạo thủ thư sử dụng hệ thống
8. ✅ Monitor và support

**Output:** Hệ thống đi vào hoạt động thực tế

---

## 📅 Timeline Tổng thể (ESP32-CAM)

```
Tuần 1-2:  Phase 1 - Chuẩn bị phần cứng
Tuần 3-4:  Phase 2 - Phát triển ESP32-CAM firmware (phức tạp hơn)
Tuần 5:    Phase 3 - Phát triển Backend API
           Phase 4 - Tích hợp Flutter App (bắt đầu)
Tuần 6:    Phase 4 - Tích hợp Flutter App (hoàn thành)
           Phase 5 - Testing & Optimization
Tuần 7:    Phase 6 - Deployment & Training

TỔNG: ~7 tuần (1.75 tháng)
```

**Lưu ý:** 
- Timeline dài hơn 1 tuần so với dùng GM65 vì cần xử lý ảnh và decode barcode
- Timeline có thể ngắn hơn nếu:
  - Đã có kinh nghiệm với ESP32-CAM
  - Đã có kinh nghiệm xử lý ảnh trên embedded
  - Có sẵn một số linh kiện
  - Làm full-time (không phải part-time)

---

## 💡 Lưu ý Quan trọng

### 1. Thẻ RFID cho Sinh viên
**Vấn đề:** Thẻ sinh viên hiện tại có thể không phải thẻ RFID

**Giải pháp:**
- **Option A:** Mua thẻ RFID riêng cho thư viện (50-100 thẻ)
  - Giá: ~5,000 - 10,000 VNĐ/thẻ
  - Phát cho sinh viên khi đăng ký
  - Đăng ký UID thẻ với MSSV trong database
  
- **Option B:** Dùng thẻ sinh viên hiện có (nếu là RFID)
  - Cần xác định loại thẻ (13.56MHz hay 125KHz)
  - Đọc UID và đăng ký vào hệ thống

- **Option C:** Dán sticker RFID lên thẻ sinh viên hiện có
  - Giá: ~3,000 - 5,000 VNĐ/sticker
  - Không cần phát thẻ mới

### 2. Barcode cho Sách
**Vấn đề:** Sách có thể chưa có barcode

**Giải pháp:**
- In barcode sticker dán lên sách
- Sử dụng mã sách hiện có để generate barcode
- Format: Code 128 hoặc Code 39
- Công cụ: Online barcode generator hoặc Excel

**Chi phí:**
- Giấy in barcode: ~100,000 - 200,000 VNĐ (1000 tem)
- Máy in barcode (optional): ~2-5 triệu VNĐ

### 3. Kết nối WiFi
**Quan trọng:** ESP32 cần kết nối WiFi ổn định

**Lưu ý:**
- Đặt trạm IoT gần router WiFi
- Sử dụng WiFi 2.4GHz (ESP32 không hỗ trợ 5GHz)
- Cấu hình static IP cho ESP32 (tránh thay đổi IP)
- Backup: Có thể dùng 4G router nếu WiFi không ổn định

### 4. Nguồn điện (Power Bank) ⭐
**Khuyến nghị:** Sử dụng Power Bank (theo yêu cầu)

**Ưu điểm:**
- ✅ Di động, không cần cắm điện
- ✅ Linh hoạt, có thể di chuyển trạm IoT
- ✅ Backup khi mất điện

**Thông số:**
- Dung lượng: 10,000 - 20,000 mAh
- Output: 5V 2A
- Thời gian hoạt động: 
  - ESP32-CAM: ~200-300mA (idle)
  - ESP32-CAM + Camera active: ~400-500mA
  - Thời gian: 8-15 giờ (tùy dung lượng và tần suất quét)

**Lưu ý:**
- Chọn power bank có chế độ "always on" (không tự tắt khi dòng điện thấp)
- Sạc đầy mỗi ngày để đảm bảo hoạt động liên tục

### 5. Bảo mật
**Quan trọng:** Bảo vệ hệ thống khỏi truy cập trái phép

**Biện pháp:**
- API authentication (API key hoặc JWT)
- HTTPS cho tất cả requests
- Rate limiting (tránh spam)
- Validate dữ liệu từ ESP32
- Log tất cả hoạt động

### 6. Xử lý Lỗi
**Scenarios cần xử lý:**
- Mất kết nối WiFi → Retry + hiển thị lỗi trên LCD
- API timeout → Retry 3 lần
- Thẻ/sách không tồn tại → Hiển thị lỗi rõ ràng
- Database down → Queue requests, sync sau

### 7. Scalability
**Nếu muốn mở rộng:**
- Có thể thêm nhiều trạm IoT (mỗi trạm 1 device_id)
- Backend hỗ trợ multiple devices
- App hiển thị trạng thái tất cả trạm
- Centralized monitoring dashboard

---

## 🎓 Khuyến nghị Triển khai

### Bước 1: Proof of Concept (PoC)
**Mục tiêu:** Chứng minh hệ thống hoạt động

**Làm gì:**
1. Mua 1 bộ linh kiện cơ bản (~700k VNĐ)
2. Test với 5-10 thẻ RFID mẫu
3. Test với 5-10 sách có barcode
4. Demo cho stakeholders

**Thời gian:** 1-2 tuần

### Bước 2: Pilot (Thử nghiệm)
**Mục tiêu:** Test trong môi trường thực tế nhỏ

**Làm gì:**
1. Deploy 1 trạm IoT tại quầy thư viện
2. Đăng ký 20-30 sinh viên tham gia pilot
3. Thu thập feedback
4. Fix bugs và cải thiện

**Thời gian:** 2-3 tuần

### Bước 3: Full Deployment
**Mục tiêu:** Triển khai toàn bộ hệ thống

**Làm gì:**
1. Đăng ký tất cả sinh viên
2. Dán barcode cho tất cả sách
3. Deploy thêm trạm IoT nếu cần
4. Training cho tất cả thủ thư
5. Go live!

**Thời gian:** 2-4 tuần

---

## 📞 Câu hỏi Cần Làm rõ Trước khi Bắt đầu

### 1. Về Thẻ Sinh viên
- [ ] Thẻ sinh viên hiện tại là loại gì? (RFID, từ tính, hay chỉ là thẻ nhựa thường?)
- [ ] Nếu là RFID, tần số bao nhiêu? (13.56MHz hay 125KHz?)
- [ ] Có bao nhiêu sinh viên cần đăng ký?
- [ ] Ngân sách cho thẻ RFID mới (nếu cần)?

### 2. Về Sách
- [ ] Có bao nhiêu đầu sách cần dán barcode?
- [ ] Sách đã có mã sách chưa? (để generate barcode)
- [ ] Ai sẽ in và dán barcode?

### 3. Về Hạ tầng
- [ ] Thư viện có WiFi không?
- [ ] Tốc độ và độ ổn định WiFi?
- [ ] Có ổ cắm điện tại quầy không?
- [ ] Backend API sẽ host ở đâu? (VPS, shared hosting, cloud?)

### 4. Về Ngân sách
- [ ] Ngân sách tổng cho dự án?
- [ ] Có thể mua linh kiện ngay không?
- [ ] Có ngân sách dự phòng không?

### 5. Về Timeline
- [ ] Deadline dự án?
- [ ] Có thể làm full-time hay part-time?
- [ ] Có hỗ trợ kỹ thuật không?

---

## 🎯 Next Steps

### Nếu đồng ý với kế hoạch này:

1. **Trả lời các câu hỏi ở trên** để tôi có thể điều chỉnh kế hoạch cho phù hợp

2. **Quyết định bắt đầu từ đâu:**
   - Option A: Mua linh kiện ngay và bắt đầu Phase 1
   - Option B: Tôi viết code mẫu cho ESP32 trước (để bạn xem trước)
   - Option C: Tôi setup backend API trước (để test với mock data)

3. **Tôi sẽ hỗ trợ:**
   - Code ESP32 firmware (C++)
   - Code backend API endpoints
   - Code Flutter integration
   - Hướng dẫn kết nối phần cứng
   - Troubleshooting

---

**Tóm lại:** Hệ thống IoT với ESP32 là giải pháp chuyên nghiệp, phù hợp cho thư viện. Chi phí hợp lý (~700k - 1 triệu VNĐ), timeline ~6 tuần. Cần chuẩn bị thẻ RFID cho sinh viên và barcode cho sách.
