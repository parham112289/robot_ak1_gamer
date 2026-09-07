import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/ak1_backend_service.dart';
import 'services/ak1_speech_service.dart';

void main() {
  runApp(const RobotAk1App());
}

class RobotAk1App extends StatelessWidget {
  const RobotAk1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AK-1',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF090B10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class LaptopScreenPage extends StatefulWidget {
  const LaptopScreenPage({super.key});
  @override State<LaptopScreenPage> createState() => _LaptopScreenPageState();
}

class _LaptopScreenPageState extends State<LaptopScreenPage> {
  bool live=false; bool audio=false;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('نمایش لپتاپ')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Icon(Icons.circle,size:13,color:live?Colors.red:Colors.grey), const SizedBox(width:8), Text(live?'LIVE • نمایش زنده':'OFFLINE',style:Theme.of(context).textTheme.titleMedium)]),
        const SizedBox(height:16),
        Container(height:230,decoration:BoxDecoration(color:Colors.black,borderRadius:BorderRadius.circular(18)),child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.desktop_windows_rounded,size:58,color:Colors.white54),const SizedBox(height:12),Text(live?'استریم صفحه لپتاپ اینجا نمایش داده می‌شود':'نمایش زنده خاموش است',style:const TextStyle(color:Colors.white70),textAlign:TextAlign.center)]))),
        SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('نمایش زنده صفحه'),subtitle:const Text('دریافت تصویر از Laptop Agent'),value:live,onChanged:(v)=>setState(()=>live=v)),
        SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('صدای سیستم'),subtitle:const Text('در صورت پشتیبانی استریم'),value:audio,onChanged:(v)=>setState(()=>audio=v)),
        OutlinedButton.icon(onPressed:live?()=>setState(()=>live=false):null,icon:const Icon(Icons.stop_circle_outlined),label:const Text('قطع نمایش')),
      ]))),
      const SizedBox(height:12),
      const Card(child:ListTile(leading:Icon(Icons.security_rounded),title:Text('اتصال امن'),subtitle:Text('برای تصویر واقعی، Laptop Agent باید screen capture و استریم امن را فراهم کند.'))),
    ]),
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: const Row(
            children: [
              _AkLogo(size: 38),
              SizedBox(width: 10),
              Text('AK-1', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'بازی هوشمند',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamingPage()),
              ),
              icon: const Icon(Icons.sports_esports_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _welcomeCard(context),
            const SizedBox(height: 16),
            _sectionTitle('کنترل و امکانات اصلی', 'همه چیز را از اینجا مدیریت کن'),
            const SizedBox(height: 10),
            _menuCard(
              context,
              icon: Icons.record_voice_over_rounded,
              title: 'دستور به ربات',
              subtitle: 'دستور متنی یا صوتی با میکروفون گوشی و ربات',
              badge: 'AI',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssistantPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.memory_rounded,
              title: 'دوربین ربات',
              subtitle: 'تصویر زنده از AI-Thinker ESP32-CAM',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Esp32CamPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.settings_input_antenna_rounded,
              title: 'اتصال و وضعیت ربات',
              subtitle: 'باتری ربات، Wi-Fi و Bluetooth خود ربات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectivityPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.videocam_outlined,
              title: 'دوربین گوشی / PS4',
              subtitle: 'نمایش مانیتور و آماده‌سازی تحلیل بازی',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.sports_esports_outlined,
              title: 'بازی هوشمند',
              subtitle: 'تحلیل بازی و تصمیم‌گیری با AI',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamingPage()),
              ),
            ),
            const SizedBox(height: 8),
            _sectionTitle('ابزارهای جانبی', 'امکانات بیشتر AK-1'),
            const SizedBox(height: 10),
            _menuCard(
              context,
              icon: Icons.laptop_mac_outlined,
              title: 'کنترل لپتاپ',
              subtitle: 'اتصال امن، وضعیت سیستم و کارهای مجاز',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LaptopPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.auto_awesome_rounded,
              title: 'اتوماسیون هوشمند',
              subtitle: 'مدیریت کارهایی که AK-1 می‌تواند خودکار انجام دهد',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AutomationPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(.24),
              Theme.of(context).colorScheme.surface,
            ],
          ),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(.18)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _AkLogo(size: 54),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('سلام! من AK-1 هستم', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('مرکز کنترل ربات و هوش مصنوعی', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 10),
                  SizedBox(width: 8),
                  Expanded(child: Text('ربات آماده اتصال است')),
                  Icon(Icons.chevron_left_rounded, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: primary, size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700))),
                        if (badge != null) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(.16),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12.5, color: Colors.white60, height: 1.25)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

