# AK-1 — Complete Fresh Project

این نسخه **از صفر و در ریشه Repository** آماده شده است؛ مثل زمانی که یک Flutter project جدید می‌سازی.

## ساختار اصلی

```text
AK-1/
├── .github/workflows/build-apk.yml
├── lib/
│   ├── main.dart
│   └── services/ak1_service.dart
├── backend/
├── esp32_cam/
├── docs/
├── pubspec.yaml
└── README.md
```

## قابلیت‌های اپ

- AI با OpenRouter
- Study Mode
- Game Mode
- فرمان متنی
- فرمان صوتی از میکروفون گوشی
- کنترل LEFT / RIGHT / STOP
- نمایش آنلاین/آفلاین
- نمایش ولتاژ باتری در صورت دریافت شدن
- صفحه دوربین
- بدون درصد شارژ باتری
- بدون PS4 و LCD

## GitHub

کل محتویات همین پوشه را مستقیماً در ریشه Repository قرار بده.

سپس از بخش **Actions**، workflow با نام **Build AK-1 APK** را اجرا کن. Workflow ابتدا Android project را با قالب همان نسخه Flutter می‌سازد و بعد APK release تولید می‌کند.

## Backend

در Cloudflare Worker Secret زیر را تنظیم کن:

`OPENROUTER_API_KEY`

مدل پیش‌فرض:

`openrouter/free`

## نکته سخت‌افزار

کد ESP32-CAM موجود در این بسته پایه است. پین‌های واقعی موتور، DFPlayer و سایر قطعات باید با برد و سیم‌کشی نهایی تطبیق داده شوند.
