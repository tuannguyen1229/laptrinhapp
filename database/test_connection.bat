@echo off
chcp 65001 >nul
echo ========================================
echo Test PostgreSQL Connection
echo ========================================
echo.

set /p PGPASSWORD="Nhập password cho user postgres: "
echo.

echo Testing connection to localhost:5432...
psql -h localhost -U postgres -d quan_ly_thu_vien_dev -c "SELECT 'Connection successful!' as status;"

if %errorlevel% equ 0 (
    echo.
    echo [OK] Kết nối thành công!
    echo.
    echo Thống kê dữ liệu:
    psql -h localhost -U postgres -d quan_ly_thu_vien_dev -c "SELECT 'Books' as table_name, COUNT(*)::text as count FROM books UNION ALL SELECT 'Readers', COUNT(*)::text FROM readers UNION ALL SELECT 'Borrow Cards', COUNT(*)::text FROM borrow_cards UNION ALL SELECT 'Users', COUNT(*)::text FROM users;"
) else (
    echo.
    echo [ERROR] Không thể kết nối!
    echo Kiểm tra:
    echo - PostgreSQL service đang chạy
    echo - Password đúng
    echo - Database đã được tạo
)

echo.
pause
