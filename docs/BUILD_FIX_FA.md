# رفع خطای GitHub Actions

اگر فقط `Process completed with exit code 1` دیده می‌شود، باید وارد صفحه همان Job شوید و بخش build را باز کنید؛ این عبارت علت واقعی نیست.

این پکیج workflow را طوری تنظیم کرده که:
- Node.js 20 deprecation هشدار قبلی را با `checkout@v5` و `setup-java@v5` کنار بگذارد.
- Java 17 استفاده شود.
- Android platform با `flutter create` تولید/ترمیم شود.
- `flutter analyze` قبل از APK اجرا شود.
- APK به عنوان Artifact آپلود شود.
