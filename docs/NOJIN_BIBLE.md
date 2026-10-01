# NOJÎN — Product & Engineering Bible

## هویت

- نام برند: **NOJÎN / نوژین**
- مفهوم: «زندگی نو، تولد دوباره»
- شعار: «زندگی نو، تولد دوباره»
- محصول: LifeOS ایرانی، موبایل‌محور و offline-first
- زبان پیش‌فرض: فارسی
- جهت: RTL

## چهار حوزه اصلی

1. Notes — یادداشت‌ها و ویرایشگر غنی
2. Finance — حساب و مدیریت مالی شخصی
3. Planning — برنامه‌ریزی و روش‌های بهره‌وری
4. Info — مخزن اطلاعات شخصی

## اصول محصول

- ایران‌محور از ابتدا، نه ترجمه یک محصول خارجی
- Persian/RTL first
- Offline-first
- حداقل عملیات و حداکثر دو لمس برای عملیات‌های پرتکرار
- بدون Emoji در UI؛ آیکون‌های SVG/Vector
- تاریخ نمایشی جلالی و ذخیره‌سازی زمانی استاندارد
- اعداد فارسی در UI و فرمت‌سازی دوگانه EN/FA در داده‌های مالی
- تومان به‌عنوان واحد مالی پیش‌فرض و پشتیبانی از ریال
- پشتیبانی از نیازهای بانکی ایران: کارت، شبا، حساب، چک و اقساط
- Tehran timezone / Asia/Tehran
- امنیت و حریم خصوصی از لایه معماری

## دامنه Notes

دسته‌های پایه: ایده‌ها، کار، شخصی، مطالعه، عمومی.

ویرایشگر باید مسیر رشد به سمت متن غنی، heading، لیست، checklist، quote، code، جدول، لینک، divider و رسانه را پشتیبانی کند.

## دامنه Finance

- Accounts
- Transactions: income / expense / saving / transfer
- Installments
- Debt / Receivable
- Financial Goals
- Emergency Fund
- Dashboard و گزارش‌های مالی

## دامنه Planning

برنامه‌ریزی باید برای روش‌های تعریف‌شده در محصول از جمله Kaizen، 5S، Kanban، Ikigai، PDCA، Hoshin Kanri، Pomodoro، Deep Work، Eat the Frog، قانون دو دقیقه، Mood Tracker، Gratitude، CBT، Growth Mindset، Eisenhower، SMART، Time Blocking، Wheel of Life و Habit Tracker قابل توسعه باشد.

## دامنه Info

انواع اطلاعات: text، link، code، card، address، note، image با copy سریع و شمارنده استفاده.

## منبع حقیقت UI/UX

فایل `reference/nozhin_pwa_demo.html` مرجع رسمی ظاهر، layout، interaction و prototype behavior است. در تعارض با نسخه‌های قدیمی، این فایل مبناست مگر کاربر صریحاً مرجع جدیدی تعیین کند.

## اصل فنی

مرجع HTML برای استخراج رفتار و طراحی است، نه معماری نهایی. پیاده‌سازی محصول باید Native Flutter، قابل تست، ماژولار، offline-first و قابل توسعه باشد.
