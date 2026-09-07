import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Ak1BackendService {
  final String baseUrl;
  Ak1BackendService(String url) : baseUrl = _normalizeBaseUrl(url);

  static String _normalizeBaseUrl(String url) {
    var value = url.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    value = value.replaceFirst(RegExp(r'/+$'), '');
    const endpointSuffixes = ['/v1/status', '/v1/ai/command', '/v1/ai/vision'];
    for (final suffix in endpointSuffixes) {
      if (value.endsWith(suffix)) {
        value = value.substring(0, value.length - suffix.length);
        break;
      }
    }
    return value;
  }

  Uri _uri(String path) {
    var value = baseUrl.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    value = value.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$value$path');
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 90),
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= 3; attempt++) {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15)
        ..idleTimeout = const Duration(seconds: 30)
        ..userAgent = 'AK-1-Flutter/1.0';

      try {
        final request = await client.postUrl(_uri(path)).timeout(
          const Duration(seconds: 20),
        );
        request.headers.contentType = ContentType.json;
        request.headers.set('Accept', 'application/json');
        request.headers.set('Cache-Control', 'no-cache');
        request.write(jsonEncode(body));

        final response = await request.close().timeout(timeout);
        final text = await utf8.decoder.bind(response).join().timeout(timeout);
        final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);

        if (response.statusCode < 200 || response.statusCode >= 300) {
          final message = decoded is Map && decoded['error'] != null
              ? decoded['error'].toString()
              : 'HTTP ${response.statusCode}';
          throw HttpException(message, uri: _uri(path));
        }

        return decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{'data': decoded};
      } on TimeoutException catch (e) {
        lastError = Exception('زمان پاسخ Backend تمام شد. (تلاش $attempt از 3)');
        if (attempt == 3) throw lastError!;
      } on HandshakeException catch (e) {
        lastError = Exception('اتصال امن HTTPS به Backend برقرار نشد. (تلاش $attempt از 3)');
        if (attempt == 3) throw lastError!;
      } on SocketException catch (e) {
        lastError = Exception('اتصال اینترنت/Backend قطع شد: ${e.message}');
        if (attempt == 3) throw lastError!;
      } finally {
        client.close(force: true);
      }

      await Future<void>.delayed(Duration(milliseconds: 700 * attempt));
    }

    throw lastError ?? Exception('خطای ناشناخته در اتصال به Backend');
  }

  Future<Map<String, dynamic>> status() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..idleTimeout = const Duration(seconds: 15)
      ..userAgent = 'AK-1-Flutter/1.0';
    try {
      final request = await client.getUrl(_uri('/v1/status')).timeout(
        const Duration(seconds: 12),
      );
      request.headers.set('Accept', 'application/json');
      final response = await request.close().timeout(const Duration(seconds: 12));
      final text = await utf8.decoder.bind(response).join();
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}', uri: _uri('/v1/status'));
      }
      return jsonDecode(text) as Map<String, dynamic>;
    } on HandshakeException {
      throw Exception('HTTPS به Backend برقرار نشد.');
    } on SocketException catch (e) {
      throw Exception('اتصال اینترنت برقرار نیست: ${e.message}');
    } finally {
      client.close(force: true);
    }
  }

  Future<String> ask(String prompt) async {
    final data = await _post('/v1/ai/command', {'prompt': prompt});
    return data['text']?.toString().trim() ?? '';
  }

  Future<String> analyzeImage({
    required String imageBase64,
    String prompt = 'این تصویر را به فارسی تحلیل کن و مهم‌ترین چیزهایی که می‌بینی را کوتاه و واضح بگو.',
  }) async {
    final data = await _post(
      '/v1/ai/vision',
      {'prompt': prompt, 'image_base64': imageBase64},
      timeout: const Duration(seconds: 90),
    );
    return data['text']?.toString().trim() ?? '';
  }

  Future<void> sendRobotSpeech({required String robotUrl, required String text}) async {
    var base = robotUrl.trim();
    if (!base.startsWith('http://') && !base.startsWith('https://')) base = 'http://$base';
    base = base.replaceFirst(RegExp(r'/+$'), '');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..idleTimeout = const Duration(seconds: 10);
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
        final data = jsonDecode(body);
        if (data is Map && data['ok'] == false) {
          throw Exception(data['error']?.toString() ?? 'خطای اسپیکر ربات');
        }
      }
    } finally {
      client.close(force: true);
    }
  }
}
