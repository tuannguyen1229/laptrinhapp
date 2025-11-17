/*
 * I2C Scanner for ESP32-S3-CAM
 * Tìm địa chỉ I2C của LCD
 */

#include <Wire.h>

#define SDA_PIN 4
#define SCL_PIN 5

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n\n=== I2C Scanner ===");
  Serial.println("Scanning I2C bus...");
  
  Wire.begin(SDA_PIN, SCL_PIN);
  
  byte error, address;
  int nDevices = 0;
  
  for(address = 1; address < 127; address++) {
    Wire.beginTransmission(address);
    error = Wire.endTransmission();
    
    if (error == 0) {
      Serial.print("I2C device found at address 0x");
      if (address < 16) {
        Serial.print("0");
      }
      Serial.print(address, HEX);
      Serial.println(" !");
      nDevices++;
    }
    else if (error == 4) {
      Serial.print("Unknown error at address 0x");
      if (address < 16) {
        Serial.print("0");
      }
      Serial.println(address, HEX);
    }
  }
  
  if (nDevices == 0) {
    Serial.println("No I2C devices found!");
    Serial.println("Check connections:");
    Serial.println("  SDA -> GPIO 4");
    Serial.println("  SCL -> GPIO 5");
    Serial.println("  VCC -> 5V");
    Serial.println("  GND -> GND");
  }
  else {
    Serial.println("Scan complete!");
    Serial.print("Found ");
    Serial.print(nDevices);
    Serial.println(" device(s)");
  }
}

void loop() {
  // Không làm gì
  delay(5000);
}
