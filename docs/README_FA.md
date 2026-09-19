# AK-1 — پروژه تازه از صفر

این Repository از ریشه به شکل یک پروژه Flutter ساخته شده است؛ پوشه `phone_app` ندارد.

اجزای پروژه:
- اپ Flutter در ریشه (`lib/`)
- ساخت خودکار Android در GitHub Actions
- Cloudflare Worker + OpenRouter در `backend/`
- firmware پایه ESP32-CAM در `esp32_cam/`
- مستندات در `docs/`

درصد شارژ باتری عمداً در اپ وجود ندارد؛ فقط ولتاژ در صورت دریافت از backend نمایش داده می‌شود.

کلید OpenRouter باید فقط به‌عنوان Secret در Cloudflare Worker با نام `OPENROUTER_API_KEY` قرار بگیرد و نباید داخل GitHub یا اپ ذخیره شود.
