# EverQpid Customer — Responsiveness Analysis

**Scope:** Flutter customer app (`lib/`), with emphasis on width-driven layout tiers for mobile, tablet, and desktop/web.  
**Date:** 2026-07-27  
**Source of truth:** `lib/Settings/responsive/` + feature `desktop/` / `tablet/` forks

---

## 1. Verdict

The app has a **real, width-based responsive system** (not `kIsWeb`-gated chrome). Authenticated navigation forks correctly into bottom-nav (mobile) vs sidebar shell (tablet/desktop). Most primary tabs and settings/profile flows have dedicated desktop layouts. Gaps remain: **unused spacing helpers**, **parallel breakpoint constants** (especially Welcome/onboarding at 900 / 1100), and **incomplete adoption** of shared max-width / column helpers on some secondary screens.

| Area | Status |
|------|--------|
| Core breakpoints API | Solid |
| Main shell (nav) | Solid — 3-tier |
| Primary tabs (Home, Matches, Messages, Profile, Clan) | Mostly solid |
| Settings / subscription / edit subpages | Solid via `ProfileEditResponsive` |
| Onboarding forms | Parametric (`AppContentFrame`) + some web shells |
| Welcome marketing | Custom breakpoints (diverges from app tiers) |
| Shared spacing (`AppSpacing`) | Defined, **unused** |
| Automated responsive tests | Minimal |

---

## 2. Architecture overview

```
┌─────────────────────────────────────────────────────────────┐
│  Window / parent width (LayoutBuilder or MediaQuery)        │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│  breakpointOf(width) → AppBreakpoint { mobile | tablet |    │
│                                         desktop }           │
│  mobile  < 768                                              │
│  tablet  768–1199                                           │
│  desktop ≥ 1200                                             │
└────────────────────────────┬────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
 ResponsiveBuilder    AppContentFrame      Parametric helpers
 (full UI forks)      (center + maxWidth)  profileGridColumns
 ProfileEditResponsive                     photoSlotColumns
 MainScreen shell                          AppSpacing (unused)
```

**Design rule (encoded in code comments):** prefer parametric changes (columns, max width) over full tree forks; use `ResponsiveBuilder` / desktop views only when the layout truly differs.

**Platform rule:** tiers are driven by **logical width**, not `kIsWeb`. A narrow browser window is mobile; a wide phone/tablet window can hit tablet/desktop.

---

## 3. Core module — `lib/Settings/responsive/`

| File | Role |
|------|------|
| `breakpoints.dart` | `AppBreakpoint`, `Breakpoints`, `breakpointOf`, `BreakpointContext`, grid helpers |
| `responsive_builder.dart` | `ResponsiveBuilder` — mobile required; tablet/desktop optional fallbacks |
| `content_max_width.dart` | Named max-width constants (dp) |
| `app_content_frame.dart` | Centers/caps content on tablet+; passthrough on mobile |
| `app_spacing.dart` | Page horizontal insets by tier — **not referenced anywhere yet** |

### 3.1 Breakpoints

```dart
// lib/Settings/responsive/breakpoints.dart
mobileMax  = 768   // width < 768  → mobile
tabletMax  = 1200  // 768 ≤ width < 1200 → tablet
               // width ≥ 1200 → desktop
```

**Context helpers:**

| Getter | Meaning |
|--------|---------|
| `context.bp` | Current `AppBreakpoint` from `MediaQuery.sizeOf` width |
| `context.isMobile` / `isTablet` / `isDesktop` | Equality checks |
| `context.screenSize` | `MediaQuery.sizeOf(this)` |

**Important:** `MainScreen`, `ProfileEditResponsive`, and several screens use **`LayoutBuilder` constraints** (`breakpointOf(constraints.maxWidth)`) so nested shells do not mis-classify when the available width is less than the full window (e.g. beside a sidebar). Prefer that pattern inside shells; `MediaQuery`-based `context.bp` is fine for top-level pages.

### 3.2 `ResponsiveBuilder`

Fallback chain:

