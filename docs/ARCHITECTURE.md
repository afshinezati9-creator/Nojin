# NOJÎN — Architecture Baseline

## هدف

NOJÎN به‌صورت Native Flutter ساخته می‌شود. Golden Reference رفتار و ظاهر را مشخص می‌کند؛ معماری کد باید مستقل، تست‌پذیر و قابل نگهداری باشد.

## لایه‌ها

```
UI / Presentation
        ↓
State Management
        ↓
Use Cases / Domain
        ↓
Repositories
        ↓
Local Data / Services
```

## ساختار هدف

```
lib/
  app/
  core/
  features/
    notes/
    finance/
    planning/
    info/
  shared/
  main.dart
```

## Coreهای ایران

`IranLocalization`
`IranNumber`
`IranMoney`
`IranDate`
`IranCalendar`
`IranPhone`
`IranBank`
`IranAddress`
`IranHoliday`

## داده

محصول باید local-first باشد و Repository abstraction داشته باشد تا دیتابیس، migration، backup/restore و در آینده sync بدون وابستگی UI قابل تغییر باشند.

## امنیت

اطلاعات حساس باید از ابتدا با درنظرگرفتن secure storage، app lock، biometric، clipboard protection و backup امن طراحی شوند.

## UI

Design Tokenها، Typography، Spacing، Radius، Shadow، Gradient، Icon و Componentها باید متمرکز باشند تا ظاهر همه صفحات با Golden Reference هم‌راستا بماند.

## قاعده تغییر

هر Feature جدید باید:

1. با Golden Reference مقایسه شود.
2. از Coreهای ایران استفاده کند.
3. state و persistence مشخص داشته باشد.
4. تست مناسب داشته باشد.
5. به‌صورت مستقل قابل commit باشد.
