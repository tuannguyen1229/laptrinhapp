# Tài liệu Yêu cầu - Ứng dụng Quản lý Thư viện

## Giới thiệu

Ứng dụng quản lý thư viện được phát triển bằng Flutter/Dart nhằm hỗ trợ việc quản lý toàn bộ quá trình mượn - trả sách trong thư viện một cách chính xác và tiện lợi. Ứng dụng giúp quản lý theo dõi sách đang được mượn, sách đã trả và cảnh báo sách quá hạn để xử lý kịp thời.

## Yêu cầu

### Yêu cầu 1 - Quản lý thẻ mượn sách (Nguyễn Như Tuấn)

**User Story:** Là một thủ thư, tôi muốn nhập thông tin thẻ mượn sách (tên sách, ngày mượn, ngày trả) để theo dõi việc mượn sách của độc giả.

#### Tiêu chí chấp nhận
1. WHEN thủ thư truy cập chức năng tạo thẻ mượn THEN hệ thống SHALL hiển thị form nhập liệu với các trường: tên người mượn, tên sách, ngày mượn, ngày dự kiến trả
2. WHEN thủ thư nhập tên người mượn THEN hệ thống SHALL cho phép chọn từ danh sách có sẵn hoặc nhập mới
3. WHEN thủ thư nhập tên sách THEN hệ thống SHALL cho phép nhập thủ công hoặc quét mã barcode/QR code
4. WHEN thủ thư chọn ngày mượn và ngày trả THEN hệ thống SHALL hiển thị date picker để chọn ngày
5. WHEN thủ thư hoàn tất nhập liệu và lưu THEN hệ thống SHALL lưu trữ thông tin vào cơ sở dữ liệu PostgreSQL
6. IF thông tin nhập thiếu hoặc không hợp lệ THEN hệ thống SHALL hiển thị thông báo lỗi cụ thể

### Yêu cầu 2 - Cảnh báo sách quá hạn (Nguyễn Thanh Tùng)

**User Story:** Là một thủ thư, tôi muốn được cảnh báo về các sách quá hạn để có thể xử lý kịp thời và nhắc nhở độc giả.

#### Tiêu chí chấp nhận
1. WHEN hệ thống khởi động THEN hệ thống SHALL tự động kiểm tra ngày trả dự kiến so với ngày hiện tại
2. IF sách chưa trả và đã quá ngày trả dự kiến THEN hệ thống SHALL đánh dấu trạng thái "quá hạn"
3. WHEN có sách quá hạn THEN hệ thống SHALL hiển thị cảnh báo với màu sắc đặc biệt (đỏ) và icon cảnh báo
4. WHEN thủ thư xem danh sách sách quá hạn THEN hệ thống SHALL hiển thị số ngày quá hạn
5. WHEN hệ thống phát hiện sách quá hạn THEN hệ thống SHALL gửi thông báo push notification (nếu có)
6. WHEN thủ thư truy cập dashboard THEN hệ thống SHALL hiển thị tổng số sách quá hạn ở vị trí nổi bật

### Yêu cầu 2.1 - Thông báo Email tự động (Nguyễn Thanh Tùng)

**User Story:** Là một thủ thư, tôi muốn hệ thống tự động gửi email thông báo cho người mượn khi sách sắp đến hạn hoặc quá hạn để giảm thiểu công việc nhắc nhở thủ công.

#### Tiêu chí chấp nhận
1. WHEN người mượn tạo thẻ mượn THEN hệ thống SHALL yêu cầu nhập email người mượn
2. WHEN sách còn 2-3 ngày nữa đến hạn THEN hệ thống SHALL tự động gửi email nhắc nhở
3. WHEN sách đến hạn trả hôm nay THEN hệ thống SHALL gửi email cảnh báo
4. WHEN sách quá hạn 1, 3, 7 ngày THEN hệ thống SHALL gửi email cảnh báo quá hạn
5. WHEN gửi email THEN hệ thống SHALL log kết quả gửi (thành công/thất bại)
6. WHEN thủ thư truy cập settings THEN hệ thống SHALL cho phép cấu hình SMTP và bật/tắt email notification
7. IF email không hợp lệ hoặc gửi thất bại THEN hệ thống SHALL log lỗi và thử lại sau

### Yêu cầu 3 - Tìm kiếm thẻ mượn (Lê Thọ Đức)

**User Story:** Là một thủ thư, tôi muốn tìm kiếm thẻ mượn theo tên sách hoặc tên người mượn để tra cứu thông tin nhanh chóng.

