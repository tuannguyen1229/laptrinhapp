#include "rfid_handler.h"

RFIDHandler::RFIDHandler() : lastUID(""), lastReadTime(0) {
    rfid = new MFRC522(RFID_CS_PIN, RFID_RST_PIN);
}

bool RFIDHandler::begin() {
    SPI.begin(RFID_SCK_PIN, RFID_MISO_PIN, RFID_MOSI_PIN, RFID_CS_PIN);
    rfid->PCD_Init();
    
    // Kiểm tra RFID reader
    byte version = rfid->PCD_ReadRegister(rfid->VersionReg);
    if (version == 0x00 || version == 0xFF) {
        DEBUG_PRINTLN("RFID reader not found!");
        return false;
    }
    
    DEBUG_PRINT("RFID reader initialized. Version: 0x");
    Serial.println(version, HEX);
    return true;
}

bool RFIDHandler::hasNewCard() {
    // Kiểm tra có thẻ mới không
    if (!rfid->PICC_IsNewCardPresent()) {
        return false;
    }
    
    // Đọc serial number
    if (!rfid->PICC_ReadCardSerial()) {
        return false;
    }
    
    // Debounce: tránh đọc cùng thẻ nhiều lần
    String currentUID = byteArrayToHexString(rfid->uid.uidByte, rfid->uid.size);
    unsigned long currentTime = millis();
    
    if (currentUID == lastUID && (currentTime - lastReadTime) < debounceTime) {
        return false;
    }
    
    lastUID = currentUID;
    lastReadTime = currentTime;
    
    return true;
}

String RFIDHandler::readCardUID() {
    String uid = byteArrayToHexString(rfid->uid.uidByte, rfid->uid.size);
    
    DEBUG_PRINT("[RFID] Card UID: ");
    DEBUG_PRINTLN(uid);
    
    return uid;
}

void RFIDHandler::haltCard() {
    rfid->PICC_HaltA();
    rfid->PCD_StopCrypto1();
}

String RFIDHandler::byteArrayToHexString(byte* buffer, byte bufferSize) {
    String result = "";
    for (byte i = 0; i < bufferSize; i++) {
        if (buffer[i] < 0x10) {
            result += "0";
        }
        result += String(buffer[i], HEX);
    }
    result.toUpperCase();
    return result;
}
