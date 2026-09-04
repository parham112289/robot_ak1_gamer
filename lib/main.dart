import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
          title: const Text('ربات AK-1'),
          actions: [
            IconButton(
              tooltip: 'بازی هوشمند',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamingPage()),
              ),
              icon: const Icon(Icons.sports_esports_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _statusCard(),
            const SizedBox(height: 16),
            _menuCard(
              context,
              icon: Icons.videocam_outlined,
              title: '📱 دوربین گوشی / PS4',
              subtitle: 'نمایش مانیتور و آماده‌سازی تحلیل بازی',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.memory_rounded,
              title: '📷 دوربین ESP32-CAM',
              subtitle: 'نمایش تصویر زنده دوربین روی برد',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Esp32CamPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.settings_input_antenna_rounded,
              title: '📡 اتصال‌ها و باتری',
              subtitle: 'درصد باتری، Wi-Fi و Bluetooth',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectivityPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.sports_esports_outlined,
              title: 'بازی هوشمند',
              subtitle: 'AI برای تحلیل بازی و اجرای تصمیم‌ها',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamingPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.smart_toy_outlined,
              title: 'دستیار هوشمند',
              subtitle: 'فرمان صوتی و مدیریت هدف‌ها',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssistantPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.laptop_mac_outlined,
              title: 'کنترل لپتاپ',
              subtitle: 'اتصال امن، وضعیت سیستم و اجرای کارهای مجاز',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LaptopPage()),
              ),
            ),
            _menuCard(
              context,
              icon: Icons.auto_awesome,
              title: 'اتوماسیون هوشمند',
              subtitle: 'کارهایی که AK-1 می‌تواند به‌صورت خودکار مدیریت کند',
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

  Widget _statusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('وضعیت سیستم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 14),
            _StatusRow('Cloud', 'آماده', Icons.cloud_done_outlined),
            _StatusRow('AI Vision', 'آماده', Icons.visibility_outlined),
            _StatusRow('Robot Core', 'آماده', Icons.memory_outlined),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
      ),
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
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batterySub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  int _batteryLevel = 0;
  String _network = 'در حال بررسی...';
  String _bluetooth = 'برای وضعیت دقیق، تنظیمات دستگاه را بررسی کنید';

  @override
  void initState() {
    super.initState();
    _refresh();
    _batterySub = _battery.onBatteryStateChanged.listen((_) => _refreshBattery());
    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) => _refreshNetwork());
  }

  Future<void> _refresh() async {
    await _refreshBattery();
    await _refreshNetwork();
  }

  Future<void> _refreshBattery() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) setState(() => _batteryLevel = level);
    } catch (_) {}
  }

  Future<void> _refreshNetwork() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (!mounted) return;
      final hasWifi = results.contains(ConnectivityResult.wifi);
      final hasMobile = results.contains(ConnectivityResult.mobile);
      final hasEthernet = results.contains(ConnectivityResult.ethernet);
      setState(() {
        _network = hasWifi ? 'Wi-Fi متصل' : hasMobile ? 'اینترنت موبایل متصل' : hasEthernet ? 'Ethernet متصل' : 'آفلاین';
      });
    } catch (_) {
      if (mounted) setState(() => _network = 'نامشخص');
    }
  }

  Future<void> _openWifi() async {
    await const AndroidIntent(action: 'android.settings.WIFI_SETTINGS').launch();
  }

  Future<void> _openBluetooth() async {
    await const AndroidIntent(action: 'android.settings.BLUETOOTH_SETTINGS').launch();
  }

  @override
  void dispose() {
    _batterySub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اتصال‌ها و باتری')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(child: ListTile(leading: const Icon(Icons.battery_full_rounded), title: const Text('باتری گوشی'), trailing: Text('$_batteryLevel%'))),
            Card(child: ListTile(leading: const Icon(Icons.wifi_rounded), title: const Text('Wi-Fi / اینترنت'), subtitle: Text(_network), trailing: FilledButton(onPressed: _openWifi, child: const Text('تنظیم')))),
            Card(child: ListTile(leading: const Icon(Icons.bluetooth_rounded), title: const Text('Bluetooth'), subtitle: Text(_bluetooth), trailing: FilledButton(onPressed: _openBluetooth, child: const Text('تنظیم')))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('برای انتخاب Wi-Fi دلخواه یا اتصال ایرپاد، AK-1 صفحه تنظیمات رسمی Android را باز می‌کند تا انتخاب و جفت‌سازی توسط خود سیستم انجام شود. برنامه بدون اجازه سیستم، دستگاه Bluetooth یا شبکه را مخفیانه تغییر نمی‌دهد.', textAlign: TextAlign.right))),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh), label: const Text('به‌روزرسانی وضعیت')),
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

class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دستیار هوشمند')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(Icons.mic_none, size: 72),
            const SizedBox(height: 18),
            const Text(
              'فرمان نمونه',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '«در Elden Ring این باس را برای من شکست بده»',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamingPage()),
              ),
              icon: const Icon(Icons.sports_esports),
              label: const Text('باز کردن حالت بازی هوشمند'),
            ),
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
