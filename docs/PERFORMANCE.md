# Phase 7 — Performance Optimization

**Date:** 2026-07-21  
**Scope:** Runtime performance only — images, scrolling, rebuild isolation, startup.  
**Constraint:** No UI redesign, no large-file splits, no API/auth/network changes.

---

## Before → After

| Metric | Before | After |
|--------|--------|-------|
| `Image.network` call sites | 9+ | **0** |
| `CachedNetworkImage` / `AppNetworkImage` | 0 | **shared widget + ~25 usages** |
| `RepaintBoundary` on hot lists/cards | 0 | **6+** |
| `cacheExtent` on builders | 0 | **8** |
| Discovery swipe drag rebuilds | `setState` every pan update | `ValueListenableBuilder` (card body cached) |
| Facebook analytics on `main()` | Sync before `runApp` | **After first frame** |
| Image cache cap | Flutter default | **100 images / 50 MB** |
| Analyzer errors / warnings | 0 / 0 | **0 / 0** |

---

## Performance improvements

1. **Network images** — added `cached_network_image` and [`AppNetworkImage`](lib/Settings/common/widgets/app_network_image.dart) with placeholder, error widget, fade, and `memCacheWidth` decode sizing. Replaced discovery, matches, likes, chat, clan, profile, and verification network image paths.
2. **Scrolling** — `cacheExtent` on matches/likes grids, chat message list, messages list, clan horizontal list, contacts list, recent passes / your likes grids. `RepaintBoundary` around match cards, chat bubbles, chat tiles, clan member cards.
3. **Animations** — home discovery swipe no longer `setState`s the full card on every drag delta; transform/indicators listen via `ValueListenableBuilder` while heavy scroll content is the `child`.
4. **Startup** — Facebook install event deferred to post-frame; Flutter image cache capped to reduce peak memory.
5. **Const / fix** — `dart format` + `dart fix --apply` (nothing remaining beyond existing infos).

---

## Widgets optimized

| Area | Change |
|------|--------|
| Home discovery card | Cached images + RepaintBoundary on hero image + ValueListenableBuilder swipe |
| Match / like grids | `AppNetworkImage`, `cacheExtent`, `RepaintBoundary` |
| Recent passes / Your likes | Cached images + `cacheExtent` |
| Chat messages | Cached media, `cacheExtent`, `RepaintBoundary` per bubble |
| Messages list | Cached avatars, `cacheExtent`, `RepaintBoundary` per tile |
| Clan home / list | Cached images + horizontal list `cacheExtent` / `RepaintBoundary` |
| Profile / verify / other profile | Cached avatar / decoration images |
| Full-screen image viewer | Cached contain fit |

---

## Startup improvements

- Non-critical Facebook analytics no longer blocks `runApp`.
- Shell/feature providers remain lazy (Phase 6) — Support / Contacts / Subscription still not constructed at splash.
- Image decode memory bounded early via `PaintingBinding.instance.imageCache`.

---

## Remaining hotspots

- Large `build()` methods in home / edit-profile / preferences (file split is Phase 8+, not this phase).
- Chat list still rebuilds on every `ChatViewModel.notifyListeners` for message appends — needs VM-level listenable split later.
- `withOpacity` / `WillPopScope` deprecation infos.
- Nested `SingleChildScrollView` inside discovery card remains (product UX); further isolation would need layout redesign.

---

## Compile confirmation

`dart format lib` · `dart fix --apply` · `flutter analyze` → **0 errors, 0 warnings**.

**Phase 7 complete. Do not start Phase 8 until requested.**
