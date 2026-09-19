# AK-1 — Complete GitHub Package

این بسته برای قرار گرفتن **مستقیم در ریشه Repository گیت‌هاب** آماده شده است.

## ساخت APK
1. تمام فایل‌های این بسته را در Root ریپازیتوری قرار بده؛ یعنی `.github` و `phone_app` باید مستقیم در Root باشند.
2. برو به **Actions → build-apk**.
3. روی **Run workflow** بزن.
4. پس از موفقیت، از بخش **Artifacts** فایل `ak1-release-apk` را دریافت کن.

Workflow از قالب فعلی Flutter، پوشه Android را خودش تولید می‌کند تا نسخه‌های قدیمی Gradle/Android باعث خطای Build نشوند.

## اجزای پروژه
- `phone_app/` اپ Flutter
- `backend/` Cloudflare Worker / OpenRouter
- `esp32_cam/` firmware پایه ESP32-CAM
- `docs/` مستندات
- `.github/workflows/build-apk.yml` ساخت خودکار APK

## نکته
در اپ، **درصد باتری حذف شده** و فقط ولتاژ باتری در صورت ارسال شدن نمایش داده می‌شود.
