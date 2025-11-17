#ifndef CONFIG_H
#define CONFIG_H

// ============================================
// WiFi Configuration
// ============================================
#define WIFI_SSID "VDK IOT"          // Thay bằng tên WiFi của bạn
#define WIFI_PASSWORD "20242025x"  // Thay bằng mật khẩu WiFi
#define WIFI_TIMEOUT 20000                  // 20 seconds

// ============================================
// API Configuration
// ============================================
#define API_BASE_URL "http://172.20.10.5:3000"  // Thay bằng IP server của bạn
#define API_SCAN_STUDENT "/api/iot/scan-student-card"
#define API_SCAN_BOOK "/api/iot/scan-book-barcode"
#define API_HEARTBEAT "/api/iot/heartbeat"
#define API_TIMEOUT 10000  // 10 seconds

// ============================================
// Device Configuration
// ============================================
#define DEVICE_ID "IOT_STATION_01"
#define DEVICE_NAME "Tram Quet Chinh"
#define DEVICE_LOCATION "Quay Thu Vien Tang 1"

// ============================================
// RFID RC522 Pin Configuration (SPI) - ESP32-S3-CAM
// ============================================
#define RFID_CS_PIN 10    // Chip Select
#define RFID_RST_PIN 9    // Reset
#define RFID_SCK_PIN 12   // Serial Clock
#define RFID_MOSI_PIN 11  // Master Out Slave In
#define RFID_MISO_PIN 13  // Master In Slave Out

// ============================================
// LCD 16x2 I2C Configuration - ESP32-S3-CAM
// ============================================
#define LCD_ADDRESS 0x3F  // Thử 0x3F trước, nếu không được thì 0x27
#define LCD_COLS 16
#define LCD_ROWS 2
#define LCD_SDA_PIN 4     // I2C SDA for ESP32-S3
#define LCD_SCL_PIN 5     // I2C SCL for ESP32-S3

// ============================================
// Camera Configuration - ESP32-S3-CAM
// ============================================
#define CAMERA_MODEL_ESP32S3_EYE  // ESP32-S3-CAM
#define CAMERA_FRAME_SIZE FRAMESIZE_VGA  // 640x480 - tốt cho barcode
#define CAMERA_JPEG_QUALITY 10  // 0-63, thấp hơn = chất lượng cao hơn

// ============================================
// Button Configuration
// ============================================
#define SCAN_BUTTON_PIN 0  // GPIO 0 (Boot button)
#define BUTTON_DEBOUNCE_MS 50

// ============================================
// LED & Buzzer Configuration (Optional)
// ============================================
// #define LED_PIN 33         // LED indicator - Disabled
// #define BUZZER_PIN 4       // Buzzer - Disabled (conflict with LCD SDA)
// #define FLASH_LED_PIN 4    // Camera flash LED - Disabled

// ============================================
// Timing Configuration
// ============================================
#define RFID_SCAN_INTERVAL 500     // Check RFID mỗi 500ms
#define LCD_DISPLAY_TIMEOUT 5000   // Hiển thị thông tin 5 giây
#define HEARTBEAT_INTERVAL 60000   // Gửi heartbeat mỗi 60 giây
#define CAMERA_WARMUP_MS 1000      // Camera warm-up time

// ============================================
// Debug Configuration
// ============================================
#define DEBUG_MODE true
#define SERIAL_BAUD_RATE 115200

// Debug macros
#if DEBUG_MODE
  #define DEBUG_PRINT(x) Serial.print(x)
  #define DEBUG_PRINTLN(x) Serial.println(x)
  #define DEBUG_PRINTF(x, ...) Serial.printf(x, __VA_ARGS__)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN(x)
  #define DEBUG_PRINTF(x, ...)
#endif

// ============================================
// MQTT Configuration (Optional)
// ============================================
// #define USE_MQTT true
// #define MQTT_SERVER "192.168.1.100"
// #define MQTT_PORT 1883
// #define MQTT_USER "mqtt_user"
// #define MQTT_PASSWORD "mqtt_password"
// #define MQTT_TOPIC_STUDENT "library/iot/student-scanned"
// #define MQTT_TOPIC_BOOK "library/iot/book-scanned"

#endif // CONFIG_H
