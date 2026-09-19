# AK-1 — Clean Flutter Project

این پروژه برای شروع از صفر آماده شده است.

## نکته مهم

این Repository عمداً فایل‌های `android/` و `ios/` را داخل خود ندارد.
Flutter آن‌ها را از روی نسخه نصب‌شده تولید می‌کند تا فایل‌های قدیمی Gradle/Android وارد پروژه نشوند.

برای ساخت کامل:

```bash
flutter create .
flutter pub get
flutter test
flutter analyze
flutter build apk --release
```

بعد APK در این مسیر قرار می‌گیرد:

`build/app/outputs/flutter-apk/app-release.apk`

## GitHub

Workflow موجود در:

`.github/workflows/build-apk.yml`

قبل از Build، `flutter create --platforms=android .` را اجرا می‌کند و سپس APK را می‌سازد.

## OpenRouter

در Cloudflare Worker این Secret را تنظیم کن:

`OPENROUTER_API_KEY`

کلید را داخل Flutter یا GitHub قرار نده.

## ویژگی‌ها

- AI
- Study Mode
- Game Mode
- فرمان صوتی از گوشی
- ESP32-CAM
- کنترل LEFT / RIGHT / STOP
- دوربین
- نمایش ولتاژ باتری در صورت ارسال شدن
- بدون درصد باتری
- بدون PS4
- بدون LCD
- بدون میکروفون روی ربات

## ESP32

فایل نمونه:

`esp32_cam/AK1_ESP32_CAM.ino`

پین‌های موتور نمونه هستند و قبل از سیم‌کشی نهایی باید با مدار واقعی بررسی شوند.
