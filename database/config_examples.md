# Các Cấu Hình Kết Nối Database

## 1. Kết nối Local (Máy tính của bạn)

### Windows Desktop App:
```dart
// lib/config/database/database_config.dart
static const String postgresHost = 'localhost';  // hoặc '127.0.0.1'
static const int postgresPort = 5432;
static const String postgresDatabase = 'quan_ly_thu_vien_dev';
static const String postgresUsername = 'postgres';
static const String postgresPassword = '1234';
```

## 2. Kết nối từ Android Emulator

```dart
// Android Emulator có IP đặc biệt để truy cập localhost của máy host
static const String postgresHost = '10.0.2.2';
static const int postgresPort = 5432;
static const String postgresDatabase = 'quan_ly_thu_vien_dev';
static const String postgresUsername = 'postgres';
static const String postgresPassword = '1234';
```

## 3. Kết nối từ Android Device (Điện thoại thật)

### Bước 1: Tìm IP máy tính
Chạy lệnh trong CMD:
```cmd
ipconfig
```
Tìm "IPv4 Address" (ví dụ: 192.168.1.100)

### Bước 2: Cấu hình PostgreSQL cho phép kết nối từ mạng
File: `C:\Program Files\PostgreSQL\15\data\postgresql.conf`
```
listen_addresses = '*'
```

File: `C:\Program Files\PostgreSQL\15\data\pg_hba.conf`
Thêm dòng:
```
host    all    all    0.0.0.0/0    md5
```

### Bước 3: Restart PostgreSQL
```cmd
net stop postgresql-x64-15
net start postgresql-x64-15
```

### Bước 4: Cấu hình trong Flutter
```dart
static const String postgresHost = '192.168.1.100';  // IP máy tính của bạn
static const int postgresPort = 5432;
static const String postgresDatabase = 'quan_ly_thu_vien_dev';
static const String postgresUsername = 'postgres';
static const String postgresPassword = '1234';
```

## 4. Kết nối qua Internet (Cloudflare Tunnel / Ngrok)

### Sử dụng Cloudflare Tunnel (Miễn phí):

1. Cài đặt cloudflared:
   ```cmd
   winget install Cloudflare.cloudflared
   ```

2. Tạo tunnel:
   ```cmd
   cloudflared tunnel --url tcp://localhost:5432
   ```

3. Copy URL tunnel (ví dụ: `random-name.trycloudflare.com`)

4. Cấu hình trong Flutter:
   ```dart
   static const String postgresHost = 'random-name.trycloudflare.com';
   static const int postgresPort = 7844;  // Port từ cloudflare
   static const String postgresDatabase = 'quan_ly_thu_vien_dev';
   static const String postgresUsername = 'postgres';
   static const String postgresPassword = '1234';
   ```

### Sử dụng Ngrok:

1. Tải ngrok: https://ngrok.com/download
2. Chạy:
   ```cmd
   ngrok tcp 5432
   ```
3. Copy địa chỉ forwarding (ví dụ: `0.tcp.ngrok.io:12345`)
4. Cấu hình tương tự Cloudflare

## 5. Kiểm Tra Kết Nối

### Test từ command line:
```cmd
psql -h localhost -U postgres -d quan_ly_thu_vien_dev -c "SELECT COUNT(*) FROM books;"
```

### Test từ Flutter app:
Chạy app và kiểm tra log để xem kết nối thành công hay không.

## 6. Troubleshooting

### Lỗi "Connection refused":
- Kiểm tra PostgreSQL service đang chạy
- Kiểm tra port 5432 không bị chặn bởi firewall

### Lỗi "Password authentication failed":
- Kiểm tra lại password trong config
- Đảm bảo user `postgres` có quyền truy cập database

### Lỗi timeout:
- Tăng `connectionTimeout` trong `database_config.dart`
- Kiểm tra kết nối mạng

### Android device không kết nối được:
- Đảm bảo máy tính và điện thoại cùng mạng WiFi
- Tắt Windows Firewall hoặc cho phép port 5432
- Kiểm tra `pg_hba.conf` đã cấu hình đúng
