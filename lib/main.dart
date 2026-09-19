import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'services/ak1_service.dart';

void main() => runApp(const AK1App());

class AK1App extends StatelessWidget {
  const AK1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AK-1',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyan,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AK1Service service = AK1Service();
  final TextEditingController input = TextEditingController();
  final stt.SpeechToText speech = stt.SpeechToText();

  Timer? timer;
  int tab = 0;
  String mode = 'AI';
  String reply = 'سلام! من AK-1 هستم.';
  bool busy = false;
  bool listening = false;
  bool online = false;
  double? batteryVoltage;

  @override
  void initState() {
    super.initState();
    loadSettings();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => refreshStatus());
  }

  @override
  void dispose() {
    timer?.cancel();
    input.dispose();
    super.dispose();
  }

  Future<void> loadSettings() async {
    final p = await SharedPreferences.getInstance();
    final url = p.getString('robot_url');
    if (url != null && url.isNotEmpty) service.setRobotBaseUrl(url);
    await refreshStatus();
  }

  Future<void> refreshStatus() async {
    try {
      final s = await service.robotStatus();
      if (!mounted) return;
      setState(() {
        online = s.online;
        batteryVoltage = s.batteryVoltage;
      });
    } catch (_) {
      if (mounted) setState(() => online = false);
    }
  }

  Future<void> ask(String text) async {
    final value = text.trim();
    if (value.isEmpty || busy) return;
    setState(() {
      busy = true;
      reply = 'در حال پردازش...';
    });
    try {
      final answer = await service.askAI(value, mode: mode);
      if (mounted) setState(() => reply = answer);
    } catch (e) {
      if (mounted) setState(() => reply = 'خطا: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> voice() async {
    if (listening) {
      await speech.stop();
      if (mounted) setState(() => listening = false);
      return;
    }
    final available = await speech.initialize(
      onStatus: (s) {
        if (mounted && (s == 'done' || s == 'notListening')) {
          setState(() => listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => listening = false);
      },
    );
    if (!available) {
      if (mounted) snack('تشخیص صدا در دسترس نیست.');
      return;
    }
    setState(() => listening = true);
    await speech.listen(
      localeId: 'fa_IR',
      onResult: (r) {
        if (r.finalResult && r.recognizedWords.trim().isNotEmpty) {
          ask(r.recognizedWords);
        }
      },
    );
  }

  Future<void> motor(String action) async {
    try {
      await service.motor(action);
      if (mounted) snack('فرمان $action ارسال شد.');
    } catch (e) {
      if (mounted) snack('ارتباط با ESP32-CAM برقرار نشد.');
    }
  }

  Future<void> settings() async {
    final c = TextEditingController(text: service.robotBaseUrl);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('آدرس ESP32-CAM'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'http://192.168.1.50',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
          FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('ذخیره')),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    service.setRobotBaseUrl(result);
    final p = await SharedPreferences.getInstance();
    await p.setString('robot_url', service.robotBaseUrl);
    await refreshStatus();
  }

  void snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_aiPage(), _controlPage(), _cameraPage()];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AK-1 🤖'),
          actions: [
            Icon(
              online ? Icons.wifi : Icons.wifi_off,
              color: online ? Colors.greenAccent : Colors.redAccent,
            ),
            IconButton(onPressed: settings, icon: const Icon(Icons.settings)),
          ],
        ),
        body: pages[tab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.psychology), label: 'AI'),
            NavigationDestination(icon: Icon(Icons.gamepad), label: 'کنترل'),
            NavigationDestination(icon: Icon(Icons.camera_alt), label: 'دوربین'),
          ],
        ),
      ),
    );
  }

  Widget statusCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(online ? Icons.check_circle : Icons.error_outline,
                  color: online ? Colors.greenAccent : Colors.redAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(online ? 'ESP32-CAM متصل است' : 'ESP32-CAM متصل نیست'),
                    if (batteryVoltage != null)
                      Text('ولتاژ باتری: ${batteryVoltage!.toStringAsFixed(2)} V'),
                  ],
                ),
              ),
              IconButton(onPressed: refreshStatus, icon: const Icon(Icons.refresh)),
            ],
          ),
        ),
      );

  Widget _aiPage() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          statusCard(),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'AI', label: Text('AI')),
              ButtonSegment(value: 'Study', label: Text('Study')),
              ButtonSegment(value: 'Game', label: Text('Game')),
            ],
            selected: {mode},
            onSelectionChanged: (s) => setState(() => mode = s.first),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('🧠 دستیار AK-1',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Text(reply),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: input,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'پیامت را بنویس...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: busy
                            ? null
                            : () {
                                final t = input.text;
                                input.clear();
                                ask(t);
                              },
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: busy ? null : voice,
                      icon: Icon(listening ? Icons.stop : Icons.mic),
                      label: Text(listening ? 'توقف شنیدن' : 'فرمان صوتی'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _controlPage() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          statusCard(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('کنترل چرخش',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: () => motor('LEFT'),
                        icon: const Icon(Icons.rotate_left),
                        iconSize: 32,
                      ),
                      const SizedBox(width: 20),
                      IconButton.filledTonal(
                        onPressed: () => motor('STOP'),
                        icon: const Icon(Icons.stop),
                        iconSize: 32,
                      ),
                      const SizedBox(width: 20),
                      IconButton.filled(
                        onPressed: () => motor('RIGHT'),
                        icon: const Icon(Icons.rotate_right),
                        iconSize: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _cameraPage() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          statusCard(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('📷 دوربین AK-1',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text(
                    'پس از اتصال ESP32-CAM، آدرس تصویر از API ربات دریافت می‌شود.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: refreshStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('به‌روزرسانی'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
