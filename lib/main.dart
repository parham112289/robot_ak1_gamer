import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/ak1_service.dart';

void main() => runApp(const AK1App());

class AK1App extends StatelessWidget {
  const AK1App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AK-1',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = AK1Service();
  final text = TextEditingController();
  final speech = stt.SpeechToText();
  Timer? timer;
  int tab = 0;
  bool listening = false;
  String voiceText = '';
  String statusText = 'آماده';
  String aiReply = '';
  RobotStatus robot = const RobotStatus(online: false, batteryVoltage: 0);
  String? cameraUrl;

  @override
  void initState() {
    super.initState();
    refresh();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
  }

  @override
  void dispose() {
    timer?.cancel();
    text.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    try {
      final s = await service.status();
      if (!mounted) return;
      setState(() { robot = s; cameraUrl = s.cameraUrl ?? cameraUrl; });
    } catch (_) {
      if (mounted) setState(() => robot = const RobotStatus(online: false, batteryVoltage: 0));
    }
  }

  Future<void> ask(String value, {String mode = 'general'}) async {
    if (value.trim().isEmpty) return;
    setState(() => statusText = 'در حال پردازش...');
    try {
      final result = await service.command(value.trim(), mode: mode);
      if (!mounted) return;
      setState(() { aiReply = result.text; statusText = 'پاسخ دریافت شد'; });
    } catch (_) {
      if (mounted) setState(() => statusText = 'خطا در ارتباط با AI');
    }
  }

  Future<void> voice() async {
    if (listening) { await speech.stop(); setState(() => listening = false); return; }
    final ok = await speech.initialize(onStatus: (s) {
      if (mounted && (s == 'done' || s == 'notListening')) setState(() => listening = false);
    }, onError: (_) { if (mounted) setState(() => listening = false); });
    if (!ok) { setState(() => statusText = 'تشخیص صدای گوشی در دسترس نیست'); return; }
    setState(() => listening = true);
    await speech.listen(localeId: 'fa_IR', onResult: (r) {
      if (!mounted) return;
      setState(() => voiceText = r.recognizedWords);
      if (r.finalResult && r.recognizedWords.trim().isNotEmpty) ask(r.recognizedWords);
    });
  }

  Future<void> move(String action) async {
    setState(() => statusText = 'ارسال فرمان $action...');
    try { await service.robotCommand(action); if (mounted) setState(() => statusText = 'انجام شد'); }
    catch (_) { if (mounted) setState(() => statusText = 'فرمان به ربات ارسال نشد'); }
  }

  Widget statusCard() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    Row(children: [Icon(robot.online ? Icons.wifi : Icons.wifi_off), const SizedBox(width: 10), Expanded(child: Text(robot.online ? 'AK-1 متصل است' : 'AK-1 آفلاین است', style: const TextStyle(fontWeight: FontWeight.bold))), IconButton(onPressed: refresh, icon: const Icon(Icons.refresh))]),
    const Divider(),
    Row(children: [const Icon(Icons.battery_6_bar), const SizedBox(width: 10), Text(robot.batteryVoltage > 0 ? 'ولتاژ باتری: ${robot.batteryVoltage.toStringAsFixed(2)} V' : 'ولتاژ باتری: —')]),
  ])));

  Widget aiPanel() => Column(children: [
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('🧠 AI AK-1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      TextField(controller: text, minLines: 1, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'سؤال یا فرمان خود را بنویس...')),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: FilledButton.icon(onPressed: () { final v = text.text; text.clear(); ask(v); }, icon: const Icon(Icons.send), label: const Text('ارسال'))), const SizedBox(width: 8), IconButton.filled(onPressed: voice, icon: Icon(listening ? Icons.stop : Icons.mic))]),
      if (voiceText.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('صدا: $voiceText')),
      if (aiReply.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).colorScheme.surfaceContainerHighest), child: Text(aiReply))),
    ]))),
    Row(children: [Expanded(child: _mode('📚 مطالعه', 'study')), const SizedBox(width: 8), Expanded(child: _mode('🎮 بازی', 'game'))]),
  ]);

  Widget _mode(String label, String mode) => FilledButton.tonal(onPressed: () => ask('حالت $mode را فعال کن و برای این حالت آماده باش.', mode: mode), child: Text(label));

  Widget controlPanel() => Column(children: [
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
      const Text('↔️ چرخش ربات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton.filled(onPressed: () => move('LEFT'), icon: const Icon(Icons.rotate_left), iconSize: 32), const SizedBox(width: 18), IconButton.filledTonal(onPressed: () => move('STOP'), icon: const Icon(Icons.stop), iconSize: 32), const SizedBox(width: 18), IconButton.filled(onPressed: () => move('RIGHT'), icon: const Icon(Icons.rotate_right), iconSize: 32)]),
    ]))),
    Card(child: ListTile(leading: const Icon(Icons.volume_up), title: const Text('صدای ربات'), subtitle: const Text('کنترل صدای سخت‌افزار از طریق firmware در نسخه‌های بعدی'))),
  ]);

  Widget cameraPanel() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('📷 دوربین AK-1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
    if (cameraUrl != null && cameraUrl!.isNotEmpty) Image.network(cameraUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Padding(padding: EdgeInsets.all(24), child: Text('تصویر دوربین در دسترس نیست.')))
    else const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('آدرس Snapshot دوربین هنوز از ربات دریافت نشده است.'))),
    const SizedBox(height: 8), TextButton.icon(onPressed: refresh, icon: const Icon(Icons.refresh), label: const Text('به‌روزرسانی تصویر')),
  ]));

  @override
  Widget build(BuildContext context) {
    final pages = [ListView(padding: const EdgeInsets.all(16), children: [statusCard(), aiPanel(), const SizedBox(height: 8), Text(statusText)]), ListView(padding: const EdgeInsets.all(16), children: [statusCard(), controlPanel(), cameraPanel()]), cameraPanel()];
    return Scaffold(appBar: AppBar(title: const Text('AK-1 🤖')), body: pages[tab], bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [NavigationDestination(icon: Icon(Icons.psychology), label: 'AI'), NavigationDestination(icon: Icon(Icons.gamepad), label: 'کنترل'), NavigationDestination(icon: Icon(Icons.camera_alt), label: 'دوربین')]));
  }
}
