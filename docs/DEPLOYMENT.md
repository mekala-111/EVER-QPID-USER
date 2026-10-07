# EverQpid — Production Deployment (Phase 12)

**Date:** 2026-07-21  
**Scope:** Validate Ubuntu + aaPanel + Nginx + HTTPS + Flutter Web. No UI / architecture / business-logic changes.  
**Related:** `docs/WEB_DEPLOYMENT.md` (PWA/Nginx detail), `docs/ENVIRONMENT.md`, `docs/SECURITY.md`, `docs/MONITORING.md`, `docs/TESTING.md`

### Phase 12 validation stamp (2026-07-21)

| Check | Result |
|-------|--------|
| `flutter build web --release --dart-define=ENV=production` | **Pass** — `✓ Built build/web` (~69 MB) |
| Required artifacts | **Pass** — index, main.dart.js, bootstrap, SW, manifest, version.json, assets/, canvaskit/, FCM SW, icons |
| Build warnings | Tree-shake icons (info); Wasm dry-run note from `socket_io_common` (not blocking JS build) |
| Active prod hosts | **Pass** — runtime defaults `https://server.everqpid.com` |
| Residual strings in JS | Dev IP / `localhost` may appear in bundle from `development.dart` + error copy — unused when `ENV=production` |
| Nginx reference config | `deploy/nginx/everqpid-web.conf` |
| Live aaPanel/browser lab | **Not executed in this phase** — use `RELEASE_CHECKLIST.md` on the VPS |

---

## 1. Release build validation

### Command

```bash
flutter clean
flutter pub get
flutter build web --release \
  --base-href=/ \
  --dart-define=ENV=production
```

Optional overrides:

```bash
flutter build web --release \
  --base-href=/ \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://server.everqpid.com \
  --dart-define=SOCKET_URL=https://server.everqpid.com \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_ID.apps.googleusercontent.com
```

Output: `build/web/` — deploy the **entire** tree.

### Expected artifacts

| Path | Required |
|------|----------|
| `index.html` | Yes |
| `main.dart.js` (or hashed JS) | Yes |
| `flutter_bootstrap.js` | Yes |
| `flutter_service_worker.js` | Yes (PWA) |
| `manifest.json` | Yes |
| `assets/` | Yes |
| `canvaskit/` | Yes (default renderer) |
| `icons/Icon-192.png`, `Icon-512.png`, maskable variants | Yes |
| `firebase-messaging-sw.js` | Yes (web push) |
| `version.json` | Present on recent Flutter |

### Production config check

| Check | Result |
|-------|--------|
| Default `ENV` | production (`AppConfig`) |
| API / Socket / Image | `https://server.everqpid.com` |
| Cleartext API in staging/prod | Blocked at network init |
| Localhost / LAN in prod defaults | None (dev-only in `development.dart`) |
| Path URLs | `usePathUrlStrategy()` in `main.dart` |
| Debug logging | `LoggerService` skips debug/info in release; errors still print + Crashlytics on mobile |

---

## 2. aaPanel + Nginx + SSL

### Steps

1. **Domain** — point `web.everqpid.com` A/AAAA to the Ubuntu VPS.  
2. **aaPanel** — create site for `web.everqpid.com`, document root = deploy folder (e.g. `/www/wwwroot/web.everqpid.com`).  
3. **SSL** — aaPanel → Site → SSL → Let’s Encrypt; force HTTPS. Confirm HTTP/2.  
4. **Nginx** — merge `deploy/nginx/everqpid-web.conf` into the site config (SPA `try_files`, cache rules, gzip/brotli, security headers).  
5. **Upload** — sync `build/web/*` into the site root (rsync/SFTP). Preserve `firebase-messaging-sw.js`.  
6. **Reload** — `nginx -t && nginx -s reload` (or aaPanel Reload).  
7. **CORS** — backend `https://server.everqpid.com` must allow origin `https://web.everqpid.com` (API + Socket.IO).  

### Cloudflare (optional)

| Setting | Recommendation |
|---------|----------------|
| Proxy (orange cloud) | OK; SSL mode **Full (strict)** |
| Cache | Bypass HTML / SW; or Page Rule: `index.html`, `flutter_service_worker.js`, `version.json` → Bypass |
| Miniify / Rocket Loader | Off for Flutter JS (can break) |
| Brotli | On (edge) in addition to origin gzip |

### Rollback

1. Keep previous `build/web` tarball: `everqpid-web-YYYYMMDD.tar.gz`.  
2. On failure: extract previous tarball over site root.  
3. Reload Nginx.  
4. Hard-refresh or clear SW (DevTools → Application → Clear storage) if clients stick on broken SW.  
5. Do **not** roll back SSL/Nginx SPA `try_files` unless the previous release also depended on it.

