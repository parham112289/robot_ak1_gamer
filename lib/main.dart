import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/ak1_service.dart';

void main() => runApp(const AK1App());

class AK1App extends StatelessWidget {
  const AK1App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AK-1',
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true, colorSchemeSeed: Colors.cyan),
        home: const AK1Home(),
      );
}

class AK1Home extends StatefulWidget {
  const AK1Home({super.key});
  @override
  State<AK1Home> createState() => _AK1HomeState();
}

class _AK1HomeState extends State<AK1Home> {
  final _service = AK1Service();
  final _text = TextEditingController();
  final _speech = stt.SpeechToText();
  Timer? _timer;
  bool _busy = false;
  bool _listening = false;
  bool _online = false;
  double? _voltage;
  String? _cameraUrl;
  String _reply = 'سلام! من AK-1 هستم.';
  String _mode = 'AI';
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadRobotUrl();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _refreshRobot());
  }

  Future<void> _loadRobotUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('robot_url');
    if (url != null && url.isNotEmpty) _service.setRobotBaseUrl(url);
    await _refreshRobot();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<void> _refreshRobot() async {
    try {
      final s = await _service.robotStatus();
      if (!mounted) return;
      setState(() {
        _online = s.online;
        _voltage = s.batteryVoltage;
        _cameraUrl = s.cameraUrl ?? _cameraUrl;
      });
    } catch (_) {
      if (mounted) setState(() => _online = false);
    }
  }

  Future<void> _ask(String value, {String? mode}) async {
    final message = value.trim();
    if (message.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final answer = await _service.askAI(message, mode: mode ?? _mode);
      if (mounted) setState(() => _reply = answer);
    } catch (e) {
      if (mounted) setState(() => _reply = 'خطا در AI: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _voice() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ok = await _speech.initialize(
      onStatus: (s) {
        if (mounted && (s == 'done' || s == 'notListening')) setState(() => _listening = false);
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!ok) {
      if (mounted) _snack('تشخیص صدای گوشی در دسترس نیست.');
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      localeId: 'fa_IR',
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _ask(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _motor(String action) async {
    try {
      await _service.motor(action);
      if (mounted) _snack('فرمان $action ارسال شد.');
    } catch (_) {
      if (mounted) _snack('ربات متصل نیست یا آدرس ESP32 درست نیست.');
    }
  }

  Future<void> _settings() async {
    final controller = TextEditingController(text: _service.robotBaseUrl);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('آدرس ESP32-CAM'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'http://192.168.1.50'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('ذخیره')),
        ],
      ),
    );
    if (value == null || value.trim().isEmpty) return;
    _service.setRobotBaseUrl(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('robot_url', _service.robotBaseUrl);
    await _refreshRobot();
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final pages = [_aiPage(), _controlPage(), _cameraPage()];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AK-1 🤖'),
          actions: [
            Icon(_online ? Icons.wifi : Icons.wifi_off, color: _online ? Colors.greenAccent : Colors.redAccent),
            IconButton(onPressed: _settings, icon: const Icon(Icons.settings)),
          ],
        ),
        body: pages[_page],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _page,
          onDestinationSelected: (i) => setState(() => _page = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.psychology), label: 'AI'),
            NavigationDestination(icon: Icon(Icons.gamepad), label: 'کنترل'),
            NavigationDestination(icon: Icon(Icons.camera_alt), label: 'دوربین'),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(_online ? Icons.check_circle : Icons.error_outline, color: _online ? Colors.greenAccent : Colors.redAccent),
              const SizedBox(width: 8),
              Text(_online ? 'ESP32-CAM متصل است' : 'ESP32-CAM متصل نیست', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: _refreshRobot, icon: const Icon(Icons.refresh)),
            ]),
            if (_voltage != null) Text('ولتاژ باتری: ${_voltage!.toStringAsFixed(2)} V'),
          ]),
        ),
      );

  Widget _aiPage() => ListView(padding: const EdgeInsets.all(16), children: [
        _statusCard(),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'AI', label: Text('AI'), icon: Icon(Icons.auto_awesome)),
            ButtonSegment(value: 'Study', label: Text('Study'), icon: Icon(Icons.menu_book)),
            ButtonSegment(value: 'Game', label: Text('Game'), icon: Icon(Icons.sports_esports)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Align(alignment: Alignment.centerRight, child: Text('🧠 دستیار AK-1', style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Theme.of(context).colorScheme.surfaceContainerHighest), child: Text(_reply)),
          const SizedBox(height: 12),
          TextField(controller: _text, minLines: 1, maxLines: 4, decoration: InputDecoration(hintText: 'پیام یا سؤال خودت را بنویس...', border: const OutlineInputBorder(), suffixIcon: IconButton(onPressed: _busy ? null : () { final v = _text.text; _text.clear(); _ask(v); }, icon: const Icon(Icons.send)))),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _busy ? null : _voice, icon: Icon(_listening ? Icons.stop : Icons.mic), label: Text(_listening ? 'توقف شنیدن' : 'فرمان صوتی')),
        ]))),
      ]);

  Widget _controlPage() => ListView(padding: const EdgeInsets.all(16), children: [
        _statusCard(),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          const Text('↔️ چرخش ربات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton.filled(onPressed: () => _motor('LEFT'), icon: const Icon(Icons.rotate_left), iconSize: 32),
            const SizedBox(width: 18),
            IconButton.filledTonal(onPressed: () => _motor('STOP'), icon: const Icon(Icons.stop), iconSize: 32),
            const SizedBox(width: 18),
            IconButton.filled(onPressed: () => _motor('RIGHT'), icon: const Icon(Icons.rotate_right), iconSize: 32),
          ]),
          const SizedBox(height: 12),
          const Text('یک موتور زرد + چرخ با L298N برای چرخش چپ/راست.'),
        ]))),
      ]);

  Widget _cameraPage() => ListView(padding: const EdgeInsets.all(16), children: [
        _statusCard(),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          const Align(alignment: Alignment.centerRight, child: Text('📷 دوربین AK-1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          if (_cameraUrl != null && _cameraUrl!.isNotEmpty) Image.network(_cameraUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Padding(padding: EdgeInsets.all(30), child: Text('تصویر دریافت نشد.')))
          else const Padding(padding: EdgeInsets.all(30), child: Text('ESP32-CAM هنوز آدرس تصویر را اعلام نکرده است.')),
          FilledButton.icon(onPressed: _refreshRobot, icon: const Icon(Icons.refresh), label: const Text('به‌روزرسانی')),
        ]))),
      ]);
}
