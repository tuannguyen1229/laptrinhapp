-- =====================================================
-- Script Cập Nhật Password cho Users
-- =====================================================
-- Chạy script này để cập nhật password thành plain text
-- (Chỉ dùng cho development, không dùng trong production!)
-- =====================================================

-- Cập nhật password thành plain text để dễ test
UPDATE users SET password_hash = 'admin123' WHERE username = 'admin';
UPDATE users SET password_hash = 'admin123' WHERE username = 'librarian';
UPDATE users SET password_hash = 'admin123' WHERE username = 'user';

-- Kiểm tra kết quả
SELECT username, password_hash, role FROM users;

-- =====================================================
-- Hoàn tất!
-- =====================================================
