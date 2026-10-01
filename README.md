# NOJÎN / نوژین

زندگی نو، تولد دوباره.

NOJÎN یک LifeOS ایرانی، موبایل‌محور و offline-first است که چهار حوزه Notes، Finance، Planning و Info را در یک تجربه فارسی/RTL یکپارچه جمع می‌کند.

## Phase 01 — Flutter Foundation

این فاز اسکلت Native Flutter محصول را فراهم می‌کند:

- Material 3 و RTL فارسی
- GoRouter برای routing
- Riverpod برای state management و DI پایه
- Theme متمرکز با پالت آبی/بنفش Golden Reference
- Error boundary و صفحه خطای قابل بازیابی
- Logging متمرکز
- Service container پایه
- چهار route اولیه برای Notes، Finance، Planning و Info
- تست smoke برای boot و shell اصلی

## منبع طراحی

مرجع رسمی UI/UX در:
`reference/nozhin_pwa_demo.html`

مستندات محصول و معماری در:
- `docs/NOJIN_BIBLE.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`

## اجرا

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

HTML مرجع منبع طراحی و رفتار است؛ محصول نهایی Native Flutter خواهد بود.
