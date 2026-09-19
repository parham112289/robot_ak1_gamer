# معماری AK-1

گوشی نقش رابط کاربری و ورودی صوتی را دارد. Cloudflare Worker واسط امن بین اپ و OpenRouter است. ESP32-CAM نقش کنترلر سخت‌افزار و دوربین را دارد.

`Phone -> Cloudflare Worker -> OpenRouter`

`Phone -> Robot API -> ESP32-CAM -> Motor / DFPlayer / Camera`

در این نسخه درصد باتری حذف شده و فقط ولتاژ اختیاری است.
