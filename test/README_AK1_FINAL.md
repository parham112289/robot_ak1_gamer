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