class _AkLogo extends StatelessWidget {
  final double size;
  const _AkLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withOpacity(.55)],
        ),
        boxShadow: [BoxShadow(color: primary.withOpacity(.18), blurRadius: 14)],
      ),
      child: Icon(Icons.smart_toy_rounded, size: size * .52),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;

  const _StatusRow(this.title, this.status, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(status),
        ],
      ),
    );
  }
}

class ConnectivityPage extends StatefulWidget {
  const ConnectivityPage({super.key});
  @override
  State<ConnectivityPage> createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.4.1');
  int _robotBattery = 0;
  String _robotWifi = 'نامشخص';
  String _robotBluetooth = 'نامشخص';
  bool _loading = false;

  String get _baseUrl {
    final raw = _ipController.text.trim();
    if (raw.isEmpty) return '';
    return raw.startsWith('http://') || raw.startsWith('https://') ? raw : 'http://$raw';
  }

  Future<void> _readRobotStatus() async {
    if (_baseUrl.isEmpty) return;
    setState(() => _loading = true);
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$_baseUrl/status')).timeout(const Duration(seconds: 4));
      final response = await request.close().timeout(const Duration(seconds: 4));
      final body = await utf8.decoder.bind(response).join();
      client.close();
      final data = jsonDecode(body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _robotBattery = (data['battery'] as num?)?.toInt() ?? _robotBattery;
        _robotWifi = data['wifi']?.toString() ?? _robotWifi;
        _robotBluetooth = data['bluetooth']?.toString() ?? _robotBluetooth;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('وضعیت ربات دریافت نشد. فعلاً Firmware ربات باید API وضعیت را داشته باشد.')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _configureWifi() async {
    final result = await _wifiDialog();
    if (result == null) return;
    await _postRobot('/wifi/config', result);
  }

  Future<void> _configureBluetooth() async {
    final result = await _bluetoothDialog();
    if (result == null) return;
    await _postRobot('/bluetooth/config', result);
  }

  Future<Map<String, dynamic>?> _wifiDialog() async {
    final ssidController = TextEditingController();
    final passwordController = TextEditingController();
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تنظیم Wi-Fi خود ربات'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: ssidController, decoration: const InputDecoration(labelText: 'نام شبکه (SSID)', hintText: 'Wi-Fi خانه')),
          const SizedBox(height: 12),
          TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'رمز Wi-Fi')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
          FilledButton(onPressed: () {
            final ssid = ssidController.text.trim();
            if (ssid.isEmpty) return;
            Navigator.pop(context, {'ssid': ssid, 'password': passwordController.text});
          }, child: const Text('اتصال ربات')),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _bluetoothDialog() async {
    bool enabled = _robotBluetooth.toLowerCase().contains('on') || _robotBluetooth.contains('فعال');
    final nameController = TextEditingController(text: 'AK-1');
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Bluetooth خود ربات'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Bluetooth روشن باشد'), value: enabled, onChanged: (v) => setDialogState(() => enabled = v)),
            const SizedBox(height: 8),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'نام Bluetooth', hintText: 'AK-1')),
            const SizedBox(height: 8),
            const Text('این تنظیم برای Bluetooth خود ESP32-CAM است، نه Bluetooth گوشی.', style: TextStyle(fontSize: 12, color: Colors.white60)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('لغو')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, {'enabled': enabled, 'name': nameController.text.trim().isEmpty ? 'AK-1' : nameController.text.trim()}), child: const Text('ذخیره')),
          ],
        ),
      ),
    );
  }

  Future<void> _postRobot(String path, Map<String, dynamic> payload) async {
    if (_baseUrl.isEmpty) return;
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$_baseUrl$path')).timeout(const Duration(seconds: 4));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
      final response = await request.close().timeout(const Duration(seconds: 4));
      client.close();
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('درخواست برای ربات ارسال شد.')));
        await _readRobotStatus();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ربات پاسخ نداد. این بخش بعد از نصب Firmware ارتباطی روی ESP32-CAM فعال می‌شود.')));
    }
  }

  Future<String?> _textDialog(String title, String hint, {bool obscure = false}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('ذخیره')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اتصال ربات و باتری')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('این صفحه وضعیت خود ربات را نشان می‌دهد، نه باتری یا Wi-Fi گوشی. ESP32-CAM باید Firmware ارتباطی داشته باشد تا اطلاعات و تنظیمات از اینجا اعمال شود.'))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('آدرس ربات', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: _ipController, keyboardType: TextInputType.url, decoration: const InputDecoration(prefixIcon: Icon(Icons.router), hintText: '192.168.4.1', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              FilledButton.icon(onPressed: _loading ? null : _readRobotStatus, icon: const Icon(Icons.link), label: const Text('اتصال و دریافت وضعیت')),
            ]))),
            Card(child: ListTile(leading: const Icon(Icons.battery_full_rounded), title: const Text('باتری ربات'), trailing: Text('$_robotBattery%'))),
            Card(child: ListTile(leading: const Icon(Icons.wifi_rounded), title: const Text('Wi-Fi ربات'), subtitle: Text(_robotWifi), trailing: FilledButton(onPressed: _configureWifi, child: const Text('تنظیم')))),
            Card(child: ListTile(leading: const Icon(Icons.bluetooth_rounded), title: const Text('Bluetooth ربات'), subtitle: Text(_robotBluetooth), trailing: FilledButton(onPressed: _configureBluetooth, child: const Text('تنظیم')))),
            const SizedBox(height: 8),
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('هدف این بخش: انتخاب شبکه Wi-Fi موردنظر برای خود ربات و مدیریت Bluetooth خود ESP32-CAM. در مرحله Firmware، API های /status، /wifi/config و /bluetooth/config را روی ربات پیاده می‌کنیم.'))),
          ],
        ),
      ),
    );
  }
}

