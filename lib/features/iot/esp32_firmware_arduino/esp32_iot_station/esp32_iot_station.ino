/*
 * ESP32-S3-CAM IoT Station - Arduino Version
 * Trạm Quét Thẻ & Sách Tự động
 * 
 * Hardware:
 * - ESP32-S3-CAM (with USB-C built-in)
 * - RC522 RFID Reader
 * - LCD 16x2 I2C
 * - Power Bank
 * 
 * Author: Kiro AI Assistant
 * Date: 2024
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <MFRC522.h>
#include <SPI.h>
#include <LiquidCrystal_I2C.h>

// ============================================
// CONFIGURATION - CHỈNH SỬA PHẦN NÀY
// ============================================

// WiFi credentials
const char* WIFI_SSID = "VDK IOT";        // ← Sửa đây
const char* WIFI_PASSWORD = "20242025x"; // ← Sửa đây

// API endpoint
const char* API_BASE_URL = "http://172.20.10.5:3000"; // ← Sửa đây
const char* API_SCAN_STUDENT = "/api/iot/scan-student-card";
const char* API_SCAN_BOOK = "/api/iot/scan-book-barcode";
const char* API_HEARTBEAT = "/api/iot/heartbeat";

// Device info
const char* DEVICE_ID = "IOT_STATION_01";
const char* DEVICE_NAME = "Tram Quet Chinh";
const char* DEVICE_LOCATION = "Quay Thu Vien Tang 1";

// Pin configuration for ESP32-S3-CAM
#define RFID_CS_PIN 10
#define RFID_RST_PIN 9
#define RFID_SCK_PIN 12
#define RFID_MOSI_PIN 11
#define RFID_MISO_PIN 13

#define LCD_ADDRESS 0x27  // Hoặc 0x3F - thử cả 2
#define LCD_COLS 16
#define LCD_ROWS 2
#define LCD_SDA_PIN 4     // I2C SDA for ESP32-S3
#define LCD_SCL_PIN 5     // I2C SCL for ESP32-S3

#define SCAN_BUTTON_PIN 0  // Boot button

// Timing
#define RFID_SCAN_INTERVAL 500
#define LCD_DISPLAY_TIMEOUT 5000
#define HEARTBEAT_INTERVAL 60000
#define WIFI_TIMEOUT 20000

// ============================================
// GLOBAL OBJECTS
// ============================================

MFRC522 rfid(RFID_CS_PIN, RFID_RST_PIN);
LiquidCrystal_I2C lcd(LCD_ADDRESS, LCD_COLS, LCD_ROWS);
HTTPClient http;

// State variables
unsigned long lastHeartbeat = 0;
unsigned long lastDisplayUpdate = 0;
unsigned long lastRFIDCheck = 0;
bool isProcessing = false;
String lastUID = "";

// ============================================
// SETUP
// ============================================

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n\n========================================");
  Serial.println("  ESP32-S3-CAM IoT Station");
  Serial.println("  Tram Quet The & Sach Tu dong");
  Serial.println("========================================");
  Serial.print("Device ID: ");
  Serial.println(DEVICE_ID);
  Serial.print("Location: ");
  Serial.println(DEVICE_LOCATION);
  Serial.println("========================================\n");
  
  // Initialize button
  pinMode(SCAN_BUTTON_PIN, INPUT_PULLUP);
  
  // Initialize LCD with custom I2C pins for ESP32-S3
  Serial.println("[INIT] Initializing LCD...");
  Wire.begin(LCD_SDA_PIN, LCD_SCL_PIN);  // Initialize I2C with custom pins
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Khoi dong...");
  lcd.setCursor(0, 1);
  lcd.print("Vui long doi");
  
  // Connect WiFi
  Serial.println("[INIT] Connecting to WiFi...");
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Ket noi WiFi...");
  lcd.setCursor(0, 1);
  lcd.print(WIFI_SSID);
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  unsigned long startTime = millis();
  while (WiFi.status() != WL_CONNECTED) {
    if (millis() - startTime > WIFI_TIMEOUT) {
      Serial.println("[ERROR] WiFi connection timeout!");
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("LOI WiFi!");
      while(true) delay(1000);
    }
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\nWiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("WiFi OK!");
  lcd.setCursor(0, 1);
  lcd.print(WiFi.localIP());
  delay(2000);
  
  // Initialize SPI
  SPI.begin(RFID_SCK_PIN, RFID_MISO_PIN, RFID_MOSI_PIN, RFID_CS_PIN);
  
  // Initialize RFID
  Serial.println("[INIT] Initializing RFID reader...");
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Khoi tao RFID...");
  
  rfid.PCD_Init();
  
  byte version = rfid.PCD_ReadRegister(rfid.VersionReg);
  if (version == 0x00 || version == 0xFF) {
    Serial.println("[ERROR] RFID reader not found!");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("LOI RFID!");
    while(true) delay(1000);
  }
  
  Serial.print("RFID reader initialized. Version: 0x");
  Serial.println(version, HEX);
  
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("RFID OK!");
  delay(1000);
  
  // Send initial heartbeat
  Serial.println("[INIT] Sending initial heartbeat...");
  sendHeartbeat();
  lastHeartbeat = millis();
  
  // Ready
  Serial.println("\n[SYSTEM] System ready!");
  Serial.println("========================================\n");
  displayReady();
}

// ============================================
// MAIN LOOP
// ============================================

void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected! Reconnecting...");
    WiFi.reconnect();
    delay(5000);
    return;
  }
  
  // Send heartbeat
  if (millis() - lastHeartbeat > HEARTBEAT_INTERVAL) {
    Serial.println("[HEARTBEAT] Sending...");
    if (sendHeartbeat()) {
      Serial.println("[HEARTBEAT] OK");
    } else {
      Serial.println("[HEARTBEAT] Failed");
    }
    lastHeartbeat = millis();
  }
  
  // Reset display after timeout
  if (isProcessing && (millis() - lastDisplayUpdate > LCD_DISPLAY_TIMEOUT)) {
    isProcessing = false;
    displayReady();
    Serial.println("[SYSTEM] Ready for next scan");
  }
  
  // Check RFID card
  if (!isProcessing && (millis() - lastRFIDCheck > RFID_SCAN_INTERVAL)) {
    lastRFIDCheck = millis();
    
    if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
      String cardUID = getCardUID();
      
      // Debounce: skip if same card
      if (cardUID == lastUID) {
        rfid.PICC_HaltA();
        rfid.PCD_StopCrypto1();
        return;
      }
      
      lastUID = cardUID;
      isProcessing = true;
      
      Serial.print("[RFID] Card detected: ");
      Serial.println(cardUID);
      
      // Display processing
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Dang xu ly...");
      
      // Send to API
      scanStudentCard(cardUID);
      
      // Halt card
      rfid.PICC_HaltA();
      rfid.PCD_StopCrypto1();
      
      lastDisplayUpdate = millis();
    }
  }
  
  delay(100);
}

// ============================================
// RFID FUNCTIONS
// ============================================

String getCardUID() {
  String uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    if (rfid.uid.uidByte[i] < 0x10) {
      uid += "0";
    }
    uid += String(rfid.uid.uidByte[i], HEX);
  }
  uid.toUpperCase();
  return uid;
}

// ============================================
// API FUNCTIONS
// ============================================

void scanStudentCard(String cardUID) {
  String url = String(API_BASE_URL) + String(API_SCAN_STUDENT);
  
  Serial.print("[API] POST ");
  Serial.println(url);
  
  // Create JSON payload
  StaticJsonDocument<200> doc;
  doc["card_uid"] = cardUID;
  doc["device_id"] = DEVICE_ID;
  doc["timestamp"] = millis();
  
  String payload;
  serializeJson(doc, payload);
  
  Serial.print("[API] Payload: ");
  Serial.println(payload);
  
  // Send request
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.setTimeout(10000);
  
  int httpCode = http.POST(payload);
  
  if (httpCode > 0) {
    Serial.print("[API] Response code: ");
    Serial.println(httpCode);
    
    if (httpCode == HTTP_CODE_OK) {
      String response = http.getString();
      Serial.print("[API] Response: ");
      Serial.println(response);
      
      // Parse response
      StaticJsonDocument<512> responseDoc;
      DeserializationError error = deserializeJson(responseDoc, response);
      
      if (!error) {
        bool success = responseDoc["success"];
        
        if (success) {
          // Success - display student info
          String name = responseDoc["student"]["name"].as<String>();
          String mssv = responseDoc["student"]["mssv"].as<String>();
          
          Serial.println("[API] Student found:");
          Serial.print("  Name: ");
          Serial.println(name);
          Serial.print("  MSSV: ");
          Serial.println(mssv);
          
          displayStudent(name, mssv);
        } else {
          // Error
          String error = responseDoc["error"].as<String>();
          Serial.print("[API] Error: ");
          Serial.println(error);
          
          displayError("Khong tim thay");
        }
      }
    }
  } else {
    Serial.print("[API] Error: ");
    Serial.println(http.errorToString(httpCode));
    displayError("Loi ket noi");
  }
  
  http.end();
}

bool sendHeartbeat() {
  String url = String(API_BASE_URL) + String(API_HEARTBEAT);
  
  StaticJsonDocument<200> doc;
  doc["device_id"] = DEVICE_ID;
  doc["device_name"] = DEVICE_NAME;
  doc["location"] = DEVICE_LOCATION;
  doc["timestamp"] = millis();
  
  String payload;
  serializeJson(doc, payload);
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.setTimeout(5000);
  
  int httpCode = http.POST(payload);
  bool success = (httpCode == HTTP_CODE_OK);
  
  http.end();
  return success;
}

// ============================================
// LCD DISPLAY FUNCTIONS
// ============================================

void displayReady() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("San sang!");
  lcd.setCursor(0, 1);
  lcd.print("Quet the/sach");
}

void displayStudent(String name, String mssv) {
  lcd.clear();
  
  // Remove Vietnamese tones (simple version)
  name.replace("Đ", "D");
  name.replace("đ", "d");
  
  // Truncate if too long
  if (name.length() > LCD_COLS) {
    name = name.substring(0, LCD_COLS);
  }
  
  lcd.setCursor(0, 0);
  lcd.print(name);
  
  lcd.setCursor(0, 1);
  lcd.print("MSSV:");
  lcd.print(mssv);
  
  Serial.println("[LCD] Displaying student info");
}

void displayError(String error) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("LOI!");
  lcd.setCursor(0, 1);
  lcd.print(error);
  
  Serial.print("[LCD] Error: ");
  Serial.println(error);
}
