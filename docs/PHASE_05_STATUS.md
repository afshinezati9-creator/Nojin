# NOJÎN — Phase 05 Status

## SVG Icon System

Phase 05 establishes the centralized, reusable icon layer for NOJÎN.

### Decisions

- Icons are SVG assets, not emoji.
- Feature UI should consume NojinIconName rather than hard-code asset paths.
- NojinIcon owns rendering, sizing and optional color treatment.
- NojinIconButton standardizes icon-only actions and Persian tooltips.
- SVG assets live under assets/icons/ and are registered once in pubspec.yaml.
- Icons are intentionally simple vector artwork so the same visual language can be reused across mobile, tablet and desktop layouts.
- The system is RTL-safe because direction is controlled by the surrounding Flutter UI rather than by icon mirroring.

### Included foundation icons

home, notes, finance, planning, info, search, sparkle.

### Usage

Use NojinIcon(NojinIconName.notes) or NojinIconButton(icon: NojinIconName.search, onPressed: ...).

Do not introduce direct Icons.* usage for NOJÎN product icons in new feature UI.

### Scope boundary

This phase does not implement Notes, Finance, Planning or Info functionality. It only replaces the shared shell/home icon dependency and establishes the reusable icon API.

### Verification

The icon registry has unit coverage for asset mapping and Persian labels. The Flutter project remains free of GitHub Actions/CI changes by product decision.
