-- =====================================================
-- Script Setup PostgreSQL cho Quản Lý Thư Viện
-- =====================================================
-- Chạy script này trong PostgreSQL để tạo database và tables
-- Cách chạy:
--   1. Mở pgAdmin hoặc psql
--   2. Kết nối với PostgreSQL server
--   3. Chạy toàn bộ script này
-- =====================================================

-- Tạo database (nếu chưa có)
-- Lưu ý: Phải chạy lệnh này riêng nếu đang kết nối vào database khác
-- DROP DATABASE IF EXISTS quan_ly_thu_vien_dev;
-- CREATE DATABASE quan_ly_thu_vien_dev
--     WITH 
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'en_US.UTF-8'
--     LC_CTYPE = 'en_US.UTF-8'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1;

-- Kết nối vào database (trong psql: \c quan_ly_thu_vien_dev)

-- =====================================================
-- Bảng borrow_cards (Phiếu mượn sách)
-- =====================================================
CREATE TABLE IF NOT EXISTS borrow_cards (
    id SERIAL PRIMARY KEY,
    borrower_name VARCHAR(255) NOT NULL,
    borrower_class VARCHAR(100),
    borrower_student_id VARCHAR(50),
    borrower_phone VARCHAR(20),
    borrower_email VARCHAR(255),
    book_name VARCHAR(500) NOT NULL,
    book_code VARCHAR(100),
    borrow_date DATE NOT NULL,
    expected_return_date DATE NOT NULL,
    actual_return_date DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'borrowed',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index để tăng tốc truy vấn
CREATE INDEX IF NOT EXISTS idx_borrow_cards_status ON borrow_cards(status);
CREATE INDEX IF NOT EXISTS idx_borrow_cards_borrower_name ON borrow_cards(borrower_name);
CREATE INDEX IF NOT EXISTS idx_borrow_cards_borrower_email ON borrow_cards(borrower_email);
CREATE INDEX IF NOT EXISTS idx_borrow_cards_book_name ON borrow_cards(book_name);
CREATE INDEX IF NOT EXISTS idx_borrow_cards_borrow_date ON borrow_cards(borrow_date);
CREATE INDEX IF NOT EXISTS idx_borrow_cards_expected_return_date ON borrow_cards(expected_return_date);

-- =====================================================
-- Bảng books (Sách)
-- =====================================================
CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    book_code VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    author VARCHAR(255),
    category VARCHAR(100),
    isbn VARCHAR(50),
    publisher VARCHAR(255),
    publish_year INTEGER,
    total_copies INTEGER NOT NULL DEFAULT 1,
    available_copies INTEGER NOT NULL DEFAULT 1,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index cho books
CREATE INDEX IF NOT EXISTS idx_books_book_code ON books(book_code);
CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);
CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);
CREATE INDEX IF NOT EXISTS idx_books_category ON books(category);

-- =====================================================
-- Bảng readers (Độc giả)
-- =====================================================
CREATE TABLE IF NOT EXISTS readers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    student_id VARCHAR(50) UNIQUE,
    class VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    date_of_birth DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index cho readers
CREATE INDEX IF NOT EXISTS idx_readers_student_id ON readers(student_id);
CREATE INDEX IF NOT EXISTS idx_readers_name ON readers(name);
CREATE INDEX IF NOT EXISTS idx_readers_class ON readers(class);

-- =====================================================
-- Function để tự động cập nhật updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger cho borrow_cards
DROP TRIGGER IF EXISTS update_borrow_cards_updated_at ON borrow_cards;
CREATE TRIGGER update_borrow_cards_updated_at
    BEFORE UPDATE ON borrow_cards
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger cho books
DROP TRIGGER IF EXISTS update_books_updated_at ON books;
CREATE TRIGGER update_books_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger cho readers
DROP TRIGGER IF EXISTS update_readers_updated_at ON readers;
CREATE TRIGGER update_readers_updated_at
    BEFORE UPDATE ON readers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Bảng users (Người dùng hệ thống - Authentication)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Index cho users
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Trigger cho users
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Bảng password_reset_tokens (Token reset mật khẩu)
-- =====================================================
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index cho password_reset_tokens
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

