#ifndef RFID_HANDLER_H
#define RFID_HANDLER_H

#include <Arduino.h>
#include <MFRC522.h>
#include <SPI.h>
#include "config.h"

class RFIDHandler {
public:
    RFIDHandler();
    
    // Khởi tạo RFID reader
    bool begin();
    
    // Kiểm tra có thẻ mới không
    bool hasNewCard();
    
    // Đọc UID thẻ
    String readCardUID();
    
    // Dừng đọc thẻ hiện tại
    void haltCard();

private:
    MFRC522* rfid;
    String lastUID;
    unsigned long lastReadTime;
    const unsigned long debounceTime = 2000; // 2 giây debounce
    
    // Helper: Convert byte array to hex string
    String byteArrayToHexString(byte* buffer, byte bufferSize);
};

#endif // RFID_HANDLER_H