#### Tiêu chí chấp nhận
1. WHEN thủ thư truy cập chức năng tìm kiếm THEN hệ thống SHALL hiển thị ô nhập từ khóa tìm kiếm
2. WHEN thủ thư nhập từ khóa THEN hệ thống SHALL tìm kiếm theo tên sách hoặc tên người mượn
3. WHEN có kết quả tìm kiếm THEN hệ thống SHALL hiển thị danh sách kết quả dạng bảng với các cột: Mã thẻ, Tên sách, Người mượn, Ngày mượn, Ngày trả, Trạng thái
4. WHEN thủ thư gõ từ khóa THEN hệ thống SHALL thực hiện tìm kiếm tức thì (live search)
5. IF không tìm thấy kết quả THEN hệ thống SHALL hiển thị thông báo "Không tìm thấy kết quả"
6. WHEN tìm kiếm THEN hệ thống SHALL không phân biệt hoa thường và hỗ trợ tìm kiếm có/không dấu
7. WHEN có nhiều kết quả THEN hệ thống SHALL hỗ trợ bộ lọc bổ sung theo ngày mượn, trạng thái, thể loại sách

### Yêu cầu 4 - Quản lý danh sách thẻ mượn

**User Story:** Là một thủ thư, tôi muốn xem danh sách các thẻ đang mượn và đã trả để theo dõi tổng quan tình trạng sách trong thư viện.

#### Tiêu chí chấp nhận
1. WHEN thủ thư truy cập danh sách thẻ mượn THEN hệ thống SHALL hiển thị hai tab: "Đang mượn" và "Đã trả"
2. WHEN xem tab "Đang mượn" THEN hệ thống SHALL hiển thị các thẻ có trạng thái chưa trả sách
3. WHEN xem tab "Đã trả" THEN hệ thống SHALL hiển thị các thẻ đã hoàn thành việc mượn trả
4. IF danh sách có nhiều bản ghi THEN hệ thống SHALL hỗ trợ phân trang
5. WHEN thủ thư chọn một thẻ mượn THEN hệ thống SHALL hiển thị chi tiết thông tin thẻ
6. WHEN thủ thư cần cập nhật trạng thái THEN hệ thống SHALL cho phép đánh dấu "đã trả" cho thẻ đang mượn

### Yêu cầu 5 - Thống kê và báo cáo

**User Story:** Là một quản lý thư viện, tôi muốn xem thống kê số lần mượn theo người dùng và theo tháng để đánh giá hoạt động thư viện.

#### Tiêu chí chấp nhận
1. WHEN quản lý truy cập chức năng thống kê THEN hệ thống SHALL hiển thị các tùy chọn: "Theo người dùng" và "Theo tháng"
2. WHEN chọn thống kê theo người dùng THEN hệ thống SHALL hiển thị số lần mượn của từng người trong khoảng thời gian được chọn
3. WHEN chọn thống kê theo tháng THEN hệ thống SHALL hiển thị số lần mượn tổng theo các tháng trong năm
4. WHEN xem thống kê THEN hệ thống SHALL hiển thị dữ liệu dưới dạng bảng và biểu đồ
5. WHEN chọn khoảng thời gian THEN hệ thống SHALL cho phép lọc theo ngày bắt đầu và ngày kết thúc
6. WHEN xuất báo cáo THEN hệ thống SHALL cho phép xuất dữ liệu dưới dạng PDF hoặc Excel

### Yêu cầu 6 - Tích hợp IoT và quét mã

**User Story:** Là một thủ thư, tôi muốn sử dụng camera để quét barcode/QR code trên sách và thẻ người dùng để tăng tốc độ nhập liệu.

#### Tiêu chí chấp nhận
1. WHEN thủ thư chọn chức năng quét mã THEN hệ thống SHALL kích hoạt camera của thiết bị
2. WHEN quét barcode/QR code trên sách THEN hệ thống SHALL tự động điền thông tin sách vào form
3. WHEN quét thẻ người dùng THEN hệ thống SHALL tự động điền thông tin: Họ tên, Lớp, MSSV, SĐT
4. IF mã không được nhận diện THEN hệ thống SHALL hiển thị thông báo lỗi và cho phép nhập thủ công
5. WHEN quét thành công THEN hệ thống SHALL phát âm thanh xác nhận
6. IF thiết bị không có camera THEN hệ thống SHALL ẩn chức năng quét mã và chỉ cho phép nhập thủ công

### Yêu cầu 7 - Quản lý dữ liệu và bảo mật

**User Story:** Là một quản trị viên hệ thống, tôi muốn đảm bảo dữ liệu được lưu trữ an toàn và có thể sao lưu/khôi phục.

#### Tiêu chí chấp nhận
1. WHEN ứng dụng khởi động THEN hệ thống SHALL kết nối với cơ sở dữ liệu PostgreSQL
2. WHEN lưu dữ liệu THEN hệ thống SHALL mã hóa thông tin nhạy cảm
3. WHEN có lỗi kết nối THEN hệ thống SHALL hiển thị thông báo và cho phép thử lại
4. WHEN thực hiện thao tác quan trọng THEN hệ thống SHALL yêu cầu xác thực
5. IF mất kết nối internet THEN hệ thống SHALL lưu dữ liệu offline và đồng bộ khi có kết nối
6. WHEN sao lưu dữ liệu THEN hệ thống SHALL cho phép xuất/nhập dữ liệu định kỳ