```bash
# Example rollback
cd /www/wwwroot
tar -xzf /backup/everqpid-web-PREV.tar.gz -C web.everqpid.com
nginx -t && nginx -s reload
```

---

## 3. Deep links / navigation validation

App uses **named routes** (`PPages` + `Routes.genericRoute`) with **path URL strategy**.

| Scenario | Expectation | Notes |
|----------|-------------|-------|
| Open `/` | App loads → splash | OK |
| In-app named navigation | Browser path may update to route name | OK when `pushNamed` used |
| Refresh on `/splash`, `/mainScreen`, `/login` | Nginx → `index.html` → Flutter restores route | Requires SPA `try_files` |
| Refresh on routes **with arguments** (`/chatScreen`, `/settingsScreen`, …) | Shell loads; **args lost** → incomplete screen | Known limitation — prefer re-entry from list |
| Browser Back / Forward | Navigator history | Smoke-test after deploy |
| Direct URL bookmark | Same as refresh | Argument routes not URL-encoded |

**Post-deploy smoke:** `/` → navigate → refresh → Back → Forward → open same URL in new tab.

---

## 4. Browser matrix

| Browser | Desktop | Mobile | Status |
|---------|---------|--------|--------|
| Chrome | Yes | Android Chrome | **Supported** |
| Edge (Chromium) | Yes | — | **Supported** |
| Firefox | Yes | Android Firefox | **Supported** |
| Safari | macOS recent | iPhone / iPad Safari | **Supported** (prefer latest) |

### Unsupported / limited features (not deploy bugs)

| Feature | Limitation |
|---------|------------|
| Audio recording (`record`) | Disabled on web |
| Razorpay | Mobile plugin; web payment UX limited / may be unavailable |
| Contacts | Limited / unavailable on web |
| Facebook App Events | Skipped on web |
| PWA install prompt | Chromium yes; Safari “Add to Home Screen” (different UX) |
| Push (FCM) | Needs `firebase-messaging-sw.js` + HTTPS + permission |
| Private Safari / ITP | Storage / Sign-In quirks — test Google Sign-In |
| CanvasKit | Needs WebAssembly + WebGL |

---

## 5. PWA review

| Item | Status |
|------|--------|
| `manifest.json` | name EverQpid, `standalone`, theme `#9B5DE5`, icons 192/512 + maskable |
| Icons | Present under `web/icons/` |
| Service worker | `flutter_service_worker.js` from release build |
| Update strategy | New build → new SW; keep `index.html` + SW **no-cache** so clients discover updates (often second visit) |
| Offline | Shell/assets may work offline; API/chat/socket need network |
| FCM SW | Keep `firebase-messaging-sw.js` beside Flutter SW |

---

## 6. Production environment review

| Item | Status |
|------|--------|
| HTTPS only (prod/staging API) | Enforced in `NetworkApiServiceV2` |
| Production ENV default | Yes |
| No localhost in prod defaults | Yes |
| Staging URL same host as prod API today | `server.everqpid.com` — OK if intentional; split hosts when staging differs |
| Debug logging | Release: no debug/info console spam; errors still `debugPrint` |
| Google client ID in `index.html` | Must match dart-define / console authorized origins |

---

## 7. Troubleshooting

| Symptom | Fix |
|---------|-----|
| Refresh 404 | SPA `try_files $uri $uri/ /index.html` |
| Stale UI after deploy | no-cache on `index.html` + SW; clear site data |
| White screen | Console errors; missing assets; CORS |
| Google Sign-In fail | Authorized JS origins + matching client ID |
| WASM MIME errors | `application/wasm` for `.wasm` |
| Wrong subdirectory | Rebuild with matching `--base-href` |
| Chat/settings blank after refresh | Argument routes — navigate from in-app lists |

---

## 8. Release checklist

Use root **`RELEASE_CHECKLIST.md`** for the full sign-off matrix (auth, uploads, payments, chat, etc.).

Quick gate before traffic:

- [ ] `flutter build web --release --dart-define=ENV=production` succeeded  
- [ ] Full `build/web/` deployed + FCM SW present  
- [ ] Nginx config from `deploy/nginx/everqpid-web.conf` applied  
- [ ] HTTPS + HTTP/2 verified  
- [ ] Deep link / refresh / back-forward smoke  
- [ ] Chrome + Safari mobile smoke  
- [ ] Rollback tarball stored  

---

## Pointers

- Web/PWA deep dive: `docs/WEB_DEPLOYMENT.md`  
- Env dart-defines: `docs/ENVIRONMENT.md`  
- Headers / tokens: `docs/SECURITY.md`  
- Crashlytics / Analytics: `docs/MONITORING.md`
