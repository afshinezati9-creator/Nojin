# NOJÎN — Development Roadmap

## Phase 00 — Golden Reference / Repository Stabilization
- تثبیت مخزن
- انتقال Golden Reference به `reference/nozhin_pwa_demo.html`
- ایجاد Bible، Architecture و Roadmap
- تعیین سلسله‌مراتب منابع تصمیم‌گیری
- ایجاد branch مستقل و PR

## Phase 01 — Flutter Foundation
پروژه Native Flutter، routing، state management، theme، logging، error handling و DI.

## Phase 02 — Iranian Core
RTL، فارسی، اعداد فارسی، تومان/ریال، جلالی، Asia/Tehran، تلفن +98، داده‌های بانکی و تعطیلات.

## Phase 03 — Design System
تبدیل طراحی Golden Reference به tokenها و componentهای Native Flutter.

## Phase 04 — App Shell
Splash، header، brand، tabs، FAB، overlay، dialog، bottom sheet و shell اصلی چهار حوزه.

## Phase 05 — SVG Icon System
سیستم آیکون بدون Emoji و قابل استفاده مجدد.

## Phase 06 — Responsive / Adaptive
پشتیبانی از موبایل، تبلت و landscape.

## Phase 07 — Local Database
مدل‌ها، migration، index، repository و integrity برای Notes/Finance/Planning/Info/Settings.

## Phase 08 — State Architecture
Riverpod و جریان UI → UseCase → Repository → Local Data.

## Phase 09 — Notes Foundation
لیست، جست‌وجو، دسته‌بندی، sort، pin، archive، CRUD.

## Phase 10 — Rich Editor
ویرایشگر غنی و toolbarهای مطابق مرجع.

## Phase 11 — Media Engine
Image / Video / Voice / Audio، permission، storage، compression و playback.

## Phase 12 — Finance Foundation
Account، transaction و balance logic.

## Phase 13 — Iranian Finance
کارت، شبا، حساب، چک، اقساط، تومان/ریال و تاریخ جلالی.

## Phase 14 — Finance Dashboard
دارایی، درآمد، هزینه، پس‌انداز، حساب‌ها، نمودار و شاخص‌های مالی.

## Phase 15 — Installments
مدیریت کامل اقساط.

## Phase 16 — Debt / Receivable
بدهی و طلب.

## Phase 17 — Goals / Emergency Fund
اهداف مالی و صندوق اضطراری.

## Phase 18 — Planning Engine
هسته 19 روش برنامه‌ریزی.

## Phase 19 — Planning Widgets
ویجت‌ها، وضعیت، progress، history و statistics.

## Phase 20 — Calendar Engine
جلالی/میلادی/قمری، مناسبت‌ها، تعطیلات، تولد و سررسید.

## Phase 21 — Info Vault
text/link/code/card/address/note/image، copy سریع و usage counter.

## Phase 22 — Settings
Theme، font، profile، language، calendar، currency، notifications، privacy.

## Phase 23 — Backup / Restore
JSON versioned backup، validation، migration و restore.

## Phase 24 — Security / Privacy
PIN، biometric، secure storage، app lock، encrypted data/backup و privacy mode.

## Phase 25 — Notifications
Todo، habit، Pomodoro، installment، debt، goal و reminder.

## Phase 26 — Global Search / Quick Actions
جست‌وجوی همه حوزه‌ها و عملیات سریع.

## Phase 27 — Dashboard
Greeting، تاریخ، وضعیت و خلاصه چهار حوزه.

## Phase 28 — UX Polish
Animation، transitions، skeleton، swipe، long press، haptic، keyboard و empty/error states.

## Phase 29 — QA / Performance
Unit، widget، integration، Android QA، performance و regression.

## Phase 30 — Release 1.0
APK/AAB، iOS، release notes، privacy، backup specification و documentation.

### قاعده اجرای فازها

هر فاز باید مستقل قابل بررسی و commit باشد. روند اجرا:

READ → INSPECT → COMPARE → PLAN → IMPLEMENT → TEST → FIX → REVIEW → COMMIT → PUSH/PR → REPORT
