# Phase 5 — Code Cleanup Report

**Date:** 2026-07-21  
**Scope:** Dead code removal, naming cleanup, pubspec trim, light repository/logging hygiene.  
**Constraint:** Behavior unchanged. No UI redesign, widget splits, provider optimization, API/auth/business-logic changes.

---

## Summary

| Metric | Before (HEAD) | After | Delta |
|--------|---------------|-------|-------|
| Dart files under `lib/` | 193 | 178 | −15 tracked deletions (+ renames/adds) |
| Lines of code (`lib/**/*.dart`) | 46,680 | 37,479 | **−9,201** |
| Analyzer errors | — | **0** | — |
| Analyzer warnings | — | **0** | — |
| Analyzer infos | — | ~124 | mostly deprecations / async context |

Compile confirmed via `flutter analyze` (0 errors / 0 warnings). No intentional Android/Gradle config changes in this phase.

---

## 1. Files deleted

Confirmed unused / legacy (no remaining references):

### Data layer
- `lib/Data/LocaStorage/base_local_service.dart`
- `lib/Data/LocaStorage/localstorage_service.dart`
- `lib/Data/Network/network_api_service.dart` (legacy; V2 is sole client — Phase 4)
- `lib/Data/Response/AppResponse/api_response.dart`
- `lib/Data/Response/AppResponse/status.dart`
- `lib/Data/services/notification_api_service.dart` (commented stub)
- `lib/Data/services/permission_services.dart`
- `lib/env.dart` (empty; replaced by `lib/config/` in Phase 3)

### Settings / common widgets
- `lib/Settings/common/widgets/common_multy_popup_selector.dart`
- `lib/Settings/common/widgets/common_no_data_found.dart`
- `lib/Settings/common/widgets/common_popup_selector_widget.dart`
- `lib/Settings/common/widgets/custom_elevated_button.dart`
- `lib/Settings/common/widgets/custom_icon_elevated_button.dart`
- `lib/Settings/common/widgets/custom_outline_button.dart`
- `lib/Settings/common/widgets/custom_text_feild.dart`
- `lib/Settings/common/widgets/custom_textfeild_with_head.dart`
- `lib/Settings/common/widgets/errorMsg.dart`
- `lib/Settings/common/widgets/error_page.dart`
- `lib/Settings/common/widgets/loadingBar.dart`
- `lib/Settings/common/widgets/succesMsg.dart`
- `lib/Settings/helper/validator.dart`
- `lib/Settings/utils/svgs.dart`

### Features
- `lib/Features/common_widgets/subscription_blur_widget.dart` (empty)
- Dead private widgets/methods removed in-place (e.g. `_SocialButton` in onboarding, unused subscribe/logout dialogs, `_emptyGallery`)

---

## 2. Files renamed

| From | To | Notes |
|------|-----|--------|
| `lib/Data/LocaStorage/` | `lib/Data/LocalStorage/` | Typo fix; `loggedin_user.dart` retained |
| `lib/Settings/common/widgets/no_internet copy.dart` | `no_internet_screen.dart` | Routes updated |
| `lib/Features/home/repository/profile_repository.dart` | `home_profile_repository.dart` | Class → `HomeProfileRepository` |
| `lib/Features/home/model/user_profile_model.dart` | `discovery_profile_model.dart` | Types → `DiscoveryProfile` / `DiscoveryProfilesResponse` |

Profile feature keeps distinct `ProfileRepository` + `UserProfileModel` (different domain from home discovery).

---

## 3. Packages removed (`pubspec.yaml`)

| Package | Reason |
|---------|--------|
| `http` | Unused; Dio via `NetworkApiServiceV2` |
| `country_code_picker` | Unused |
| `change_app_package_name` | Dev/one-shot tool, not app runtime |

**Kept:** `socket_io_client`, `google_sign_in` (still referenced).

Verified with `flutter pub get` / `flutter analyze`.

---

## 4. Commented / legacy code stripped

Large comment blocks removed from screens and view-models (preferences, edit profile, subscription, support, clan list, onboarding, matches subscribe stubs, other-profile gallery stub, etc.). Git history retains prior implementations.

Approximate comment-line reduction from earlier Phase 5 pass: ~6.5k non-doc `//` lines across large files, plus additional dead methods after strip.

---

## 5. Repository / network hygiene

- Repos continue to use shared `NetworkApiServiceV2.instance` (Phase 4).
- Light simplification of matches / FCM / matching repositories (less local boilerplate where already covered by network layer).
- Repositories still map models and return results; no API contract changes.

---

## 6. Logging

- Added `lib/Settings/helper/app_logger.dart` (`AppLogger.d` / `AppLogger.e`).
- Replaced scattered `print` / `debugPrint` in feature code and notification helper with `AppLogger`.
- Network logging remains in `network_logger.dart` (Phase 4).
- Some `dart:developer` `log()` calls remain in view-models (auth, messages, chat) — debt listed below.

---

## 7. Analyzer improvements

| Check | Result |
|-------|--------|
| `dart format lib` | Applied |
| `dart fix --apply` | Nothing remaining |
| `flutter analyze` | **0 errors, 0 warnings** |
| Remaining infos | ~124 (deprecated `withOpacity` / `WillPopScope`, `use_build_context_synchronously`, style infos) |

Fixes of note this close-out:
- Removed broken unused `_SocialButton` (uninitialized fields → analyzer error).
- Removed unused private APIs flagged as warnings.
- Fixed duplicate map key `"Ice Hockey"` in `edit_interests_screen.dart`.

---

## 8. Remaining technical debt (out of Phase 5 scope)

Deferred to later phases (do **not** treat as Phase 5 failures):

1. **Phase 6** — Mixed `Features/` vs `features/` import casing.
2. **Phase 7** — Large files still >500 lines (screens/VMs).
3. **Phase 8** — Global provider list / optimization.
4. Remaining `dart:developer` `log()` in auth/messages/chat VMs → migrate fully to `AppLogger`.
5. Deprecated APIs (`withOpacity` → `withValues`, `WillPopScope` → `PopScope`).
6. `use_build_context_synchronously` infos in splash / FCM / no-internet.
7. Unused scroll-to-bottom flag in chat still hard-coded `false` (behavior preserved; wiring is incomplete product work, not dead-file cleanup).
8. Google Sign-In UI path was already commented out on onboarding; dead `_SocialButton` removed — product may still want social buttons later.

---

## Success criteria

| Criterion | Status |
|-----------|--------|
| Dead code removed | ✓ |
| Duplicate / copy files removed | ✓ |
| No commented implementations left in cleaned files | ✓ (major surfaces) |
| Cleaner repositories | ✓ (light) |
| pubspec cleaned | ✓ |
| Naming improved | ✓ |
| Behavior unchanged | ✓ (no API/UI/auth redesign) |
| Zero analyzer errors | ✓ |
| Zero analyzer warnings | ✓ |

**Phase 5 complete. Do not start Phase 6 until explicitly requested.**
