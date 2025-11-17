# 🌐 Hướng Dẫn Kết Nối Database

## 📦 Thông Tin Database

```
Host: db.nhutuan.io.vn
Port: 5432
Database: quan_ly_thu_vien_dev
Username: postgres
Password: (để trống)
```

---

## 🚀 Cách Kết Nối

### Bước 1: Clone Project

```bash
git clone <repository-url>
cd laptrinhapp
flutter pub get
```

### Bước 2: Cấu Hình Kết Nối

Mở file: `lib/config/database/database_config.dart`

Tìm dòng:
```dart
static const String connectionMode = 'remote'; // ⬅️ Đảm bảo là 'remote'
```

**Đảm bảo giá trị là `'remote'`** để kết nối qua internet.

### Bước 3: Chạy App

```bash
flutter run
```

### Bước 4: Đăng Nhập

```
Username: admin
Password: admin123
```

---

## 🔧 Troubleshooting

### Lỗi "Connection timeout"

**Nguyên nhân 1:** Tunnel chưa chạy trên máy chủ

**Giải pháp:** Liên hệ người quản lý database để start tunnel.

**Nguyên nhân 2:** Android Emulator không resolve được DNS

**Giải pháp:**
1. Set DNS Google cho emulator:
   - Settings → Network & Internet → Wi-Fi
   - Long press AndroidWifi → Modify network
   - Advanced → IP settings → Static
   - DNS 1: `8.8.8.8`, DNS 2: `8.8.4.4`

2. Hoặc chạy trên Windows Desktop:
   ```bash
   flutter run -d windows
   ```

---

### Lỗi "Host not found"

**Nguyên nhân:** DNS chưa propagate hoặc không có internet

**Giải pháp:** 
- Kiểm tra kết nối internet
- Thử lại sau 1-2 phút
- Clear DNS cache: `ipconfig /flushdns` (Windows)

---

### Lỗi "Authentication failed"

**Nguyên nhân:** Sai username/password

**Giải pháp:** Đảm bảo config đúng:
```dart
static const String postgresUsername = 'postgres';
static const String postgresPassword = ''; // Để trống
```

---

## 👥 Dành Cho Người Quản Lý Database

### Start Tunnel (Bắt buộc để người khác kết nối)

**Cách 1: Chạy thủ công**
```cmd
cloudflared tunnel run library-tunnel
```

**Cách 2: Chạy ngầm**
- Double-click: `database/start_tunnel_hidden.vbs`

**Cách 3: Cài service (tự động chạy)**
```cmd
cloudflared service install
net start cloudflared
```

### Stop Tunnel
```cmd
database/stop_tunnel.bat
```

### Kiểm tra tunnel đang chạy
```cmd
tasklist | findstr cloudflared
```

---

## 📊 Chế Độ Kết Nối

### Remote Mode (Mặc định - Cho team)
```dart
static const String connectionMode = 'remote';
```
- ✅ Mọi người kết nối qua internet
- ✅ Không cần cùng mạng WiFi
- ⚠️ Cần tunnel chạy trên máy chủ

### Local Mode (Chỉ cho developer)
```dart
static const String connectionMode = 'local';
```
- ✅ Kết nối nhanh hơn
- ❌ Chỉ máy local kết nối được
- ❌ Người khác không dùng được

---

## 🔐 Bảo Mật

- Database hiện tại **không có password** (chỉ dùng cho development)
- Không chia sẻ thông tin kết nối ra ngoài team
- Trong production, cần đặt password mạnh

---

## 📞 Liên Hệ

Nếu gặp vấn đề, liên hệ người quản lý database:
- Email: [email của bạn]
- Phone: [số điện thoại]

---

## ✅ Checklist Kết Nối Thành Công

- [ ] Clone project và chạy `flutter pub get`
- [ ] Đảm bảo `connectionMode = 'remote'` trong config
- [ ] Tunnel đang chạy trên máy chủ
- [ ] Có kết nối internet
- [ ] Chạy `flutter run` thành công
- [ ] Đăng nhập được với `admin` / `admin123`

---

**Chúc bạn code vui vẻ! 🎉**