-- =====================================================
-- Bảng login_history (Lịch sử đăng nhập)
-- =====================================================
CREATE TABLE IF NOT EXISTS login_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    device_info TEXT,
    ip_address VARCHAR(50),
    success BOOLEAN DEFAULT true
);

-- Index cho login_history
CREATE INDEX IF NOT EXISTS idx_login_history_user_id ON login_history(user_id);
CREATE INDEX IF NOT EXISTS idx_login_history_login_time ON login_history(login_time);

-- =====================================================
-- Dữ liệu mẫu (Sample Data)
-- =====================================================

-- Thêm user mẫu (password: "admin123" đã hash)
-- Lưu ý: Trong production, password phải được hash bằng bcrypt
INSERT INTO users (username, email, password_hash, full_name, role, is_active) VALUES
('admin', 'admin@library.com', '$2a$10$rKvqLZZ9Z9Z9Z9Z9Z9Z9ZuXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxX', 'Quản trị viên', 'admin', true),
('librarian', 'librarian@library.com', '$2a$10$rKvqLZZ9Z9Z9Z9Z9Z9Z9ZuXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxX', 'Thủ thư', 'librarian', true),
('user', 'user@library.com', '$2a$10$rKvqLZZ9Z9Z9Z9Z9Z9Z9ZuXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxX', 'Người dùng', 'user', true)
ON CONFLICT (username) DO NOTHING;

-- =============================================

-- Thêm sách mẫu
INSERT INTO books (book_code, title, author, category, isbn, publisher, publish_year, total_copies, available_copies, description) VALUES
('BK001', 'Lập trình Flutter cơ bản', 'Nguyễn Văn A', 'Công nghệ', '978-604-1-00001-1', 'NXB Trẻ', 2023, 5, 4, 'Sách hướng dẫn lập trình Flutter từ cơ bản đến nâng cao'),
('BK002', 'Dart Programming', 'Trần Thị B', 'Công nghệ', '978-604-1-00002-2', 'NXB Giáo dục', 2023, 3, 3, 'Giáo trình lập trình Dart'),
('BK003', 'Toán học rời rạc', 'Lê Văn C', 'Toán học', '978-604-1-00003-3', 'NXB Đại học Quốc gia', 2022, 10, 8, 'Giáo trình toán học rời rạc'),
('BK004', 'Cấu trúc dữ liệu và giải thuật', 'Phạm Văn D', 'Công nghệ', '978-604-1-00004-4', 'NXB Thông tin và Truyền thông', 2023, 7, 6, 'Sách về cấu trúc dữ liệu và giải thuật'),
('BK005', 'Cơ sở dữ liệu', 'Hoàng Thị E', 'Công nghệ', '978-604-1-00005-5', 'NXB Khoa học và Kỹ thuật', 2022, 8, 7, 'Giáo trình cơ sở dữ liệu')
ON CONFLICT (book_code) DO NOTHING;

-- Thêm độc giả mẫu
INSERT INTO readers (name, student_id, class, phone, email, address, date_of_birth) VALUES
('Nguyễn Văn An', 'SV001', '12A1', '0901234567', 'an.nguyen@email.com', 'Hà Nội', '2005-03-15'),
('Trần Thị Bình', 'SV002', '12A2', '0902345678', 'binh.tran@email.com', 'Hồ Chí Minh', '2005-05-20'),
('Lê Văn Cường', 'SV003', '12A1', '0903456789', 'cuong.le@email.com', 'Đà Nẵng', '2005-07-10'),
('Phạm Thị Dung', 'SV004', '12A3', '0904567890', 'dung.pham@email.com', 'Hải Phòng', '2005-02-28'),
('Hoàng Văn Em', 'SV005', '12A2', '0905678901', 'em.hoang@email.com', 'Cần Thơ', '2005-09-05')
ON CONFLICT (student_id) DO NOTHING;

