# Hướng Dẫn Setup PostgreSQL Local

## 1. Cài Đặt PostgreSQL

### Windows:
1. Tải PostgreSQL từ: https://www.postgresql.org/download/windows/
2. Chạy installer và cài đặt với các thông số:
   - Port: **5432** (mặc định)
   - Password cho user `postgres`: **1234** (hoặc password bạn muốn)
   - Cài kèm pgAdmin 4

### Kiểm tra cài đặt:
```cmd
psql --version
```

## 2. Tạo Database và Import Dữ Liệu

### Cách 1: Dùng pgAdmin 4 (Đơn giản nhất)

1. Mở **pgAdmin 4**
2. Kết nối PostgreSQL server (nhập password)
3. Tạo database:
   - Chuột phải **Databases** → **Create** → **Database**
   - Database name: `quan_ly_thu_vien_dev`
   - Owner: `postgres`
   - Click **Save**
4. Import dữ liệu:
   - Chuột phải database vừa tạo → **Query Tool**
   - Copy nội dung file `setup_postgres.sql`
   - Paste vào Query Tool
   - Click **Execute** (▶️)

### Cách 2: Dùng Command Line

```cmd
REM Tạo database
psql -U postgres -c "CREATE DATABASE quan_ly_thu_vien_dev;"

REM Import dữ liệu
psql -U postgres -d quan_ly_thu_vien_dev -f setup_postgres.sql
```

## 3. Cấu Hình Kết Nối trong Flutter App

### Cho Windows Desktop App:
File: `lib/config/database/database_config.dart`

```dart
static const String postgresHost = 'localhost';  // hoặc '127.0.0.1'
static const int postgresPort = 5432;
static const String postgresDatabase = 'quan_ly_thu_vien_dev';
static const String postgresUsername = 'postgres';
static const String postgresPassword = '1234';  // Password bạn đã đặt
```

### Cho Android Emulator:
```dart
static const String postgresHost = '10.0.2.2';  // IP đặc biệt của emulator
```

### Cho Android Device (Điện thoại thật):
```dart
static const String postgresHost = '192.168.x.x';  // IP máy tính trong mạng LAN
```

**Cách tìm IP máy tính:**
```cmd
ipconfig
```
Tìm dòng "IPv4 Address" trong phần "Wireless LAN adapter Wi-Fi" hoặc "Ethernet adapter"

## 4. Kiểm Tra Kết Nối

### Test kết nối database:
```cmd
psql -U postgres -d quan_ly_thu_vien_dev -c "SELECT COUNT(*) FROM books;"
```

Kết quả mong đợi: Hiển thị số lượng sách (5 sách mẫu)

### Xem dữ liệu:
```sql
-- Xem sách
SELECT * FROM books;

-- Xem độc giả
SELECT * FROM readers;

-- Xem phiếu mượn
SELECT * FROM borrow_cards;

-- Xem users
SELECT username, email, role FROM users;
```

## 5. Troubleshooting

### Lỗi: "Connection refused"
- Kiểm tra PostgreSQL service đang chạy:
  ```cmd
  sc query postgresql-x64-15
  ```
- Nếu stopped, start service:
  ```cmd
  net start postgresql-x64-15
  ```

### Lỗi: "Password authentication failed"
- Kiểm tra lại password trong config
- Reset password nếu cần:
  ```cmd
  psql -U postgres
  ALTER USER postgres PASSWORD '1234';
  ```

### Lỗi: Android không kết nối được
- Với Emulator: Dùng `10.0.2.2`
- Với Device thật: 
  - Kiểm tra máy tính và điện thoại cùng mạng WiFi
  - Tắt Windows Firewall hoặc cho phép port 5432
  - Sửa file `pg_hba.conf` thêm dòng:
    ```
    host    all    all    0.0.0.0/0    md5
    ```
  - Restart PostgreSQL service

### Cho phép kết nối từ mạng LAN (cho Android device):

1. Tìm file `postgresql.conf` (thường ở `C:\Program Files\PostgreSQL\15\data\`)
2. Sửa dòng:
   ```
   listen_addresses = '*'
   ```
3. Tìm file `pg_hba.conf` (cùng thư mục)
4. Thêm dòng:
   ```
   host    all    all    0.0.0.0/0    md5
   ```
5. Restart PostgreSQL service

## 6. Backup và Restore

### Backup database:
```cmd
pg_dump -U postgres -d quan_ly_thu_vien_dev -f backup.sql
```

### Restore database:
```cmd
psql -U postgres -d quan_ly_thu_vien_dev -f backup.sql
```

## 7. Thông Tin Đăng Nhập Mẫu

Sau khi import dữ liệu, bạn có 3 tài khoản mẫu:

| Username   | Password   | Role      |
|------------|------------|-----------|
| admin      | admin123   | admin     |
| librarian  | admin123   | librarian |
| user       | admin123   | user      |

**Lưu ý:** Password đã được hash trong database, cần implement authentication để sử dụng.

## 8. Dữ Liệu Mẫu Có Sẵn

- **5 cuốn sách** (books)
- **5 độc giả** (readers)
- **5 phiếu mượn** (borrow_cards)
- **3 users** (users)

Tất cả dữ liệu này sẽ được tự động tạo khi chạy script `setup_postgres.sql`.