class Esp32CamPage extends StatefulWidget {
  const Esp32CamPage({super.key});
  @override
  State<Esp32CamPage> createState() => _Esp32CamPageState();
}

class _Esp32CamPageState extends State<Esp32CamPage> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.4.1');
  WebViewController? _webController;
  bool _loading = false;

  void _connect() {
    final raw = _ipController.text.trim();
    if (raw.isEmpty) return;
    final url = raw.startsWith('http://') || raw.startsWith('https://') ? raw : 'http://$raw';
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onPageStarted: (_) => setState(() => _loading = true), onPageFinished: (_) => setState(() => _loading = false), onWebResourceError: (_) => setState(() => _loading = false)))
      ..loadRequest(Uri.parse(url));
    setState(() => _webController = controller);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('دوربین ESP32-CAM')),
        body: Column(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: TextField(controller: _ipController, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'آدرس IP دوربین', hintText: 'مثلاً 192.168.4.1', border: OutlineInputBorder()))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _connect, icon: const Icon(Icons.link), label: const Text('اتصال به ESP32-CAM')))),
            if (_loading) const LinearProgressIndicator(),
            Expanded(child: _webController == null ? const Center(child: Text('IP دوربین را وارد کنید و اتصال را بزنید.\nESP32-CAM و گوشی باید روی یک شبکه باشند.', textAlign: TextAlign.center)) : WebViewWidget(controller: _webController!)),
          ],
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _selectedCamera = 0;
  bool _initializing = true;
  String? _error;
  bool _audioEnabled = true;
  bool _analyzing = false;
  String _visionAnswer = '';
  final TextEditingController _backendController = TextEditingController(text: 'https://robot-ak1-gamer.parhamsadr-s89.workers.dev');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameras();
  }

  Future<void> _initializeCameras({bool preserveSelection = false}) async {
    if (mounted) {
      setState(() {
        _initializing = true;
        _error = null;
      });
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException('NoCamera', 'هیچ دوربینی روی دستگاه پیدا نشد.');
      }
      if (!preserveSelection) {
        _selectedCamera = 0;
      } else if (_selectedCamera >= _cameras.length) {
        _selectedCamera = 0;
      }
      await _startController(_selectedCamera);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _error = _cameraErrorMessage(e);
          _initializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'راه‌اندازی دوربین ناموفق بود: $e';
          _initializing = false;
        });
      }
    }
  }

  Future<void> _startController(int index) async {
    final oldController = _controller;
    _controller = null;
    await oldController?.dispose();

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: _audioEnabled,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
        _error = null;
      });
    } on CameraException {
      await controller.dispose();
      rethrow;
    }
  }

  String _cameraErrorMessage(CameraException e) {
    switch (e.code) {
      case 'CameraAccessDenied':
        return 'دسترسی دوربین رد شده است. از تنظیمات گوشی، اجازه دوربین را برای AK-1 فعال کن.';
      case 'AudioAccessDenied':
        return 'دسترسی میکروفون رد شده است. اگر صدای محیط را می‌خواهی، اجازه میکروفون را فعال کن.';
      case 'CameraAccessRestricted':
        return 'دسترسی به دوربین توسط دستگاه محدود شده است.';
      default:
        return 'خطای دوربین: ${e.description ?? e.code}';
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _initializing) return;
    setState(() => _initializing = true);
    _selectedCamera = (_selectedCamera + 1) % _cameras.length;
    try {
      await _startController(_selectedCamera);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _error = _cameraErrorMessage(e);
          _initializing = false;
        });
      }
    }
  }

  Future<void> _toggleAudio() async {
    if (_initializing || _cameras.isEmpty) return;
    final next = !_audioEnabled;
    setState(() {
      _audioEnabled = next;
      _initializing = true;
    });
    try {
      await _startController(_selectedCamera);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _audioEnabled = !next;
          _error = _cameraErrorMessage(e);
          _initializing = false;
        });
      }
    }
  }

  Future<void> _analyzeCurrentFrame() async {
    final controller = _controller;
    final backend = _backendController.text.trim();
    if (controller == null || !controller.value.isInitialized || backend.contains('YOUR-WORKER')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('دوربین را آماده کن و آدرس واقعی Cloudflare Worker را وارد کن.')));
      return;
    }
    setState(() => _analyzing = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      final answer = await Ak1BackendService(backend).analyzeImage(imageBase64: base64Encode(bytes));
      if (!mounted) return;
      setState(() => _visionAnswer = answer.isEmpty ? 'پاسخی دریافت نشد.' : answer);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تحلیل تصویر ناموفق بود: $e')));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && _cameras.isNotEmpty) {
      _startController(_selectedCamera).catchError((Object error) {
        if (mounted) {
          setState(() {
            _error = error is CameraException
                ? _cameraErrorMessage(error)
                : 'بازگشت دوربین ناموفق بود.';
            _initializing = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _backendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      appBar: AppBar(
        title: const Text('دوربین زنده AK-1'),
        actions: [
          IconButton(
            tooltip: 'تعویض دوربین',
            onPressed: _cameras.length > 1 ? _switchCamera : null,
            icon: const Icon(Icons.flip_camera_android_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: ready ? controller.value.aspectRatio : 16 / 9,
              child: Container(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (ready) CameraPreview(controller),
                    if (_initializing)
                      const Center(child: CircularProgressIndicator()),
                    if (!ready && !_initializing)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam_off_rounded,
                                  size: 56, color: Colors.white54),
                              const SizedBox(height: 12),
                              Text(
                                _error ?? 'دوربین آماده نیست.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: _initializeCameras,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('تلاش دوباره'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Chip(
                        avatar: Icon(
                          ready ? Icons.circle : Icons.circle_outlined,
                          size: 12,
                        ),
                        label: Text(ready ? 'LIVE' : 'OFFLINE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('صدای محیط'),
                  subtitle: const Text('فعال‌کردن صدای ورودی دوربین/میکروفون'),
                  value: _audioEnabled,
                  onChanged: ready ? (_) => _toggleAudio() : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('دوربین انتخاب‌شده'),
                  subtitle: Text(
                    _cameras.isEmpty
                        ? 'در حال شناسایی دوربین‌ها...'
                        : _cameras[_selectedCamera].name,
                  ),
                  trailing: IconButton(
                    tooltip: 'تعویض دوربین',
                    onPressed: _cameras.length > 1 ? _switchCamera : null,
                    icon: const Icon(Icons.flip_camera_android_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('🧠 تحلیل تصویر با Gemini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: _backendController, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'آدرس Cloudflare Worker', hintText: 'https://....workers.dev', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                FilledButton.icon(onPressed: _analyzing ? null : _analyzeCurrentFrame, icon: _analyzing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome), label: Text(_analyzing ? 'در حال تحلیل...' : 'تحلیل فریم فعلی')),
                if (_visionAnswer.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_visionAnswer),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('آماده برای هوش مصنوعی'),
              subtitle: Text(
                'تصویر زنده حالا از دوربین واقعی گوشی دریافت می‌شود و می‌تواند در مرحله بعد به ماژول بینایی AK-1 وصل شود.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController _commandController = TextEditingController();
  final TextEditingController _backendController = TextEditingController(text: 'https://robot-ak1-gamer.parhamsadr-s89.workers.dev');
  final TextEditingController _robotController = TextEditingController(text: '192.168.4.1');
  final stt.SpeechToText _speech = stt.SpeechToText();
  final Ak1SpeechService _phoneSpeaker = Ak1SpeechService();
  bool _listeningPhone = false;
  bool _busy = false;
  String _voiceText = '';
  String _source = 'گوشی';
  String _output = 'گوشی';
  String _answer = '';

  @override
  void initState() {
    super.initState();
    _phoneSpeaker.init();
  }

  Future<void> _startPhoneVoice() async {
    final available = await _speech.initialize();
    if (!available) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('میکروفون/تشخیص گفتار گوشی در دسترس نیست.')));
      return;
    }
    setState(() { _listeningPhone = true; _source = 'گوشی'; });
    await _speech.listen(
      localeId: 'fa_IR',
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _voiceText = result.recognizedWords;
          _commandController.text = result.recognizedWords;
        });
      },
    );
  }

  Future<void> _stopPhoneVoice() async {
    await _speech.stop();
    if (mounted) setState(() => _listeningPhone = false);
  }

  Future<void> _sendCommand() async {
    final text = _commandController.text.trim();
    final backend = _backendController.text.trim();
    if (text.isEmpty || backend.contains('YOUR-WORKER')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اول آدرس واقعی Cloudflare Worker را وارد کن.')));
      return;
    }
    setState(() => _busy = true);
    try {
      final service = Ak1BackendService(backend);
      final answer = await service.ask(text);
      if (!mounted) return;
      setState(() => _answer = answer.isEmpty ? 'پاسخی دریافت نشد.' : answer);
      await _playAnswer(answer);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در اتصال به AI: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _playAnswer(String text) async {
    if (text.trim().isEmpty) return;
    if (_output == 'گوشی') {
      await _phoneSpeaker.speak(text);
      return;
    }
    try {
      await Ak1BackendService(_backendController.text.trim()).sendRobotSpeech(
        robotUrl: _robotController.text.trim(),
        text: text,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('متن پاسخ برای اسپیکر ربات ارسال شد.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('اسپیکر ربات آماده نیست: $e')));
    }
  }

  Future<void> _robotMicInfo() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مسیر میکروفون ربات آماده UI است؛ برای صدای واقعی باید میکروفون و Firmware صوتی ربات اضافه شود.')));
  }

  @override
  void dispose() {
    _commandController.dispose();
    _backendController.dispose();
    _robotController.dispose();
    _speech.stop();
    _phoneSpeaker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('دستور و گفت‌وگوی AK-1')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('AK-1 می‌تواند فرمان را از میکروفون گوشی بگیرد، به Cloud AI بفرستد و پاسخ را از اسپیکر گوشی یا مسیر اسپیکر ربات پخش کند.'))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('☁️ اتصال Cloud AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: _backendController, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'آدرس Cloudflare Worker', hintText: 'https://....workers.dev', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _robotController, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'آدرس ربات برای خروجی صدا', hintText: '192.168.4.1', border: OutlineInputBorder())),
            ]))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('✍️ / 🤖 فرمان', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(controller: _commandController, minLines: 2, maxLines: 4, decoration: const InputDecoration(hintText: 'مثلاً: وضعیت ربات را بگو', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              FilledButton.icon(onPressed: _busy ? null : _sendCommand, icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send), label: Text(_busy ? 'در حال پردازش...' : 'ارسال به Gemini')),
              if (_answer.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text('پاسخ AK-1', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.black26), child: Text(_answer)),
              ],
            ]))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('🎙️ ورودی صدا', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(segments: const [ButtonSegment(value: 'گوشی', label: Text('میکروفون گوشی'), icon: Icon(Icons.phone_android)), ButtonSegment(value: 'ربات', label: Text('میکروفون ربات'), icon: Icon(Icons.mic_external_on))], selected: {_source}, onSelectionChanged: (v) => setState(() => _source = v.first)),
              const SizedBox(height: 12),
              if (_source == 'گوشی')
                FilledButton.icon(onPressed: _listeningPhone ? _stopPhoneVoice : _startPhoneVoice, icon: Icon(_listeningPhone ? Icons.stop : Icons.mic), label: Text(_listeningPhone ? 'توقف شنیدن' : 'شروع فرمان صوتی گوشی'))
              else
                FilledButton.icon(onPressed: _robotMicInfo, icon: const Icon(Icons.mic_external_on), label: const Text('فعال‌سازی میکروفون ربات')),
              if (_voiceText.isNotEmpty) ...[const SizedBox(height: 8), Text('متن تشخیص‌داده‌شده: $_voiceText')],
            ]))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('🔊 خروجی صدا', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(segments: const [ButtonSegment(value: 'گوشی', label: Text('اسپیکر گوشی'), icon: Icon(Icons.phone_android)), ButtonSegment(value: 'ربات', label: Text('اسپیکر ربات'), icon: Icon(Icons.volume_up_rounded))], selected: {_output}, onSelectionChanged: (v) => setState(() => _output = v.first)),
              const SizedBox(height: 8),
              Text(_output == 'گوشی' ? 'پاسخ با صدای فارسی از گوشی پخش می‌شود.' : 'پاسخ برای API صوتی ربات ارسال می‌شود؛ Firmware صوتی ربات باید /audio/speak را پشتیبانی کند.', style: const TextStyle(color: Colors.white60)),
            ]))),
          ],
        ),
      ),
    );
  }
}

