#include "lcd_handler.h"
#include <Wire.h>

LCDHandler::LCDHandler() {
    lcd = new LiquidCrystal_I2C(LCD_ADDRESS, LCD_COLS, LCD_ROWS);
}

bool LCDHandler::begin() {
    // Initialize I2C with custom pins for ESP32-S3
    Wire.begin(LCD_SDA_PIN, LCD_SCL_PIN);
    
    lcd->init();
    lcd->backlight();
    lcd->clear();
    
    // Test display
    lcd->setCursor(0, 0);
    lcd->print("Khoi dong...");
    delay(1000);
    
    DEBUG_PRINTLN("LCD initialized");
    return true;
}

void LCDHandler::displayText(const char* line1, const char* line2) {
    lcd->clear();
    
    lcd->setCursor(0, 0);
    lcd->print(truncateString(line1, LCD_COLS));
    
    if (strlen(line2) > 0) {
        lcd->setCursor(0, 1);
        lcd->print(truncateString(line2, LCD_COLS));
    }
}

void LCDHandler::displayStudent(const char* name, const char* mssv) {
    lcd->clear();
    
    // Dòng 1: Tên sinh viên (bỏ dấu)
    String nameStr = removeVietnameseTones(name);
    lcd->setCursor(0, 0);
    lcd->print(truncateString(nameStr.c_str(), LCD_COLS));
    
    // Dòng 2: MSSV
    lcd->setCursor(0, 1);
    lcd->print("MSSV:");
    lcd->print(mssv);
    
    DEBUG_PRINTLN("[LCD] Displaying student info");
}

void LCDHandler::displayBook(const char* title, const char* code) {
    lcd->clear();
    
    // Dòng 1: Tên sách (bỏ dấu)
    String titleStr = removeVietnameseTones(title);
    lcd->setCursor(0, 0);
    lcd->print(truncateString(titleStr.c_str(), LCD_COLS));
    
    // Dòng 2: Mã sách
    lcd->setCursor(0, 1);
    lcd->print("Ma:");
    lcd->print(code);
    
    DEBUG_PRINTLN("[LCD] Displaying book info");
}

void LCDHandler::displayStatus(const char* status) {
    lcd->clear();
    lcd->setCursor(0, 0);
    lcd->print(truncateString(status, LCD_COLS));
}

void LCDHandler::displayError(const char* error) {
    lcd->clear();
    lcd->setCursor(0, 0);
    lcd->print("LOI!");
    lcd->setCursor(0, 1);
    lcd->print(truncateString(error, LCD_COLS));
    
    DEBUG_PRINT("[LCD] Error: ");
    DEBUG_PRINTLN(error);
}

void LCDHandler::displayProcessing() {
    lcd->clear();
    lcd->setCursor(0, 0);
    lcd->print("Dang xu ly...");
}

void LCDHandler::displayReady() {
    lcd->clear();
    lcd->setCursor(0, 0);
    lcd->print("San sang!");
    lcd->setCursor(0, 1);
    lcd->print("Quet the/sach");
}

void LCDHandler::clear() {
    lcd->clear();
}

void LCDHandler::setBacklight(bool on) {
    if (on) {
        lcd->backlight();
    } else {
        lcd->noBacklight();
    }
}

String LCDHandler::truncateString(const char* str, int maxLen) {
    String result = String(str);
    if (result.length() > maxLen) {
        result = result.substring(0, maxLen);
    }
    return result;
}

String LCDHandler::removeVietnameseTones(const char* str) {
    // Đơn giản hóa: chỉ giữ ASCII
    // Trong thực tế, cần map đầy đủ: á->a, đ->d, etc.
    String result = "";
    for (int i = 0; i < strlen(str); i++) {
        char c = str[i];
        // Chỉ giữ ký tự ASCII printable
        if (c >= 32 && c <= 126) {
            result += c;
        }
    }
    return result;
}