-- Thêm phiếu mượn mẫu
INSERT INTO borrow_cards (borrower_name, borrower_class, borrower_student_id, borrower_phone, borrower_email, book_name, book_code, borrow_date, expected_return_date, actual_return_date, status) VALUES
('Nguyễn Văn An', '12A1', 'SV001', '0901234567', 'an.nguyen@email.com', 'Lập trình Flutter cơ bản', 'BK001', '2025-01-05', '2025-01-19', NULL, 'borrowed'),
('Trần Thị Bình', '12A2', 'SV002', '0902345678', 'binh.tran@email.com', 'Toán học rời rạc', 'BK003', '2025-01-08', '2025-01-22', NULL, 'borrowed'),
('Lê Văn Cường', '12A1', 'SV003', '0903456789', 'cuong.le@email.com', 'Cấu trúc dữ liệu và giải thuật', 'BK004', '2024-12-20', '2025-01-03', '2025-01-02', 'returned'),
('Phạm Thị Dung', '12A3', 'SV004', '0904567890', 'dung.pham@email.com', 'Cơ sở dữ liệu', 'BK005', '2024-12-25', '2025-01-08', NULL, 'overdue'),
('Hoàng Văn Em', '12A2', 'SV005', '0905678901', 'em.hoang@email.com', 'Toán học rời rạc', 'BK003', '2025-01-10', '2025-01-24', NULL, 'borrowed')
ON CONFLICT DO NOTHING;

-- =====================================================
-- Views hữu ích
-- =====================================================

-- View: Thống kê sách đang được mượn
CREATE OR REPLACE VIEW v_borrowed_books_summary AS
SELECT 
    b.book_code,
    b.title,
    b.total_copies,
    b.available_copies,
    COUNT(bc.id) as currently_borrowed
FROM books b
LEFT JOIN borrow_cards bc ON b.book_code = bc.book_code AND bc.status = 'borrowed'
GROUP BY b.id, b.book_code, b.title, b.total_copies, b.available_copies;

-- View: Phiếu mượn quá hạn
CREATE OR REPLACE VIEW v_overdue_borrow_cards AS
SELECT 
    bc.*,
    CURRENT_DATE - bc.expected_return_date as days_overdue
FROM borrow_cards bc
WHERE bc.status != 'returned' 
  AND bc.expected_return_date < CURRENT_DATE
ORDER BY bc.expected_return_date ASC;

-- View: Thống kê độc giả
CREATE OR REPLACE VIEW v_reader_statistics AS
SELECT 
    r.id,
    r.name,
    r.student_id,
    r.class,
    COUNT(bc.id) as total_borrows,
    COUNT(CASE WHEN bc.status = 'borrowed' THEN 1 END) as current_borrows,
    COUNT(CASE WHEN bc.status = 'returned' THEN 1 END) as returned_borrows,
    COUNT(CASE WHEN bc.status = 'overdue' THEN 1 END) as overdue_borrows
FROM readers r
LEFT JOIN borrow_cards bc ON r.student_id = bc.borrower_student_id
GROUP BY r.id, r.name, r.student_id, r.class;

-- =====================================================
-- Hoàn thành!
-- =====================================================

-- Kiểm tra kết quả
SELECT 'Số lượng sách:' as info, COUNT(*) as count FROM books
UNION ALL
SELECT 'Số lượng độc giả:', COUNT(*) FROM readers
UNION ALL
SELECT 'Số lượng phiếu mượn:', COUNT(*) FROM borrow_cards;

-- Hiển thị thông tin tables
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

COMMENT ON TABLE borrow_cards IS 'Bảng quản lý phiếu mượn sách';
COMMENT ON TABLE books IS 'Bảng quản lý sách trong thư viện';
COMMENT ON TABLE readers IS 'Bảng quản lý độc giả';
COMMENT ON COLUMN borrow_cards.borrower_email IS 'Email người mượn để gửi thông báo quá hạn';