class AutomationPage extends StatefulWidget {
  const AutomationPage({super.key});

  @override
  State<AutomationPage> createState() => _AutomationPageState();
}

class _AutomationPageState extends State<AutomationPage> {
  final Map<String, bool> automations = {
    'دستیار همیشه آماده': true,
    'هشدار هوشمند تصویر': true,
    'حالت شب': false,
    'شروع خودکار دوربین': false,
    'همگام‌سازی Cloud': true,
    'Game AI با تأیید من': false,
  };

  final List<String> events = [
    'AK-1 آماده است',
    'Cloud متصل شد',
    'AI Vision آماده است',
  ];

  void runAutomation(String name) {
    setState(() {
      events.insert(0, 'اجرای خودکار: $name');
      if (events.length > 5) events.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اتوماسیون هوشمند')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'AK-1 خودش کارها را مدیریت کند',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'این صفحه تنظیمات و سناریوهای خودکار را آماده می‌کند. اجرای واقعی هر قابلیت بعداً به سرویس، مجوز و سخت‌افزار مربوط وصل می‌شود.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...automations.entries.map(
            (entry) => Card(
              child: SwitchListTile(
                title: Text(entry.key),
                subtitle: Text(_subtitle(entry.key)),
                value: entry.value,
                onChanged: (v) => setState(() => automations[entry.key] = v),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سناریوهای سریع',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _quickAction('🌙 حالت شب', 'نور و اعلان‌ها را برای استفاده شبانه تنظیم کن'),
                  _quickAction('👁️ نگهبان تصویر', 'در صورت تشخیص رویداد مهم، اعلان بده'),
                  _quickAction('☁️ همگام‌سازی', 'اطلاعات مجاز را با Cloud هماهنگ کن'),
                  _quickAction('🎮 شروع Game AI', 'قبل از اجرای کنترل خودکار، تأیید کاربر را بگیر'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'گزارش آخرین رویدادها',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...events.map(
                    (e) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.bolt_outlined),
                      title: Text(e),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(String name) {
    switch (name) {
      case 'دستیار همیشه آماده':
        return 'برای فرمان‌های مجاز، آماده دریافت درخواست باشد';
      case 'هشدار هوشمند تصویر':
        return 'تشخیص رویدادهای تعریف‌شده و ارسال اعلان';
      case 'حالت شب':
        return 'پروفایل آرام برای ساعات شب';
      case 'شروع خودکار دوربین':
        return 'با تأیید کاربر، دوربین را برای یک سناریوی مشخص باز کند';
      case 'همگام‌سازی Cloud':
        return 'ذخیره و هماهنگ‌سازی داده‌های مجاز';
      default:
        return 'اجرای Game AI فقط با تأیید کاربر';
    }
  }

  Widget _quickAction(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.auto_awesome)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: 'اجرا',
        icon: const Icon(Icons.play_circle_outline),
        onPressed: () => runAutomation(title),
      ),
    );
  }
}


class LaptopAgentClient {
  Uri _uri(String address, String path) {
    var value = address.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'http://$value';
    }
    return Uri.parse('$value$path');
  }

  Future<Map<String, dynamic>> health(String address) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(_uri(address, '/health')).timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(const Duration(seconds: 3));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> status(String address) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(_uri(address, '/status')).timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(const Duration(seconds: 3));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> command(String address, String action) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(_uri(address, '/command')).timeout(const Duration(seconds: 3));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'action': action}));
      final response = await request.close().timeout(const Duration(seconds: 5));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: $body');
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }
}


