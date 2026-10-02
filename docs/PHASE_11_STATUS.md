# Phase 11 — Media Engine

## هدف

افزودن موتور رسانه‌ای آفلاین برای Notes با ذخیره‌سازی محلی، متادیتای مستقل و اتصال مستقیم به Rich Editor.

## قابلیت‌های این فاز

- تصویر از گالری
- ویدئو از گالری
- انتخاب فایل عمومی
- ضبط صوت از میکروفون
- تبدیل PCM ضبط‌شده به WAV برای پخش محلی
- پیش‌نمایش تصویر
- پخش صوت ذخیره‌شده با bytes
- نمایش متادیتای ویدئو و فایل
- سقف ۲۵ مگابایت برای هر پیوست
- ذخیره bytes در جدول مستقل note_media
- ارتباط رسانه با note_id
- بلوک‌های مستقل image، video، audio و file در Rich Document
- حذف رسانه‌های حذف‌شده هنگام ویرایش یادداشت
- حذف رسانه‌های یک یادداشت هنگام حذف خود یادداشت
- سازگاری با Flutter Web از طریق pickerها و Drift Web؛ مسیر ذخیره‌سازی به فایل‌سیستم محلی وابسته نیست.

## مدل داده

Database schema از نسخه ۱ به نسخه ۲ ارتقا یافت.

note_media:
- id
- note_id
- media_type
- file_name
- mime_type
- bytes
- size_bytes
- duration_ms
- created_at

رسانه داخل JSON متن یادداشت ذخیره نمی‌شود؛ JSON فقط شناسه رسانه را در mediaId نگه می‌دارد.

## وابستگی‌ها

- image_picker برای تصویر/ویدئو
- file_picker برای فایل عمومی
- record برای ضبط صوت
- audioplayers برای پخش bytes
- mime برای تشخیص MIME
- video_player برای مسیر توسعه پخش ویدئو

نسخه‌های انتخاب‌شده بر اساس مستندات pub.dev در زمان اجرای Phase 11:
- image_picker 1.2.3
- file_picker 13.1.0
- record 7.1.1
- audioplayers 6.8.1
- video_player 2.14.0
- mime 2.1.0

## محدودیت آگاهانه

در این فاز ویدئو ذخیره و در ادیتور به‌عنوان پیوست نمایش داده می‌شود؛ پخش ویدئوی inline به‌صورت cross-platform مستقل از فایل‌سیستم در این فاز نهایی نشده است تا Flutter Web به dart:io وابسته نشود.

## تست

تست‌های repository و schema اضافه شده‌اند. در محیط فعلی Flutter SDK در دسترس نیست؛ بنابراین اجرای واقعی flutter analyze و flutter test ادعا نمی‌شود. تست نهایی باید روی Windows/Chrome و Android محلی انجام شود.
