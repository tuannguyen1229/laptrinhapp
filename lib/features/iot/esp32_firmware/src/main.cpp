#include <Arduino.h>
#include "config.h"
#include "wifi_handler.h"
#include "lcd_handler.h"
#include "rfid_handler.h"
#include "api_client.h"

// Global objects
WiFiHandler wifiHandler;
LCDHandler lcdHandler;
RFIDHandler rfidHandler;
APIClient apiClient;

// State management
unsigned long lastHeartbeat = 0;
unsigned long lastDisplayUpdate = 0;
bool isProcessing = false;

// Button state
int lastButtonState = HIGH;
unsigned long lastDebounceTime = 0;

void setup() {
    // Khởi tạo Serial
    Serial.begin(SERIAL_BAUD_RATE);
    delay(1000);
    
    DEBUG_PRINTLN("\n\n");
    DEBUG_PRINTLN("========================================");
    DEBUG_PRINTLN("  ESP32-S3-CAM IoT Station");
    DEBUG_PRINTLN("  Tram Quet The & Sach Tu dong");
    DEBUG_PRINTLN("========================================");
    DEBUG_PRINT("Device ID: ");
    DEBUG_PRINTLN(DEVICE_ID);
    DEBUG_PRINT("Location: ");
    DEBUG_PRINTLN(DEVICE_LOCATION);
    DEBUG_PRINTLN("========================================\n");
    
    // Khởi tạo button
    pinMode(SCAN_BUTTON_PIN, INPUT_PULLUP);
    
    // Khởi tạo LED (optional)
    #ifdef LED_PIN
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, LOW);
    #endif
    
    // Khởi tạo LCD
    DEBUG_PRINTLN("[INIT] Initializing LCD...");
    if (!lcdHandler.begin()) {
        DEBUG_PRINTLN("[ERROR] LCD initialization failed!");
    }
    lcdHandler.displayText("Khoi dong...", "Vui long doi");
    
    // Kết nối WiFi
    DEBUG_PRINTLN("[INIT] Connecting to WiFi...");
    lcdHandler.displayText("Ket noi WiFi...", WIFI_SSID);
    
    if (!wifiHandler.connect()) {
        DEBUG_PRINTLN("[ERROR] WiFi connection failed!");
        lcdHandler.displayError("Loi WiFi!");
        while (true) {
            delay(1000);
        }
    }
    
    lcdHandler.displayText("WiFi OK!", wifiHandler.getIPAddress().c_str());
    delay(2000);
    
    // Khởi tạo RFID
    DEBUG_PRINTLN("[INIT] Initializing RFID reader...");
    lcdHandler.displayText("Khoi tao RFID...", "");
    
    if (!rfidHandler.begin()) {
        DEBUG_PRINTLN("[ERROR] RFID initialization failed!");
        lcdHandler.displayError("Loi RFID!");
        while (true) {
            delay(1000);
        }
    }
    
    lcdHandler.displayText("RFID OK!", "");
    delay(1000);
    
    // Gửi heartbeat đầu tiên
    DEBUG_PRINTLN("[INIT] Sending initial heartbeat...");
    apiClient.sendHeartbeat();
    lastHeartbeat = millis();
    
    // Sẵn sàng
    DEBUG_PRINTLN("\n[SYSTEM] System ready!");
    DEBUG_PRINTLN("========================================\n");
    lcdHandler.displayReady();
    
    #ifdef LED_PIN
    // Blink LED 3 lần để báo sẵn sàng
    for (int i = 0; i < 3; i++) {
        digitalWrite(LED_PIN, HIGH);
        delay(200);
        digitalWrite(LED_PIN, LOW);
        delay(200);
    }
    #endif
}

void loop() {
    // Kiểm tra kết nối WiFi
    wifiHandler.checkConnection();
    
    // Gửi heartbeat định kỳ
    if (millis() - lastHeartbeat > HEARTBEAT_INTERVAL) {
        DEBUG_PRINTLN("[HEARTBEAT] Sending...");
        if (apiClient.sendHeartbeat()) {
            DEBUG_PRINTLN("[HEARTBEAT] OK");
        } else {
            DEBUG_PRINTLN("[HEARTBEAT] Failed");
        }
        lastHeartbeat = millis();
    }
    
    // Reset display sau timeout
    if (isProcessing && (millis() - lastDisplayUpdate > LCD_DISPLAY_TIMEOUT)) {
        isProcessing = false;
        lcdHandler.displayReady();
        DEBUG_PRINTLN("[SYSTEM] Ready for next scan");
    }
    
    // Kiểm tra nút quét barcode (sẽ implement sau khi có camera)
    int buttonState = digitalRead(SCAN_BUTTON_PIN);
    if (buttonState != lastButtonState) {
        lastDebounceTime = millis();
    }
    
    if ((millis() - lastDebounceTime) > BUTTON_DEBOUNCE_MS) {
        if (buttonState == LOW && lastButtonState == HIGH && !isProcessing) {
            DEBUG_PRINTLN("[BUTTON] Scan button pressed");
            lcdHandler.displayText("Quet barcode", "Chua ho tro");
            delay(2000);
            lcdHandler.displayReady();
            // TODO: Implement camera barcode scan
        }
    }
    lastButtonState = buttonState;
    
    // Kiểm tra thẻ RFID
    if (!isProcessing && rfidHandler.hasNewCard()) {
        isProcessing = true;
        
        // Đọc UID thẻ
        String cardUID = rfidHandler.readCardUID();
        DEBUG_PRINT("[RFID] Card detected: ");
        DEBUG_PRINTLN(cardUID);
        
        // Hiển thị đang xử lý
        lcdHandler.displayProcessing();
        
        #ifdef LED_PIN
        digitalWrite(LED_PIN, HIGH);
        #endif
        
        // Gửi request lên API
        StudentInfo student = apiClient.scanStudentCard(cardUID);
        
        if (student.success) {
            // Thành công
            DEBUG_PRINTLN("[API] Student found:");
            DEBUG_PRINT("  Name: ");
            DEBUG_PRINTLN(student.name);
            DEBUG_PRINT("  MSSV: ");
            DEBUG_PRINTLN(student.mssv);
            DEBUG_PRINT("  Class: ");
            DEBUG_PRINTLN(student.className);
            
            // Hiển thị thông tin sinh viên
            lcdHandler.displayStudent(student.name.c_str(), student.mssv.c_str());
            
            // Beep success (nếu có buzzer)
            #ifdef BUZZER_PIN
            tone(BUZZER_PIN, 1000, 200);
            #endif
        } else {
            // Thất bại
            DEBUG_PRINT("[API] Error: ");
            DEBUG_PRINTLN(student.error);
            
            lcdHandler.displayError("Khong tim thay");
            
            // Beep error (nếu có buzzer)
            #ifdef BUZZER_PIN
            for (int i = 0; i < 3; i++) {
                tone(BUZZER_PIN, 500, 100);
                delay(150);
            }
            #endif
        }
        
        #ifdef LED_PIN
        digitalWrite(LED_PIN, LOW);
        #endif
        
        // Halt card
        rfidHandler.haltCard();
        
        lastDisplayUpdate = millis();
    }
    
    // Small delay
    delay(100);
}
