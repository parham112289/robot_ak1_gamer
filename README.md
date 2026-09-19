# AK-1 — Complete GitHub Package

این نسخه برای قرار دادن مستقیم در GitHub آماده شده است.

## ساخت APK

Workflow با نام `build-apk` به صورت خودکار Flutter و Android platform را آماده می‌کند و APK را می‌سازد.

در GitHub:
1. وارد `Actions` شوید.
2. `build-apk` را انتخاب کنید.
3. `Run workflow` را بزنید.
4. پس از پایان موفق، در بخش `Artifacts` فایل `ak1-release-apk` را دریافت کنید.

### نکته مهم درباره خطای تصویر قبلی
خط قرمز `Process completed with exit code 1` فقط نتیجه‌ی شکست build است. هشدارهای Node.js 20 و setup-java v4 علت مستقیم خطا نیستند. این نسخه checkout و setup-java را به نسخه‌های جدیدتر تغییر داده و Android platform کامل را نیز در workflow تولید/ترمیم می‌کند.

## اجزای پروژه
- `phone_app/`: اپ Flutter
- `backend/`: Cloudflare Worker + OpenRouter
- `esp32_cam/`: کد پایه ESP32-CAM
- `.github/workflows/build-apk.yml`: ساخت خودکار APK

## AI
کلید OpenRouter نباید داخل Flutter یا GitHub قرار بگیرد. در Cloudflare Worker به عنوان Secret با نام `OPENROUTER_API_KEY` قرار دهید.

## باتری
درصد شارژ حذف شده است. اپ فقط در صورت دریافت مقدار، ولتاژ باتری را نشان می‌دهد.

## سخت‌افزار فعلی
ESP32-CAM، DFPlayer Mini + PAM8403، Wi-Fi، یک موتور گیربکس زرد با L298N برای چرخش چپ/راست. LCD، MPU6050، میکروفون روی ربات و PS4 در این نسخه نیستند.
