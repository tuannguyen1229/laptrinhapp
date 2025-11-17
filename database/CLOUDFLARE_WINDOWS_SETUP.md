# 🌐 Setup Cloudflare Tunnel trên Windows (Từ đầu)

## Bước 1: Cài đặt cloudflared

```cmd
winget install Cloudflare.cloudflared
```

Hoặc tải trực tiếp: https://github.com/cloudflare/cloudflared/releases

Kiểm tra cài đặt:
```cmd
cloudflared --version
```

---

## Bước 2: Đăng nhập Cloudflare

```cmd
cloudflared tunnel login
```

- Lệnh này sẽ mở browser
- Đăng nhập Cloudflare account
- Chọn domain **nhutuan.io.vn**
- Sau khi authorize, file cert sẽ được lưu tại:
  ```
  C:\Users\<YourUsername>\.cloudflared\cert.pem
  ```

---

## Bước 3: Tạo Tunnel Mới

```cmd
cloudflared tunnel create library-tunnel
```

Lệnh này sẽ:
- Tạo tunnel với tên `library-tunnel`
- Tạo file credentials: `C:\Users\<YourUsername>\.cloudflared\<tunnel-id>.json`
- Hiển thị tunnel ID (lưu lại ID này!)

**Lưu tunnel ID**, ví dụ: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`

---

## Bước 4: Tạo File Config

Tạo file: `C:\Users\<YourUsername>\.cloudflared\config.yml`

```yaml
tunnel: <tunnel-id-từ-bước-3>
credentials-file: C:\Users\<YourUsername>\.cloudflared\<tunnel-id>.json

ingress:
  # Web app (localhost:3000)
  - hostname: nhutuan.io.vn
    service: http://localhost:3000
  
  # PostgreSQL database (localhost:5432)
  - hostname: db.nhutuan.io.vn
    service: tcp://localhost:5432
  
  # Catch-all rule (bắt buộc)
  - service: http_status:404
```

**Thay thế:**
- `<tunnel-id-từ-bước-3>` → Tunnel ID thực tế
- `<YourUsername>` → Username Windows của bạn

---

## Bước 5: Tạo DNS Records

### Cách 1: Tự động (Khuyến nghị)

```cmd
cloudflared tunnel route dns library-tunnel nhutuan.io.vn
cloudflared tunnel route dns library-tunnel db.nhutuan.io.vn
```

### Cách 2: Thủ công trong Cloudflare Dashboard

1. Vào: https://dash.cloudflare.com
2. Chọn domain **nhutuan.io.vn**
3. Vào tab **DNS**
4. Thêm 2 records:

**Record 1 (Web app):**
- Type: `CNAME`
- Name: `@` (hoặc `nhutuan.io.vn`)
- Target: `<tunnel-id>.cfargotunnel.com`
- Proxy: ✅ Proxied

**Record 2 (Database):**
- Type: `CNAME`
- Name: `db`
- Target: `<tunnel-id>.cfargotunnel.com`
- Proxy: ✅ Proxied

---

## Bước 6: Test Tunnel (Chạy thử)

```cmd
cloudflared tunnel run library-tunnel
```

Nếu thành công, bạn sẽ thấy:
```
INF Connection registered connIndex=0 location=... 
INF Connection registered connIndex=1 location=...
```

**Test kết nối:**
- Web: https://nhutuan.io.vn
- Database: `db.nhutuan.io.vn:5432`

Nhấn `Ctrl+C` để dừng.

---

## Bước 7: Cài đặt như Windows Service (Tự động chạy)

### 7.1. Cài service:
```cmd
cloudflared service install
```

### 7.2. Start service:
```cmd
net start cloudflared
```

### 7.3. Kiểm tra status:
```cmd
sc query cloudflared
```

### 7.4. Các lệnh quản lý service:
```cmd
# Start
net start cloudflared

# Stop
net stop cloudflared

# Restart
net stop cloudflared & net start cloudflared

