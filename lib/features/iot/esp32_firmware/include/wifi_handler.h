#ifndef WIFI_HANDLER_H
#define WIFI_HANDLER_H

#include <Arduino.h>
#include <WiFi.h>
#include "config.h"

class WiFiHandler {
public:
    WiFiHandler();
    
    // Kết nối WiFi
    bool connect();
    
    // Kiểm tra kết nối
    bool isConnected();
    
    // Reconnect nếu mất kết nối
    void checkConnection();
    
    // Lấy IP address
    String getIPAddress();
    
    // Lấy signal strength
    int getSignalStrength();

private:
    unsigned long lastCheckTime;
    const unsigned long checkInterval = 5000; // Check mỗi 5 giây
};

#endif // WIFI_HANDLER_H