| Tier | Widget used |
|------|-------------|
| Desktop | `desktop ?? tablet ?? mobile` |
| Tablet | `tablet ?? mobile` |
| Mobile | `mobile` |

Only the active builder runs (good for performance vs building all three trees).

### 3.3 `AppContentFrame`

- **Mobile:** returns `child` unchanged (no padding/centering).
- **Tablet/desktop:** `LayoutBuilder` + horizontal insets so content width = `min(maxWidth, available)`.
- Uses **parent constraints**, not full window width — critical inside rails/shells.
- Must **not** be placed *inside* an `IntrinsicHeight` (documented constraint).

> Doc comment in `app_content_frame.dart` still says “width &lt; 600”; implementation uses `context.isMobile` (**768**). Treat 768 as truth; update the comment when touching that file.

### 3.4 `ContentMaxWidth` constants

| Constant | Value | Intended use |
|----------|------:|--------------|
| `form` | 480 | Auth, settings, single-column forms |
| `homeCard` | 480 | Discover swipe card (out of shell) |
| `chat` | 800 | Chat thread column |
| `list` | 840 | Inbox / similar lists |
| `tabletShell` | 840 | Tablet shell around main tabs |
| `shell` | 1280 | Desktop shell / wide grids (default for `AppContentFrame`) |

### 3.5 Grid helpers

| Helper | Mobile | Tablet | Desktop |
|--------|--------|--------|---------|
| `profileGridColumns` | 2 | 3 | 4 |
| `photoSlotColumns` | 2 | 2 | 4 (one row) |

Used in matches, likes, recent passes, clan list, photo upload / edit profile / profile intro.

### 3.6 `AppSpacing` (dead API today)

| Tier | Horizontal page inset |
|------|----------------------:|
| Mobile | 16 |
| Tablet | 24 |
| Desktop | 32 |

No call sites under `lib/` as of this analysis. Screens still hardcode 16/20/24 padding.

---

## 4. App chrome — `MainScreen`

File: `lib/Features/mainscreen/view/main_screen.dart`

| Breakpoint | Chrome |
|------------|--------|
| **Mobile** | `Scaffold` + bottom navigation; tab body only |
| **Tablet** | `_webShell` with **collapsible** `DesktopSidebar` + `DesktopContentTopBar` |
| **Desktop** | `_webShell` with **expanded** sidebar (collapse toggle not used) |

Shell layout:

```
[ DesktopSidebar ] [ DesktopContentTopBar ]
                   [ IndexedStack / tab content ]
```

Background / branding for web shell lives in `_webShell` (dark chrome). Home and other tabs adapt colors when `!context.isMobile` (“in shell”).

---

## 5. Feature coverage matrix

### 5.1 Primary tabs

| Screen | Mobile | Tablet | Desktop | Mechanism |
|--------|--------|--------|---------|-----------|
| **Home** (`home_screen.dart`) | White scaffold + header + card | Shell: transparent bg, capped card, web discover variants | Same as tablet | `context.isMobile` + `AppContentFrame` + `home_web_discover` |
| **Matches** | `_MobileMatchesBody` + grids | `DesktopMatchesView` | `DesktopMatchesView` | `ResponsiveBuilder` |
| **Messages** | Mobile inbox + `AppContentFrame(list)` | `DesktopMessagesView` (split pane) | Same | `ResponsiveBuilder` |
| **Profile** | `MobileProfileView` | `TabletProfileView` | `DesktopProfileView` | `ResponsiveBuilder` (true 3-way) |
| **Clan** | Centered “coming soon” art | `DesktopClanView` | `DesktopClanView` | `!context.isMobile` |

### 5.2 Messages / chat

| Screen | Behavior |
|--------|----------|
| Inbox | Mobile list; tablet+ desktop master–detail view |
| `ChatScreen` | `AppContentFrame(maxWidth: chat)` when not in a special desktop path |

### 5.3 Profile & settings subpages

Shared wrapper: **`ProfileEditResponsive`** (`desktop_edit_subpage_shell.dart`)

- Mobile → `mobile` builder only  
- Tablet/desktop → `DesktopEditSubpageShell` (sidebar + top bar) wrapping `desktop` builder; tablet starts **collapsed**

