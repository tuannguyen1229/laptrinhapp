#include "api_client.h"

APIClient::APIClient() {}

StudentInfo APIClient::scanStudentCard(const String& cardUID) {
    StudentInfo result;
    result.success = false;
    
    String url = String(API_BASE_URL) + String(API_SCAN_STUDENT);
    String payload = createStudentPayload(cardUID);
    
    DEBUG_PRINT("[API] POST ");
    DEBUG_PRINTLN(url);
    DEBUG_PRINT("[API] Payload: ");
    DEBUG_PRINTLN(payload);
    
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.setTimeout(API_TIMEOUT);
    
    int httpCode = http.POST(payload);
    
    if (httpCode > 0) {
        DEBUG_PRINT("[API] Response code: ");
        DEBUG_PRINTLN(httpCode);
        
        if (httpCode == HTTP_CODE_OK) {
            String response = http.getString();
            DEBUG_PRINT("[API] Response: ");
            DEBUG_PRINTLN(response);
            
            result = parseStudentResponse(response);
        } else {
            result.error = "HTTP Error: " + String(httpCode);
        }
    } else {
        result.error = "Connection failed: " + http.errorToString(httpCode);
        DEBUG_PRINT("[API] Error: ");
        DEBUG_PRINTLN(result.error);
    }
    
    http.end();
    return result;
}

BookInfo APIClient::scanBookBarcode(const String& barcode) {
    BookInfo result;
    result.success = false;
    
    String url = String(API_BASE_URL) + String(API_SCAN_BOOK);
    String payload = createBookPayload(barcode);
    
    DEBUG_PRINT("[API] POST ");
    DEBUG_PRINTLN(url);
    DEBUG_PRINT("[API] Payload: ");
    DEBUG_PRINTLN(payload);
    
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.setTimeout(API_TIMEOUT);
    
    int httpCode = http.POST(payload);
    
    if (httpCode > 0) {
        DEBUG_PRINT("[API] Response code: ");
        DEBUG_PRINTLN(httpCode);
        
        if (httpCode == HTTP_CODE_OK) {
            String response = http.getString();
            DEBUG_PRINT("[API] Response: ");
            DEBUG_PRINTLN(response);
            
            result = parseBookResponse(response);
        } else {
            result.error = "HTTP Error: " + String(httpCode);
        }
    } else {
        result.error = "Connection failed: " + http.errorToString(httpCode);
        DEBUG_PRINT("[API] Error: ");
        DEBUG_PRINTLN(result.error);
    }
    
    http.end();
    return result;
}

bool APIClient::sendHeartbeat() {
    String url = String(API_BASE_URL) + String(API_HEARTBEAT);
    String payload = createHeartbeatPayload();
    
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.setTimeout(5000);
    
    int httpCode = http.POST(payload);
    bool success = (httpCode == HTTP_CODE_OK);
    
    http.end();
    return success;
}

String APIClient::createStudentPayload(const String& cardUID) {
    StaticJsonDocument<200> doc;
    doc["card_uid"] = cardUID;
    doc["device_id"] = DEVICE_ID;
    doc["timestamp"] = millis();
    
    String output;
    serializeJson(doc, output);
    return output;
}

String APIClient::createBookPayload(const String& barcode) {
    StaticJsonDocument<200> doc;
    doc["barcode"] = barcode;
    doc["device_id"] = DEVICE_ID;
    doc["timestamp"] = millis();
    
    String output;
    serializeJson(doc, output);
    return output;
}

String APIClient::createHeartbeatPayload() {
    StaticJsonDocument<200> doc;
    doc["device_id"] = DEVICE_ID;
    doc["device_name"] = DEVICE_NAME;
    doc["location"] = DEVICE_LOCATION;
    doc["timestamp"] = millis();
    
    String output;
    serializeJson(doc, output);
    return output;
}

StudentInfo APIClient::parseStudentResponse(const String& jsonResponse) {
    StudentInfo result;
    
    StaticJsonDocument<512> doc;
    DeserializationError error = deserializeJson(doc, jsonResponse);
    
    if (error) {
        result.success = false;
        result.error = "JSON parse error";
        return result;
    }
    
    result.success = doc["success"] | false;
    
    if (result.success) {
        JsonObject student = doc["student"];
        result.mssv = student["mssv"].as<String>();
        result.name = student["name"].as<String>();
        result.className = student["class"].as<String>();
        result.phone = student["phone"].as<String>();
        result.email = student["email"].as<String>();
    } else {
        result.error = doc["error"].as<String>();
    }
    
    return result;
}

BookInfo APIClient::parseBookResponse(const String& jsonResponse) {
    BookInfo result;
    
    StaticJsonDocument<512> doc;
    DeserializationError error = deserializeJson(doc, jsonResponse);
    
    if (error) {
        result.success = false;
        result.error = "JSON parse error";
        return result;
    }
    
    result.success = doc["success"] | false;
    
    if (result.success) {
        JsonObject book = doc["book"];
        result.id = book["id"].as<String>();
        result.title = book["title"].as<String>();
        result.code = book["code"].as<String>();
        result.author = book["author"].as<String>();
        result.available = book["available"] | false;
    } else {
        result.error = doc["error"].as<String>();
    }
    
    return result;
}
