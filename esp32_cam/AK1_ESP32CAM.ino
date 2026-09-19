/*
  AK-1 ESP32-CAM starter firmware.
  IMPORTANT: verify the exact AI-Thinker pin availability and your L298N wiring
  before connecting the motor. Do not use this sketch as a blind wiring map.
*/
#include <WiFi.h>
#include <WebServer.h>

const char* WIFI_SSID = "YOUR_WIFI";
const char* WIFI_PASSWORD = "YOUR_PASSWORD";

WebServer server(80);

// Example motor pins only; verify against your final board wiring.
const int MOTOR_IN1 = 12;
const int MOTOR_IN2 = 13;
const int MOTOR_ENA = 2;

void stopMotor() {
  digitalWrite(MOTOR_IN1, LOW);
  digitalWrite(MOTOR_IN2, LOW);
}
void leftMotor() {
  digitalWrite(MOTOR_IN1, HIGH);
  digitalWrite(MOTOR_IN2, LOW);
}
void rightMotor() {
  digitalWrite(MOTOR_IN1, LOW);
  digitalWrite(MOTOR_IN2, HIGH);
}

void statusEndpoint() {
  String camera = String("http://") + WiFi.localIP().toString() + "/capture";
  String body = String("{\"online\":true,\"battery_voltage\":null,\"camera_url\":\"") + camera + "\"}";
  server.send(200, "application/json", body);
}

void motorEndpoint() {
  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"error\":\"missing body\"}");
    return;
  }
  String body = server.arg("plain");
  if (body.indexOf("LEFT") >= 0) leftMotor();
  else if (body.indexOf("RIGHT") >= 0) rightMotor();
  else stopMotor();
  server.send(200, "application/json", "{\"ok\":true}");
}

void cameraEndpoint() {
  String camera = String("http://") + WiFi.localIP().toString() + "/capture";
  server.send(200, "application/json", String("{\"url\":\"") + camera + "\"}");
}

void setup() {
  Serial.begin(115200);
  pinMode(MOTOR_IN1, OUTPUT);
  pinMode(MOTOR_IN2, OUTPUT);
  pinMode(MOTOR_ENA, OUTPUT);
  digitalWrite(MOTOR_ENA, HIGH);
  stopMotor();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) delay(300);

  server.on("/api/status", HTTP_GET, statusEndpoint);
  server.on("/api/camera", HTTP_GET, cameraEndpoint);
  server.on("/api/motor", HTTP_POST, motorEndpoint);
  server.begin();
}

void loop() {
  server.handleClient();
}
