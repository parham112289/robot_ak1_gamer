# AK-1 — Complete Site Package

این مخزن برای پروژه AK-1 آماده شده و سه بخش اصلی دارد:

- `phone_app/` — اپ Flutter برای Android
- `backend/` — Cloudflare Worker برای اتصال امن به OpenRouter
- `esp32_cam/` — اسکلت firmware برای AI-Thinker ESP32-CAM
- `docs/` — راهنمای نصب و معماری

## قابلیت‌های نسخه

- فرمان متنی و صوتی از گوشی
- اتصال به AI از طریق OpenRouter
- Study Mode و Game Mode داخل اپ
- کنترل چرخش چپ/راست/توقف موتور از گوشی
- کنترل صدای ربات
- وضعیت آنلاین/آفلاین
- نمایش ولتاژ باتری **بدون نمایش درصد شارژ**
- بخش دوربین و آدرس Snapshot
- Cloudflare Worker بدون قرار دادن API Key داخل اپ
- آماده برای GitHub و Cloudflare

### موارد عمداً حذف‌شده

- PS4
- LCD
- میکروفون روی ربات
- MPU6050
- نمایش درصد شارژ باتری

> ماژول لیزر در این بسته به‌صورت سخت‌افزاری/نرم‌افزاری کنترل نمی‌شود؛ برای استفاده ایمن، تست خروجی را با LED انجام دهید.

## شروع سریع

1. پوشه `phone_app` را در Android Studio باز کنید.
2. در `lib/services/ak1_service.dart` آدرس Worker را تنظیم کنید.
3. در `backend/worker.js` Worker را روی Cloudflare Deploy کنید.
4. Secret با نام `OPENROUTER_API_KEY` را فقط در Cloudflare تنظیم کنید.
5. firmware پوشه `esp32_cam` را در Arduino IDE باز کنید.
6. قبل از اتصال موتور/صوت، پین‌ها و منبع تغذیه را با مدل دقیق بردهای خود تطبیق دهید.

## نکته مهم درباره باتری

در اپ فقط «ولتاژ باتری» نمایش داده می‌شود. درصد شارژ حذف شده است. مقدار ولتاژ از endpoint ربات می‌آید و در صورت نبود داده، `—` نمایش داده می‌شود.