Used by (among others):

- Settings, Support, Hide contacts  
- Subscription  
- Edit profile / preferences / related edit flows (via same pattern or direct `LayoutBuilder`)

| Screen | Mobile | Wide |
|--------|--------|------|
| Settings | List + `AppContentFrame(form)` | `DesktopSettingsView` in shell |
| Delete account | Full-screen page | `showWebDeleteAccountDialog` modal |
| Subscription | Mobile plans UI | `DesktopSubscriptionView` in shell |
| Blocked users | List | Desktop view / shell when non-mobile |
| Preferences / edit profile | Forms + `AppContentFrame` / photo grids | Desktop views + `photoSlotColumns` |

### 5.4 Onboarding / auth

| Flow | Responsive approach |
|------|---------------------|
| Phone / email login, OTP, gender, looking-for, name/DOB, permissions | `AppContentFrame(maxWidth: form)` — same tree, capped on wide |
| Photo upload / profile intro | Form frame + `photoSlotColumns` |
| Profile intro | Branches on `context.isMobile` for web vs mobile chrome |
| **Welcome** | Separate marketing system — see §6 |
| **Web onboarding shell** | `WebOnboardingShell` — own widths (768 / 1100), glass card |

### 5.5 Desktop / tablet view inventory

Under `lib/Features/**/view/desktop/` (and welcome desktop):

| Feature | Desktop (and shared wide) files |
|---------|---------------------------------|
| Main | `desktop_sidebar.dart` (+ top bar) |
| Matches | `desktop_matches_view.dart` |
| Messages | `desktop_messages_view.dart` |
| Profile | `desktop_profile_view.dart`, `desktop_edit_profile_view.dart`, `desktop_preferences_view.dart`, `desktop_recent_passes_view.dart`, `desktop_safety_tips_view.dart`, `desktop_form_controls.dart`, `desktop_edit_subpage_shell.dart` |
| Profile (tablet) | `tablet/tablet_profile_view.dart` |
| Settings | `desktop_settings_view.dart`, `desktop_support_view.dart`, `desktop_hide_contacts_view.dart`, `web_delete_account_dialog.dart` |
| Subscription | `desktop_subscription_view.dart` |
| Clan | `desktop_clan_view.dart` |
| Profile actions | `desktop_blocked_users_view.dart`, `web_report_account_dialog.dart` |
| Onboarding | `web_onboarding_shell.dart`, welcome web layouts |

---

## 6. Parallel breakpoint systems (inconsistency)

The **authenticated app** standard is **768 / 1200**. Marketing and some onboarding UI use **different** thresholds:

| Location | Thresholds | Notes |
|----------|------------|-------|
| `Breakpoints` | 768, 1200 | Canonical for app chrome |
| `WelcomeTheme.desktopBreakpoint` | **900** | Auth dialogs / wide welcome actions (`kIsWeb && wide`) |
| `WelcomeTheme.horizontalPad` | 768, 1200 | Aligns with app for padding only |
| `welcome_web_view.dart` | **900** | Hero stacks when `width < 900` |
| `WebOnboardingShell` | **768**, **1100** | Card width / two-column tagline |

**Impact:** Between 900–1199px a user can be “desktop” for welcome CTAs but “tablet” for `MainScreen`, or “wide” for onboarding shell at ≥1100 while still tablet until 1200. Not necessarily broken, but harder to reason about and test.

**Recommendation:** Gradually converge welcome/onboarding to `Breakpoints.mobileMax` / `tabletMax`, or document Welcome as a deliberate marketing exception with a short comment linking to this doc.

---

## 7. Patterns to copy (when adding screens)

### Prefer parametric (one tree)

```dart
Scaffold(
  body: AppContentFrame(
    maxWidth: ContentMaxWidth.form,
    child: /* existing mobile layout */,
  ),
);
```

### Full fork (rare)

```dart
return ResponsiveBuilder(
  mobile: (_) => const MobileFooView(),
  tablet: (_) => const DesktopFooView(),  // optional
  desktop: (_) => const DesktopFooView(),
);
```

