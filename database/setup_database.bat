@echo off
chcp 65001 >nul
echo ========================================
echo Setup PostgreSQL Database
echo ========================================
echo.

REM Kiểm tra PostgreSQL đã cài chưa
where psql >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PostgreSQL chưa được cài đặt hoặc chưa thêm vào PATH
    echo Vui lòng cài đặt PostgreSQL từ: https://www.postgresql.org/download/windows/
    pause
    exit /b 1
)

echo [OK] PostgreSQL đã được cài đặt
echo.

REM Nhập password
set /p PGPASSWORD="Nhập password cho user postgres: "
echo.

echo [1/3] Tạo database...
psql -U postgres -c "DROP DATABASE IF EXISTS quan_ly_thu_vien_dev;" 2>nul
psql -U postgres -c "CREATE DATABASE quan_ly_thu_vien_dev;"
if %errorlevel% neq 0 (
    echo [ERROR] Không thể tạo database. Kiểm tra password và PostgreSQL service.
    pause
    exit /b 1
)
echo [OK] Database đã được tạo
echo.

echo [2/3] Import dữ liệu từ setup_postgres.sql...
psql -U postgres -d quan_ly_thu_vien_dev -f setup_postgres.sql
if %errorlevel% neq 0 (
    echo [ERROR] Không thể import dữ liệu
    pause
    exit /b 1
)
echo [OK] Dữ liệu đã được import
echo.

echo [3/3] Kiểm tra dữ liệu...
psql -U postgres -d quan_ly_thu_vien_dev -c "SELECT 'Books: ' || COUNT(*)::text FROM books UNION ALL SELECT 'Readers: ' || COUNT(*)::text FROM readers UNION ALL SELECT 'Borrow Cards: ' || COUNT(*)::text FROM borrow_cards;"
echo.

echo ========================================
echo Setup hoàn tất!
echo ========================================
echo Database: quan_ly_thu_vien_dev
echo Host: localhost
echo Port: 5432
echo Username: postgres
echo.
echo Bạn có thể kết nối từ Flutter app bằng cách cập nhật:
echo lib/config/database/database_config.dart
echo.
pause
