#ifndef API_CLIENT_H
#define API_CLIENT_H

#include <Arduino.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "config.h"

// Struct để lưu response từ API
struct StudentInfo {
    bool success;
    String mssv;
    String name;
    String className;
    String phone;
    String email;
    String error;
};

struct BookInfo {
    bool success;
    String id;
    String title;
    String code;
    String author;
    bool available;
    String error;
};

class APIClient {
public:
    APIClient();
    
    // Gửi request quét thẻ sinh viên
    StudentInfo scanStudentCard(const String& cardUID);
    
    // Gửi request quét barcode sách
    BookInfo scanBookBarcode(const String& barcode);
    
    // Gửi heartbeat (check trạng thái thiết bị)
    bool sendHeartbeat();

private:
    HTTPClient http;
    
    // Helper: Tạo JSON payload
    String createStudentPayload(const String& cardUID);
    String createBookPayload(const String& barcode);
    String createHeartbeatPayload();
    
    // Helper: Parse JSON response
    StudentInfo parseStudentResponse(const String& jsonResponse);
    BookInfo parseBookResponse(const String& jsonResponse);
};

#endif // API_CLIENT_H
