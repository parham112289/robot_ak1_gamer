#include <WiFi.h>
#include <WebServer.h>

const char* WIFI_SSID = "YOUR_WIFI";
const char* WIFI_PASSWORD = "YOUR_PASSWORD";

WebServer server(80);

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

void statusRoute() {
  server.send(
    200,
    "application/json",
    "{\"online\":true,\"battery_voltage\":null}"
  );
}

void motorRoute() {
  String action = server.arg("action");
  action.toUpperCase();

  if (action == "LEFT") {
    leftMotor();
  } else if (action == "RIGHT") {
    rightMotor();
  } else {
    stopMotor();
  }

  server.send(200, "application/json", "{\"ok\":true}");
}

void setup() {
  Serial.begin(115200);

  pinMode(MOTOR_IN1, OUTPUT);
  pinMode(MOTOR_IN2, OUTPUT);
  pinMode(MOTOR_ENA, OUTPUT);

  digitalWrite(MOTOR_ENA, HIGH);
  stopMotor();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  server.on("/api/status", HTTP_GET, statusRoute);
  server.on("/api/motor", HTTP_POST, motorRoute);
  server.begin();
}

void loop() {
  server.handleClient();
}
