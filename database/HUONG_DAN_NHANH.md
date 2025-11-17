# 🚀 Hướng Dẫn Setup PostgreSQL Nhanh (5 phút)

## Bước 1: Cài PostgreSQL (2 phút)

1. Tải PostgreSQL: https://www.postgresql.org/download/windows/
2. Chạy installer, chọn:
   - Port: **5432**
   - Password: **1234** (hoặc password bạn muốn, nhớ password này!)
   - Cài kèm **pgAdmin 4**

## Bước 2: Tạo Database (1 phút)

### Cách Nhanh - Dùng Script Tự Động:

```cmd
cd database
setup_database.bat
```

Nhập password bạn đã đặt ở Bước 1, xong!

### Cách Thủ Công - Dùng pgAdmin:

1. Mở **pgAdmin 4**
2. Nhập password
3. Chuột phải **Databases** → **Create** → **Database**
4. Tên: `quan_ly_thu_vien_dev` → **Save**
5. Chuột phải database vừa tạo → **Query Tool**
6. Copy nội dung file `setup_postgres.sql` → Paste → Click **Execute** (▶️)

## Bước 3: Cấu Hình Flutter App (1 phút)

Mở file: `lib/config/database/database_config.dart`

### Nếu chạy trên Windows Desktop:
```dart
static const String postgresHost = 'localhost';
static const String postgresPassword = '1234';  // Password bạn đã đặt
```

### Nếu chạy trên Android Emulator:
```dart
static const String postgresHost = '10.0.2.2';
static const String postgresPassword = '1234';
```

### Nếu chạy trên Android Device (điện thoại thật):

1. Tìm IP máy tính:
   ```cmd
   ipconfig
   ```
   Tìm dòng "IPv4 Address" (ví dụ: 192.168.1.100)

2. Cấu hình:
   ```dart
   static const String postgresHost = '192.168.1.100';  // IP máy tính
   static const String postgresPassword = '1234';
   ```

3. Cho phép kết nối từ mạng LAN:
   - Mở file: `C:\Program Files\PostgreSQL\15\data\postgresql.conf`
   - Sửa: `listen_addresses = '*'`
   - Mở file: `C:\Program Files\PostgreSQL\15\data\pg_hba.conf`
   - Thêm dòng: `host    all    all    0.0.0.0/0    md5`
   - Restart PostgreSQL:
     ```cmd
     net stop postgresql-x64-15
     net start postgresql-x64-15
     ```

## Bước 4: Kiểm Tra (30 giây)

```cmd
cd database
test_connection.bat
```

Nếu thấy "Connection successful!" → Hoàn tất! 🎉

## Bước 5: Chạy App

```bash
flutter pub get
flutter run
```

## ✅ Xong! Bạn đã có database local riêng!

### Dữ liệu mẫu có sẵn:
- ✅ 5 cuốn sách
- ✅ 5 độc giả
- ✅ 5 phiếu mượn
- ✅ 3 tài khoản user (admin, librarian, user)

### Tài khoản đăng nhập:
- Username: `admin` / Password: `admin123`
- Username: `librarian` / Password: `admin123`
- Username: `user` / Password: `admin123`

## ❓ Gặp vấn đề?

### Lỗi "Connection refused"
→ PostgreSQL chưa chạy, start service:
```cmd
net start postgresql-x64-15
```

### Lỗi "Password authentication failed"
→ Sai password, kiểm tra lại password trong config

### Android device không kết nối được
→ Kiểm tra:
- Máy tính và điện thoại cùng WiFi
- Đã cấu hình `postgresql.conf` và `pg_hba.conf`
- Đã restart PostgreSQL service
- Tắt Windows Firewall hoặc cho phép port 5432

## 📚 Tài liệu chi tiết

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Hướng dẫn đầy đủ
- [config_examples.md](config_examples.md) - Các ví dụ cấu hình
- [setup_postgres.sql](setup_postgres.sql) - Script SQL

## 💡 Tips

- Backup database thường xuyên:
  ```cmd
  pg_dump -U postgres -d quan_ly_thu_vien_dev -f backup.sql
  ```

- Xem dữ liệu trong pgAdmin 4 để dễ quản lý

- Nếu muốn reset database, chạy lại `setup_database.bat`