class LaptopPage extends StatefulWidget {
  const LaptopPage({super.key});

  @override
  State<LaptopPage> createState() => _LaptopPageState();
}

class _LaptopPageState extends State<LaptopPage> {
  final ipController = TextEditingController(text: '192.168.1.100:8765');
  bool connected = false;
  bool busy = false;
  String status = 'هنوز به لپتاپ متصل نیست';
  String systemInfo = 'برای دریافت وضعیت، ابتدا اتصال را برقرار کن.';
  final logs = <String>[];
  final agent = LaptopAgentClient();

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  Future<void> connect() async {
    final address = ipController.text.trim();
    if (address.isEmpty) return;
    setState(() => busy = true);
    try {
      final result = await agent.health(address);
      final info = await agent.status(address);
      if (!mounted) return;
      setState(() {
        busy = false;
        connected = true;
        status = 'متصل به ${result['name'] ?? address}';
        systemInfo = 'سیستم: ${info['platform'] ?? 'نامشخص'} | CPU: ${info['cpu'] ?? '—'} | RAM: ${info['ram'] ?? '—'}';
        logs.insert(0, 'اتصال واقعی به Agent برقرار شد');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اتصال برقرار نشد: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }

  void disconnect() {
    setState(() {
      connected = false;
      status = 'اتصال قطع شد';
      logs.insert(0, 'اتصال لپتاپ قطع شد');
    });
  }

  Future<void> requestAction(String action) async {
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اول لپتاپ را وصل کن.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأیید عملیات'),
        content: Text('$action\n\nاین عملیات فقط از طریق Agent مجاز لپتاپ انجام می‌شود.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأیید')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        final result = await agent.command(ipController.text.trim(), action);
        if (!mounted) return;
        setState(() => logs.insert(0, 'دستور واقعی ارسال شد: $action'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']?.toString() ?? 'دستور ارسال شد.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ارسال دستور ناموفق بود: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('کنترل لپتاپ')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(connected ? Icons.link : Icons.link_off, size: 28),
                      const SizedBox(width: 10),
                      Expanded(child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ]),
                    const SizedBox(height: 14),
                    TextField(
                      controller: ipController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'آدرس Agent لپتاپ',
                        hintText: '192.168.1.100:8765',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: busy ? null : (connected ? disconnect : connect),
                        icon: Icon(connected ? Icons.link_off : Icons.link),
                        label: Text(connected ? 'قطع اتصال' : 'اتصال'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(child: ListTile(leading: const Icon(Icons.monitor_heart_outlined), title: const Text('وضعیت سیستم'), subtitle: Text(systemInfo))),
            const SizedBox(height: 4),
            const Text('کارهای مجاز', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _actionTile(Icons.apps_outlined, 'باز کردن برنامه', 'اجرای یک برنامه مشخص', () => requestAction('باز کردن برنامه')),
            _actionTile(Icons.close, 'بستن برنامه', 'بستن برنامه مشخص', () => requestAction('بستن برنامه')),
            _actionTile(Icons.download_outlined, 'نصب برنامه', 'با تأیید تو و از طریق package manager سیستم', () => requestAction('نصب برنامه')),
            _actionTile(Icons.delete_outline, 'حذف برنامه', 'با تأیید تو و بررسی نام/شناسه دقیق برنامه', () => requestAction('حذف برنامه')),
            _actionTile(Icons.folder_outlined, 'مدیریت فایل', 'فقط مسیرها و عملیات مجاز Agent', () => requestAction('مدیریت فایل')),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('امنیت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('AK-1 نباید دسترسی نامحدود به لپتاپ داشته باشد. اتصال با Pairing انجام می‌شود و نصب/حذف برنامه همیشه نیاز به تأیید کاربر دارد.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  if (logs.isEmpty) const Text('گزارشی ثبت نشده است.', style: TextStyle(color: Colors.white54))
                  else ...logs.take(6).map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('• $e'))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}

class GamingPage extends StatefulWidget {
  const GamingPage({super.key});

  @override
  State<GamingPage> createState() => _GamingPageState();
}

class _GamingPageState extends State<GamingPage> {
  Timer? _timer;
  bool aiRunning = false;
  String platform = 'PS4';
  String game = 'Elden Ring';
  String goal = 'شکست دادن باس';
  String decision = 'در انتظار تصویر بازی...';
  double confidence = 0;
  int frame = 0;

  final List<String> demoDecisions = [
    'در حال تحلیل تصویر بازی...',
    'بازیکن و باس شناسایی شدند',
    'فاصله مناسب برای حمله',
    'تصمیم پیشنهادی: ATTACK',
    'حمله باس شناسایی شد',
    'تصمیم پیشنهادی: DODGE',
    'دوباره در حال مشاهده وضعیت...',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void toggleAi() {
    if (aiRunning) {
      _timer?.cancel();
      setState(() {
        aiRunning = false;
        decision = 'AI متوقف شد';
        confidence = 0;
      });
      return;
    }

    setState(() {
      aiRunning = true;
      decision = 'شروع حلقه Observe → Decide → Act';
    });

    _timer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      frame++;
      final index = frame % demoDecisions.length;
      setState(() {
        decision = demoDecisions[index];
        confidence = index == 0 ? 0.0 : 0.72 + ((index % 3) * 0.08);
      });
    });
  }

  void stopImmediately() {
    _timer?.cancel();
    setState(() {
      aiRunning = false;
      decision = 'توقف اضطراری — هیچ ورودی کنترلی ارسال نشد';
      confidence = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازی هوشمند'),
        actions: [
          IconButton(
            tooltip: 'توقف',
            onPressed: stopImmediately,
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _gamePreview(),
          const SizedBox(height: 14),
          _selectors(),
          const SizedBox(height: 14),
          _goalCard(),
          const SizedBox(height: 14),
          _aiCard(),
          const SizedBox(height: 14),
          _architectureCard(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: toggleAi,
                  icon: Icon(aiRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(aiRunning ? 'توقف AI' : 'شروع AI'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: stopImmediately,
                  icon: const Icon(Icons.stop),
                  label: const Text('توقف فوری'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gamePreview() {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videogame_asset_outlined, size: 56, color: Colors.white54),
                SizedBox(height: 10),
                Text('ورودی تصویر بازی'),
                SizedBox(height: 5),
                Text(
                  'فعلاً شبیه‌سازی شده؛ اتصال واقعی دوربین/استریم بعداً اضافه می‌شود.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Chip(
              avatar: Icon(
                aiRunning ? Icons.circle : Icons.circle_outlined,
                size: 13,
              ),
              label: Text(aiRunning ? 'AI ACTIVE' : 'AI OFF'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectors() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: platform,
              decoration: const InputDecoration(
                labelText: 'پلتفرم',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'PS4', child: Text('PlayStation 4')),
                DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
              ],
              onChanged: (v) => setState(() => platform = v ?? platform),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: game,
              decoration: const InputDecoration(
                labelText: 'بازی',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Elden Ring', child: Text('Elden Ring')),
              ],
              onChanged: (v) => setState(() => game = v ?? game),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalCard() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.flag_outlined)),
        title: const Text('هدف AI'),
        subtitle: Text(goal),
        trailing: const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _aiCard() {
    final percent = (confidence * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تصمیم فعلی AI',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(decision),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: confidence),
            const SizedBox(height: 8),
            Text('اعتماد تقریبی: $percent%'),
            const SizedBox(height: 12),
            const Text(
              'این نسخه حلقه تحلیل و تصمیم را شبیه‌سازی می‌کند؛ اتصال واقعی کنترلر باید جداگانه پیاده‌سازی شود و اجرای خودکار بهتر است با تأیید کاربر انجام شود.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _architectureCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'مسیر اجرای AI',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('📷 تصویر → 👁️ Vision → 🧠 تصمیم → 🎮 Controller Bridge'),
            SizedBox(height: 8),
            Text(
              'اتصال واقعی دوربین، مدل بینایی و مسیر کنترلر باید جداگانه پیاده‌سازی و با مجوزهای لازم سیستم‌عامل انجام شود.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
