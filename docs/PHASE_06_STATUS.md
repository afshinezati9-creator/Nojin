# NOJÎN — Phase 06 Status

## Responsive / Adaptive

Phase 06 centralizes responsive behavior so the same Flutter UI adapts to phone, tablet, desktop and landscape window sizes.

### Breakpoints

NojinBreakpoints is the single source for width decisions:

- compact: < 600px
- medium: 600–839px
- expanded: >= 840px
- wide: >= 1200px

These are width-based rather than device-name-based, so browser resizing and landscape layouts use the same rules.

### App Shell

- Compact widths use the bottom NavigationBar.
- Medium/expanded widths use NavigationRail.
- Wide layouts use an extended rail treatment.
- Navigation icons remain on the centralized SVG system from Phase 05.
- No domain-specific feature logic was added.

### Home

- 1-column compact layout.
- 2-column medium layout.
- 3-column expanded layout.
- 4-column wide layout.
- Page padding scales by available width.
- Wide content is bounded to prevent excessively long reading/card rows.
- Card text is protected against narrow-width overflow.

### Scope boundary

This phase establishes responsive infrastructure and applies it to the current shared Shell/Home surfaces. Domain pages remain placeholders until their feature phases.

### Verification

- Breakpoint, grid and max-width rules have unit coverage.
- SVG icon usage remains centralized.
- No GitHub Actions/CI workflow was introduced.
- Flutter runtime/analyzer execution must be performed in the user's local Flutter environment because this execution environment cannot run the repository's Flutter toolchain.
