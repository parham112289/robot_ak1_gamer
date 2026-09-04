#include <WiFi.h>
#include <WebServer.h>
#include <Preferences.h>
#include <BluetoothSerial.h>
#include "esp_camera.h"

// AI-Thinker ESP32-CAM
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

WebServer server(80);
Preferences prefs;
BluetoothSerial SerialBT;

String savedSsid;
String savedPassword;
String btName = "AK-1";
bool btEnabled = false;
bool cameraOk = false;

void startSetupAP() {
  WiFi.mode(WIFI_AP_STA);
  WiFi.softAP("AK-1", "12345678");
  Serial.print("Setup AP: ");
  Serial.println(WiFi.softAPIP());
}

bool connectSavedWiFi() {
  if (savedSsid.isEmpty()) return false;
  WiFi.mode(WIFI_AP_STA);
  WiFi.begin(savedSsid.c_str(), savedPassword.c_str());
  Serial.print("Connecting to saved Wi-Fi");
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 12000) {
    delay(300);
    Serial.print('.');
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("Robot Wi-Fi IP: ");
    Serial.println(WiFi.localIP());
    return true;
  }
  Serial.println("Wi-Fi connection failed; setup AP remains available.");
  return false;
}

void initCamera() {
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sccb_sda = SIOD_GPIO_NUM;
  config.pin_sccb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  config.frame_size = FRAMESIZE_QVGA;
  config.jpeg_quality = 12;
  config.fb_count = 1;
  cameraOk = (esp_camera_init(&config) == ESP_OK);
}

void startBluetooth() {
  if (!btEnabled) return;
  if (SerialBT.hasClient()) return;
  SerialBT.begin(btName.c_str());
  Serial.print("Bluetooth ON: ");
  Serial.println(btName);
}

void stopBluetooth() {
  if (btEnabled) {
    SerialBT.end();
  }
  btEnabled = false;
}

void handleRoot() {
  String html = "<html><meta charset='utf-8'><body><h2>AK-1</h2>";
  html += "<p>Wi-Fi: " + String(WiFi.status() == WL_CONNECTED ? "connected" : "setup AP") + "</p>";
  html += "<p>IP: " + WiFi.localIP().toString() + "</p>";
  html += "<p>Bluetooth: " + String(btEnabled ? "on" : "off") + "</p>";
  html += "<p>Camera: " + String(cameraOk ? "ok" : "error") + "</p></body></html>";
  server.send(200, "text/html; charset=utf-8", html);
}

void handleStatus() {
  String ip = WiFi.status() == WL_CONNECTED ? WiFi.localIP().toString() : WiFi.softAPIP().toString();
  String json = "{\"battery\":null,\"wifi\":" + String(WiFi.status() == WL_CONNECTED ? "true" : "false") +
                ",\"wifi_ssid\":\"" + savedSsid + "\",\"ip\":\"" + ip +
                "\",\"bluetooth\":" + String(btEnabled ? "true" : "false") +
                ",\"bluetooth_name\":\"" + btName + "\",\"camera\":" + String(cameraOk ? "true" : "false") + "}";
  server.send(200, "application/json", json);
}

void handleCapture() {
  if (!cameraOk) { server.send(503, "text/plain", "Camera not ready"); return; }
  camera_fb_t *fb = esp_camera_fb_get();
  if (!fb) { server.send(503, "text/plain", "Capture failed"); return; }
  server.sendHeader("Content-Disposition", "inline; filename=ak1.jpg");
  server.send_P(200, "image/jpeg", (const char*)fb->buf, fb->len);
  esp_camera_fb_return(fb);
}

void handleWifiConfig() {
  if (!server.hasArg("plain")) { server.send(400, "application/json", "{\"ok\":false,\"error\":\"missing body\"}"); return; }
  String body = server.arg("plain");
  int s1 = body.indexOf("\"ssid\"");
  int p1 = body.indexOf("\"password\"");
  if (s1 < 0 || p1 < 0) { server.send(400, "application/json", "{\"ok\":false,\"error\":\"ssid/password required\"}"); return; }
  int ss = body.indexOf(':', s1); int ps = body.indexOf(':', p1);
  int sq1 = body.indexOf('"', ss + 1); int sq2 = body.indexOf('"', sq1 + 1);
  int pq1 = body.indexOf('"', ps + 1); int pq2 = body.indexOf('"', pq1 + 1);
  if (sq1 < 0 || sq2 < 0 || pq1 < 0 || pq2 < 0) { server.send(400, "application/json", "{\"ok\":false}"); return; }
  savedSsid = body.substring(sq1 + 1, sq2);
  savedPassword = body.substring(pq1 + 1, pq2);
  prefs.putString("ssid", savedSsid);
  prefs.putString("pass", savedPassword);

  WiFi.disconnect();
  WiFi.begin(savedSsid.c_str(), savedPassword.c_str());
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 12000) delay(250);
  String ip = WiFi.status() == WL_CONNECTED ? WiFi.localIP().toString() : "";
  String json = "{\"ok\":true,\"connected\":" + String(WiFi.status() == WL_CONNECTED ? "true" : "false") + ",\"ip\":\"" + ip + "\"}";
  server.send(200, "application/json", json);
}

void handleBluetoothConfig() {
  if (!server.hasArg("plain")) { server.send(400, "application/json", "{\"ok\":false}"); return; }
  String body = server.arg("plain");
  bool enable = body.indexOf("\"enabled\":true") >= 0;
  int n = body.indexOf("\"name\"");
  if (n >= 0) {
    int c = body.indexOf(':', n);
    int q1 = body.indexOf('"', c + 1); int q2 = body.indexOf('"', q1 + 1);
    if (q1 >= 0 && q2 > q1) btName = body.substring(q1 + 1, q2);
  }
  prefs.putBool("bt", enable);
  prefs.putString("btname", btName);
  if (enable) {
    if (btEnabled) SerialBT.end();
    btEnabled = true;
    SerialBT.begin(btName.c_str());
  } else {
    stopBluetooth();
  }
  server.send(200, "application/json", "{\"ok\":true,\"enabled\":" + String(btEnabled ? "true" : "false") + ",\"name\":\"" + btName + "\"}");
}

void setup() {
  Serial.begin(115200);
  delay(800);
  prefs.begin("ak1", false);
  savedSsid = prefs.getString("ssid", "");
  savedPassword = prefs.getString("pass", "");
  btEnabled = prefs.getBool("bt", false);
  btName = prefs.getString("btname", "AK-1");

  startSetupAP();
  initCamera();
  connectSavedWiFi();
  if (btEnabled) startBluetooth();

  server.on("/", handleRoot);
  server.on("/status", HTTP_GET, handleStatus);
  server.on("/capture", HTTP_GET, handleCapture);
  server.on("/wifi/config", HTTP_POST, handleWifiConfig);
  server.on("/bluetooth/config", HTTP_POST, handleBluetoothConfig);
  server.begin();
  Serial.println("AK-1 server started");
}

void loop() {
  server.handleClient();
  delay(2);
}