### Authenticated subpage with sidebar

```dart
return ProfileEditResponsive(
  mobile: (_) => /* mobile scaffold */,
  desktop: (_) => /* desktop panel content only */,
);
```

### Inside shell / beside rail

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final bp = breakpointOf(constraints.maxWidth);
    // ...
  },
);
```

Do **not** introduce new magic numbers (900, 1100, 600) without aligning to `Breakpoints`.

---

## 8. Gaps & risks

| # | Gap | Severity | Notes |
|---|-----|----------|-------|
| 1 | `AppSpacing` unused | Low | Dead API; either adopt on refactors or delete |
| 2 | Welcome / onboarding breakpoint drift | Medium | 900 / 1100 vs 768 / 1200 |
| 3 | `AppContentFrame` comment says 600 | Low | Doc drift only |
| 4 | Clan list / some secondary lists | Low–Med | `profileGridColumns` used in places; verify every grid screen |
| 5 | `kIsWeb` still used in welcome actions / home | Low | Platform gate on top of width — intentional for web-only dialogs |
| 6 | Orientation / foldables | Not handled | Width-only; landscape phone may hit tablet chrome |
| 7 | Automated tests | Low | Almost no breakpoint matrix tests (`welcome_theme_test` checks 900 only) |
| 8 | Hardcoded paddings | Low | Screens keep 16/20/24; inconsistent with unused `AppSpacing` |

### Landscape phone caveat

A phone in landscape often exceeds **768** logical width → `MainScreen` switches to **sidebar shell**. That may be desired for web-like tablets, but on phones it can surprise users. Mitigations (if product wants them): also consider `shortestSide`, or raise mobile max for touch devices only — not implemented today.

---

## 9. Suggested test matrix

Manual / golden / widget tests should cover at least these widths:

| Label | Width (dp) | Expected tier | Expected chrome |
|-------|------------|---------------|-----------------|
| Phone | 390 | Mobile | Bottom nav |
| Large phone / small tablet | 760 | Mobile | Bottom nav |
| Tablet | 900 | Tablet | Collapsible sidebar |
| Desktop edge | 1200 | Desktop | Expanded sidebar |
| Ultrawide | 1600 | Desktop | Content capped by `ContentMaxWidth` |

**Flows to spot-check at each tier:** Welcome → login → main tabs → Matches grids → Messages open chat → Profile → Settings → Subscription → Delete account (modal vs page).

---

## 10. File map (quick reference)

```
lib/Settings/responsive/
  breakpoints.dart          # tiers + context + grid helpers
  responsive_builder.dart   # mobile/tablet/desktop widget switch
  content_max_width.dart    # named max widths
  app_content_frame.dart    # center + cap on tablet+
  app_spacing.dart          # page insets (unused)

lib/Features/mainscreen/view/
  main_screen.dart          # shell fork
  widgets/desktop_sidebar.dart

lib/Features/*/view/desktop/   # feature desktop UIs
lib/Features/profile/view/tablet/
lib/Features/onboarding/view/desktop/web_onboarding_shell.dart
lib/Features/onboarding/view/welcome/  # marketing-responsive (own breakpoints)
```

---

## 11. Summary checklist for new UI

- [ ] Use `breakpointOf` / `context.bp` — do not invent new cutoffs  
- [ ] Prefer `AppContentFrame` + `ContentMaxWidth.*` over custom `ConstrainedBox`  
- [ ] Prefer column helpers over hardcoding `crossAxisCount`  
- [ ] Fork with `ResponsiveBuilder` or `ProfileEditResponsive` only when layout differs  
- [ ] Inside rails, classify with **parent** `LayoutBuilder` width  
- [ ] Keep mobile visual parity (frame passthrough; don’t “improve” mobile padding casually)  
- [ ] If touching Welcome, decide whether to stay on 900 or migrate to 768/1200  

---

*Generated from codebase analysis of `lib/Settings/responsive/` and feature call sites. Re-run graphify / grep after large layout PRs to keep this doc accurate.*