# Uninstall service
cloudflared service uninstall
```

---

## Bước 8: Cấu hình PostgreSQL cho Remote Access

### 8.1. Đặt password cho postgres user:
```sql
ALTER USER postgres PASSWORD 'your-strong-password';
```

### 8.2. Sửa file postgresql.conf:
File: `C:\Program Files\PostgreSQL\15\data\postgresql.conf`

Tìm và sửa:
```
listen_addresses = '*'
```

### 8.3. Sửa file pg_hba.conf:
File: `C:\Program Files\PostgreSQL\15\data\pg_hba.conf`

Thêm dòng này (ở cuối phần IPv4):
```
host    all    all    0.0.0.0/0    md5
```

### 8.4. Restart PostgreSQL:
```cmd
net stop postgresql-x64-15
net start postgresql-x64-15
```

---

## Bước 9: Cập nhật Config trong Flutter

File: `lib/config/database/database_config.dart`

```dart
static const String postgresHost = 'db.nhutuan.io.vn';
static const int postgresPort = 5432;
static const String postgresDatabase = 'quan_ly_thu_vien_dev';
static const String postgresUsername = 'postgres';
static const String postgresPassword = 'your-strong-password'; // Password từ bước 8.1
```

---

## Bước 10: Test Kết Nối

### Từ máy local:
```cmd
psql -h db.nhutuan.io.vn -U postgres -d quan_ly_thu_vien_dev
```

### Từ Flutter app:
```bash
flutter run
```

Thử đăng nhập với:
- Username: `admin`
- Password: `admin123`

---

## 📊 Quản Lý Tunnel

### Xem danh sách tunnels:
```cmd
cloudflared tunnel list
```

### Xem thông tin tunnel:
```cmd
cloudflared tunnel info library-tunnel
```

### Xem logs:
```cmd
cloudflared tunnel logs library-tunnel
```

### Xóa tunnel (nếu cần):
```cmd
cloudflared tunnel delete library-tunnel
```

---

## 🔒 Bảo Mật Nâng Cao

### 1. Tạo user riêng cho app (không dùng postgres):

```sql
-- Tạo user mới
CREATE USER app_user WITH PASSWORD 'strong-app-password';

-- Cấp quyền
GRANT ALL PRIVILEGES ON DATABASE quan_ly_thu_vien_dev TO app_user;

-- Kết nối vào database
\c quan_ly_thu_vien_dev

-- Cấp quyền trên tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Cấp quyền cho tables tương lai
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO app_user;
```

Cập nhật config:
```dart
static const String postgresUsername = 'app_user';
static const String postgresPassword = 'strong-app-password';
```

### 2. Giới hạn kết nối trong pg_hba.conf:

```
# Chỉ cho phép database cụ thể
host    quan_ly_thu_vien_dev    app_user    0.0.0.0/0    md5
```

### 3. Firewall (Optional):

Nếu muốn chặn truy cập trực tiếp port 5432 (chỉ cho phép qua tunnel):

```cmd
# Chặn port 5432 từ bên ngoài
netsh advfirewall firewall add rule name="Block PostgreSQL External" dir=in action=block protocol=TCP localport=5432 remoteip=any

# Cho phép localhost
netsh advfirewall firewall add rule name="Allow PostgreSQL Localhost" dir=in action=allow protocol=TCP localport=5432 remoteip=127.0.0.1
```

---

## ❓ Troubleshooting

### Lỗi "tunnel credentials file not found"
→ Chạy lại: `cloudflared tunnel login`

### Lỗi "failed to sufficiently increase receive buffer size"
→ Bỏ qua, không ảnh hưởng

### Tunnel không start
→ Kiểm tra config.yml syntax (phải đúng YAML format)

### DNS không resolve
→ Đợi 1-2 phút để DNS propagate
→ Clear cache: `ipconfig /flushdns`

### PostgreSQL connection refused
→ Kiểm tra PostgreSQL đang chạy
→ Kiểm tra `listen_addresses` và `pg_hba.conf`

---

## 💡 Tips

### Auto-start tunnel khi Windows boot:
Service đã tự động start khi boot (nếu đã cài ở Bước 7)

### Xem tunnel status trong browser:
https://dash.cloudflare.com → **Zero Trust** → **Networks** → **Tunnels**

### Backup config:
```cmd
copy C:\Users\%USERNAME%\.cloudflared\config.yml C:\Users\%USERNAME%\.cloudflared\config.yml.backup
```

---

## 🎉 Hoàn Tất!

Bây giờ bạn có:
- ✅ Tunnel chạy tự động khi Windows boot
- ✅ Web app: https://nhutuan.io.vn
- ✅ Database: db.nhutuan.io.vn:5432
- ✅ Kết nối bảo mật qua Cloudflare
- ✅ Không cần mở port router
- ✅ Miễn phí hoàn toàn

Chia sẻ thông tin kết nối với team:
```
Host: db.nhutuan.io.vn
Port: 5432
Database: quan_ly_thu_vien_dev
Username: app_user (hoặc postgres)
Password: <password-bạn-đã-đặt>
```
