# AK-1 — Clean GitHub Project

این Repository از صفر ساخته شده و برای قرار دادن مستقیم در GitHub آماده است.

## نکته مهم
محتویات همین پوشه را در ریشه Repository قرار بده. پوشه دیگری مثل `AK1/` نباید دور آن قرار بگیرد و فایل‌های پروژه قبلی را هم نگه ندار.

## Build APK
GitHub Actions در هر Push یا Run دستی:
1. Flutter Stable را نصب می‌کند.
2. Android platform را با همان نسخه Flutter تولید می‌کند.
3. dependencies را می‌گیرد.
4. analyze و test را اجرا می‌کند.
5. APK release می‌سازد.
6. APK را در Artifacts قرار می‌دهد.

مسیر: Actions → Build AK-1 APK → Run workflow

## امکانات
- AI با OpenRouter
- Study Mode
- Game Mode
- فرمان متنی
- فرمان صوتی از میکروفون گوشی
- کنترل LEFT / RIGHT / STOP
- ESP32-CAM از طریق شبکه محلی
- نمایش وضعیت و ولتاژ باتری در صورت ارسال توسط ESP32
- تصویر دوربین
- تنظیم آدرس ESP32 از داخل اپ
- درصد باتری عمداً وجود ندارد
- PS4، LCD و میکروفون روی ربات وجود ندارند

## OpenRouter
در Cloudflare Worker یک Secret به نام `OPENROUTER_API_KEY` بساز. کلید را داخل GitHub یا Flutter قرار نده.

## ESP32
اپ برای سخت‌افزار از آدرس محلی ESP32 استفاده می‌کند. بعد از اتصال ESP32 به Wi-Fi، آدرس آن را در Settings اپ وارد کن، مثلاً `http://192.168.1.50`.

کد ESP32 داخل `esp32_cam/` است. پین‌های موتور نمونه هستند و قبل از سیم‌کشی باید با برد و سیم‌کشی واقعی بررسی شوند.
