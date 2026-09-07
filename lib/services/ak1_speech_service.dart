import 'package:flutter_tts/flutter_tts.dart';

class Ak1SpeechService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('fa-IR');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text.trim());
  }

  Future<void> stop() => _tts.stop();
  Future<void> dispose() => _tts.stop();
}
