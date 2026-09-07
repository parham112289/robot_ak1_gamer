import 'dart:convert';
import 'dart:io';

class Ak1BackendService {
  final String baseUrl;
  const Ak1BackendService(this.baseUrl);

  Uri _uri(String path) {
    var value = baseUrl.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) value = 'https://$value';
    return Uri.parse('$value$path');
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, {Duration timeout = const Duration(seconds: 25)}) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(_uri(path)).timeout(timeout);
      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      request.write(jsonEncode(body));
      final response = await request.close().timeout(timeout);
      final text = await utf8.decoder.bind(response).join();
      final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(decoded is Map && decoded['error'] != null ? decoded['error'].toString() : 'HTTP ${response.statusCode}');
      }
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> status() async {
    final client = HttpClient();
    try {
      final response = await client.getUrl(_uri('/v1/status')).timeout(const Duration(seconds: 8)).then((r) => r.close());
      final text = await utf8.decoder.bind(response).join();
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      return jsonDecode(text) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }

  Future<String> ask(String prompt) async {
    final data = await _post('/v1/ai/command', {'prompt': prompt});
    return data['text']?.toString().trim() ?? '';
  }

  Future<String> analyzeImage({required String imageBase64, String prompt = 'این تصویر را به فارسی تحلیل کن و مهم‌ترین چیزهایی که می‌بینی را کوتاه و واضح بگو.'}) async {
    final data = await _post('/v1/ai/vision', {'prompt': prompt, 'image_base64': imageBase64}, timeout: const Duration(seconds: 40));
    return data['text']?.toString().trim() ?? '';
  }

  Future<void> sendRobotSpeech({required String robotUrl, required String text}) async {
    var base = robotUrl.trim();
    if (!base.startsWith('http://') && !base.startsWith('https://')) base = 'http://$base';
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$base/audio/speak')).timeout(const Duration(seconds: 8));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'text': text}));
      final response = await request.close().timeout(const Duration(seconds: 8));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('اسپیکر ربات هنوز به /audio/speak وصل نیست.');
      }
      if (body.isNotEmpty) {
        try {
          final data = jsonDecode(body);
          if (data is Map && data['ok'] == false) throw Exception(data['error']?.toString() ?? 'خطای اسپیکر ربات');
        } catch (e) {
          if (e is Exception) rethrow;
        }
      }
    } finally {
      client.close(force: true);
    }
  }
}
