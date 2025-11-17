@echo off
chcp 65001 >nul
echo ========================================
echo Setup Cloudflare Tunnel cho PostgreSQL
echo ========================================
echo.

REM Kiểm tra cloudflared đã cài chưa
where cloudflared >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] cloudflared chưa được cài đặt
    echo.
    echo Cài đặt bằng lệnh:
    echo   winget install Cloudflare.cloudflared
    echo.
    echo Hoặc tải từ: https://github.com/cloudflare/cloudflared/releases
    pause
    exit /b 1
)

echo [OK] cloudflared đã được cài đặt
cloudflared --version
echo.

echo ========================================
echo Các bước tiếp theo:
echo ========================================
echo.
echo 1. Đăng nhập Cloudflare:
echo    cloudflared tunnel login
echo.
echo 2. Tạo tunnel mới:
echo    cloudflared tunnel create library-tunnel
echo.
echo 3. Tạo file config.yml tại:
echo    C:\Users\%USERNAME%\.cloudflared\config.yml
echo.
echo 4. Tạo DNS records:
echo    cloudflared tunnel route dns library-tunnel nhutuan.io.vn
echo    cloudflared tunnel route dns library-tunnel db.nhutuan.io.vn
echo.
echo 5. Test tunnel:
echo    cloudflared tunnel run library-tunnel
echo.
echo 6. Cài service (tự động chạy):
echo    cloudflared service install
echo    net start cloudflared
echo.
echo ========================================
echo Xem hướng dẫn chi tiết:
echo database/CLOUDFLARE_WINDOWS_SETUP.md
echo ========================================
echo.
pause
