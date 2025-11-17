@echo off
echo ========================================
echo Stopping Cloudflare Tunnel...
echo ========================================
echo.

taskkill /F /IM cloudflared.exe

echo.
echo Tunnel đã dừng!
echo.
pause
