# IoT Feature - Trạm Quét Thẻ & Sách Tự động

## 📁 Cấu trúc Thư mục

```
features/iot/
├── esp32_firmware/              # ESP32-CAM firmware code
│   ├── src/                     # Source code
│   ├── lib/                     # Libraries
│   ├── include/                 # Header files
│   ├── platformio.ini           # PlatformIO config
│   └── README.md                # Hướng dẫn setup ESP32
│
└── flutter_integration/         # Flutter app integration (symbolic link to lib/features/iot/)
```

## 🚀 Quick Start

### 1. ESP32-CAM Setup
Xem hướng dẫn chi tiết tại: `esp32_firmware/README.md`

### 2. Flutter Integration
Code Flutter đã được tích hợp vào `lib/features/iot/`

## 📚 Documentation
- [ESP32-CAM Firmware Guide](esp32_firmware/README.md)
- [IoT Implementation Plan](../../IOT_IMPLEMENTATION_PLAN.md)
