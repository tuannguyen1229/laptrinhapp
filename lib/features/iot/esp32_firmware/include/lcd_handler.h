#ifndef LCD_HANDLER_H
#define LCD_HANDLER_H

#include <Arduino.h>
#include <LiquidCrystal_I2C.h>
#include "config.h"

class LCDHandler {
public:
    LCDHandler();
    
    // Khởi tạo LCD
    bool begin();
    
    // Hiển thị text
    void displayText(const char* line1, const char* line2 = "");
    
    // Hiển thị thông tin sinh viên
    void displayStudent(const char* name, const char* mssv);
    
    // Hiển thị thông tin sách
    void displayBook(const char* title, const char* code);
    
    // Hiển thị trạng thái
    void displayStatus(const char* status);
    
    // Hiển thị lỗi
    void displayError(const char* error);
    
    // Hiển thị "Đang xử lý..."
    void displayProcessing();
    
    // Hiển thị "Sẵn sàng"
    void displayReady();
    
    // Xóa màn hình
    void clear();
    
    // Bật/tắt backlight
    void setBacklight(bool on);

private:
    LiquidCrystal_I2C* lcd;
    
    // Helper: Cắt chuỗi cho vừa LCD (16 ký tự)
    String truncateString(const char* str, int maxLen);
    
    // Helper: Chuyển tiếng Việt có dấu sang không dấu (đơn giản)
    String removeVietnameseTones(const char* str);
};

#endif // LCD_HANDLER_H
