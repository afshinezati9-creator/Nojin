# Phase 03 — Design System

## هدف

ایجاد Design System مرکزی برای NOJÎN بر اساس Golden Reference، بدون ورود به منطق دامنه‌های Notes، Finance، Planning و Info.

## منبع طراحی

فایل reference/nozhin_pwa_demo.html مرجع رسمی رنگ‌ها، radius، spacing، سایه‌ها و رفتار بصری است.

### Palette

- Blue Sky: #38BDF8
- Blue: #3B82F6
- Indigo: #6366F1
- Violet: #8B5CF6
- Purple: #A855F7
- Light background: #F4F6FA
- Light surface: #FFFFFF
- Light text: #0F172A
- Dark background: #0A0F1C
- Dark surface: #151E30
- Border: #E5E9F0
- Success: #10B981
- Danger: #EF4444
- Warning: #F59E0B
- Pink: #EC4899

Primary gradient: #3B82F6 → #8B5CF6

## ساختار

- lib/core/theme/nojin_tokens.dart — تمام توکن‌های بصری مرکزی
- lib/core/theme/nojin_theme.dart — Material 3 light/dark theme
- lib/shared/presentation/widgets/nojin_surface.dart — surface و gradient surface
- lib/shared/presentation/widgets/nojin_chip.dart — chip مطابق الگوی reference
- lib/shared/presentation/widgets/nojin_section_header.dart — عنوان بخش
- lib/shared/presentation/widgets/nojin_stat_card.dart — کارت آماری
- lib/shared/presentation/widgets/nojin_components.dart — barrel export

## تایپوگرافی

نام منطقی فونت اصلی Vazirmatn است و fallback به Tahoma, Arial و sans-serif تعریف شده است.

در این فاز فایل فونت داخل repository اضافه نشده است؛ بنابراین این فاز ادعا نمی‌کند که asset فونت محلی موجود است. اضافه‌کردن asset واقعی و سیاست بارگذاری آفلاین فونت باید قبل از release نهایی انجام شود.

## قواعد مصرف

Featureها نباید رنگ، radius یا spacing اختصاصی تکرارشونده بسازند؛ ابتدا از NojinColors، NojinSpacing، NojinRadii، NojinTypography و کامپوننت‌های shared استفاده کنند.

برای حالت‌های معنایی مانند موفقیت، خطا، اطلاعات و هشدار از semantic colors مرکزی استفاده شود.

## محدودیت این فاز

این فاز فقط Design System است. App Shell، adaptive navigation، آیکون‌های اختصاصی و responsive rules در فازهای بعدی تکمیل می‌شوند.
