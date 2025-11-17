@echo off
echo ========================================
echo Starting Cloudflare Tunnel...
echo ========================================
echo.
echo Tunnel: library-tunnel
echo Database: db.nhutuan.io.vn:5432
echo.
echo Giữ cửa sổ này mở để tunnel hoạt động
echo Nhấn Ctrl+C để dừng tunnel
echo.
echo ========================================
echo.

cloudflared tunnel run library-tunnel

pause
