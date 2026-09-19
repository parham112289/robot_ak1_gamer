#include <Arduino.h>

// AK-1 ESP32-CAM skeleton.
// Camera initialization and hardware pin mapping should be completed
// after confirming the exact AI-Thinker board revision and peripherals.

void setup() {
  Serial.begin(115200);
  Serial.println("AK-1 ESP32-CAM starting...");
}

void loop() {
  // Keep this firmware intentionally minimal until the exact pin map is confirmed.
  delay(1000);
}
