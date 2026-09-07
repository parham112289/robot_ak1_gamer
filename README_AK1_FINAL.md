# AK-1 — Final-ready project

این نسخه ساختار اصلی قابلیت‌های AK-1 را یکجا نگه می‌دارد:

- Flutter Android app
- داشبورد، دستیار، دوربین/صدای محیط و Gaming UI
- اتصال LAN به Laptop Agent
- وضعیت لپ‌تاپ و دستورات allowlist شده
- صفحه نمایش لپ‌تاپ و کنترل‌های مربوط به استریم
- قرارداد Backend برای Cloud/AI/WebSocket
- قرارداد Robot Agent برای اتصال ربات
- GitHub Actions برای ساخت APK

## نکته مهم
این پروژه «پایه نهایی» است، اما فعال شدن اتصال واقعی به دستگاه‌ها به خود دستگاه و سرویس آن نیاز دارد. هیچ برنامه‌ای بدون IP/Pairing، سخت‌افزار دوربین/میکروفون، یا سرویس سمت مقابل نمی‌تواند از راه دور به دستگاهی متصل شود.

برای امنیت، Agent اجرای shell دلخواه، دسترسی به رمزها یا کنترل مخفی را ارائه نمی‌کند. نصب/حذف نرم‌افزار و عملیات حساس باید با تأیید کاربر انجام شود.

## GitHub حداقلی
برای ساخت APK این موارد را نگه دار:
- android/
- lib/
- laptop_agent/
- backend/
- robot_agent/
- .github/workflows/build-apk.yml
- pubspec.yaml
- pubspec.lock
- analysis_options.yaml
- .gitignore

## AK-1 AI / Voice / Speaker update
- Flutter can send text commands to `/v1/ai/command`.
- Flutter can capture a phone-camera frame and send it to `/v1/ai/vision` for Gemini vision analysis.
- Phone speech input uses Persian speech recognition.
- Phone speaker output uses Flutter TTS (`fa-IR`).
- Speaker output can be switched in the UI between phone and robot.
- Robot output sends text to the robot's `/audio/speak` endpoint. The ESP32 firmware must implement that endpoint and an actual audio playback path (for example a suitable audio/TTS module) before the robot physically speaks.
- Gemini API keys remain server-side in the Cloudflare Worker secret `GEMINI_API_KEY`.

## Backend diagnostics (FIXED v3)
The Android app now includes a **تست اتصال Backend** button. It checks `GET /v1/status` without calling Gemini and reports whether the Worker is reachable, its HTTP status, and whether `GEMINI_API_KEY` is configured on the Worker. AI requests still use `/v1/ai/command` and `/v1/ai/vision`.
