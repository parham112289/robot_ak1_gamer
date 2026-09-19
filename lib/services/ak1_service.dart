import 'dart:convert';
import 'package:http/http.dart' as http;

class RobotStatus {
  final bool online;
  final double? batteryVoltage;
  final String? cameraUrl;
  const RobotStatus({required this.online, this.batteryVoltage, this.cameraUrl});
}

class AK1Service {
  static const String aiBaseUrl = 'https://robot-ak1-gamer.parhamsadr-s89.workers.dev';
  String robotBaseUrl;

  AK1Service({this.robotBaseUrl = 'http://ak1.local'}) {
    robotBaseUrl = _clean(robotBaseUrl);
  }

  static String _clean(String value) => value.trim().replaceFirst(RegExp(r'/$'), '');
  void setRobotBaseUrl(String value) => robotBaseUrl = _clean(value);

  Map<String, String> get _jsonHeaders => const {'Content-Type': 'application/json'};

  Future<String> askAI(String message, {String mode = 'AI'}) async {
    final r = await http.post(
      Uri.parse('$aiBaseUrl/v1/ai/command'),
      headers: _jsonHeaders,
      body: jsonEncode({'message': message, 'mode': mode}),
    ).timeout(const Duration(seconds: 30));
    final data = _decode(r);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception(data['error']?.toString() ?? 'AI HTTP ${r.statusCode}');
    }
    return (data['answer'] ?? data['reply'] ?? data['text'] ?? 'پاسخی دریافت نشد.').toString();
  }

  Future<RobotStatus> robotStatus() async {
    final r = await http.get(Uri.parse('$robotBaseUrl/api/status')).timeout(const Duration(seconds: 5));
    final data = _decode(r);
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('Robot status HTTP ${r.statusCode}');
    return RobotStatus(
      online: data['online'] == true,
      batteryVoltage: (data['battery_voltage'] as num?)?.toDouble(),
      cameraUrl: data['camera_url']?.toString(),
    );
  }

  Future<void> motor(String action) async {
    final r = await http.post(
      Uri.parse('$robotBaseUrl/api/motor'),
      headers: _jsonHeaders,
      body: jsonEncode({'action': action}),
    ).timeout(const Duration(seconds: 5));
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('Motor HTTP ${r.statusCode}');
  }

  Future<String> cameraSnapshotUrl() async {
    final r = await http.get(Uri.parse('$robotBaseUrl/api/camera')).timeout(const Duration(seconds: 5));
    final data = _decode(r);
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('Camera HTTP ${r.statusCode}');
    return (data['url'] ?? '$robotBaseUrl/capture').toString();
  }

  static Map<String, dynamic> _decode(http.Response r) {
    try {
      final v = jsonDecode(r.body);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
