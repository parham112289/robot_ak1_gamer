# AK-1 Complete Update

نسخه کامل پروژه Flutter برای AK-1.

## امکانات رابط کاربری
- داشبورد فارسی و RTL
- تصویر زنده
- صدای محیط با انتخاب میکروفون گوشی/ربات
- دستیار هوشمند
- اتوماسیون هوشمند و سناریوهای خودکار
- هشدار و گزارش رویدادها
- Cloud / AI Vision / Robot Core status
- Game AI برای PS4 و Laptop
- حلقه Observe → Decide → Act
- توقف فوری

## نکته مهم
این نسخه UI و منطق نمایشی را آماده می‌کند. اتصال واقعی دوربین، میکروفون، WebRTC/stream، مدل Vision، Cloud و Bridge کنترلر باید جداگانه به سرویس‌ها و سخت‌افزار متصل شود.

## ساخت APK
Workflow موجود در `.github/workflows/build-apk.yml` برای GitHub Actions است و با `workflow_dispatch` اجرا می‌شود.
