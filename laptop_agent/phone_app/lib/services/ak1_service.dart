import 'dart:convert';
import 'package:http/http.dart' as http;

class RobotStatus {
  final bool online;
  final double batteryVoltage;
  final String? cameraUrl;

  const RobotStatus({
    required this.online,
    required this.batteryVoltage,
    this.cameraUrl,
  });
}

class AIReply {
  final String text;
  const AIReply(this.text);
}

class AK1Service {
  static const String baseUrl = 'https://robot-ak1-gamer.parhamsadr-s89.workers.dev';

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
      };

  Future<AIReply> command(String command, {String mode = 'general'}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/v1/ai/command'),
          headers: _jsonHeaders,
          body: jsonEncode({'command': command, 'mode': mode}),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AIReply((data['reply'] ?? data['text'] ?? 'پاسخی دریافت نشد.').toString());
  }

  Future<RobotStatus> status() async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/robot/status'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Status HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return RobotStatus(
      online: data['online'] == true,
      batteryVoltage: (data['battery_voltage'] as num?)?.toDouble() ?? 0,
      cameraUrl: data['camera_url']?.toString(),
    );
  }

  Future<void> robotCommand(String action) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/v1/robot/command'),
          headers: _jsonHeaders,
          body: jsonEncode({'action': action}),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Robot HTTP ${response.statusCode}');
    }
  }
}
