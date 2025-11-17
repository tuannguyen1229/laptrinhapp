#include "wifi_handler.h"

WiFiHandler::WiFiHandler() : lastCheckTime(0) {}

bool WiFiHandler::connect() {
    DEBUG_PRINTLN("\n=== Connecting to WiFi ===");
    DEBUG_PRINT("SSID: ");
    DEBUG_PRINTLN(WIFI_SSID);
    
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    
    unsigned long startTime = millis();
    while (WiFi.status() != WL_CONNECTED) {
        if (millis() - startTime > WIFI_TIMEOUT) {
            DEBUG_PRINTLN("WiFi connection timeout!");
            return false;
        }
        delay(500);
        DEBUG_PRINT(".");
    }
    
    DEBUG_PRINTLN("\nWiFi connected!");
    DEBUG_PRINT("IP Address: ");
    DEBUG_PRINTLN(WiFi.localIP());
    DEBUG_PRINT("Signal Strength: ");
    DEBUG_PRINT(WiFi.RSSI());
    DEBUG_PRINTLN(" dBm");
    
    return true;
}

bool WiFiHandler::isConnected() {
    return WiFi.status() == WL_CONNECTED;
}

void WiFiHandler::checkConnection() {
    unsigned long currentTime = millis();
    
    // Chỉ check sau mỗi checkInterval
    if (currentTime - lastCheckTime < checkInterval) {
        return;
    }
    
    lastCheckTime = currentTime;
    
    if (!isConnected()) {
        DEBUG_PRINTLN("WiFi disconnected! Reconnecting...");
        connect();
    }
}

String WiFiHandler::getIPAddress() {
    return WiFi.localIP().toString();
}

int WiFiHandler::getSignalStrength() {
    return WiFi.RSSI();
}
