# EverQpid — Production Release Checklist

**Product:** EverQpid Customer (Flutter Web + Mobile)  
**Phase:** 12 — Production Deployment Validation  
**Date:** _______________  
**Build / commit:** _______________  
**Deployed by:** _______________  

Mark each item **Pass / Fail / N/A** after smoke on **production** (`ENV=production`, HTTPS).

---

## Pre-deploy

| # | Check | Result |
|---|--------|--------|
| 1 | `flutter build web --release --dart-define=ENV=production` succeeds | |
| 2 | No missing assets in `build/web/` (icons, canvaskit, SW, manifest) | |
| 3 | Previous release tarball saved for rollback | |
| 4 | Nginx config includes SPA `try_files` + no-cache shell/SW | |
| 5 | SSL valid (Let’s Encrypt / Cloudflare Full strict) | |
| 6 | Backend CORS allows `https://web.everqpid.com` | |
| 7 | Firebase Auth authorized domains include production host | |
| 8 | Google Sign-In JS origins match production host + `index.html` client ID | |

---

## Authentication

| # | Check | Result |
|---|--------|--------|
| 1 | Phone login UI loads | |
| 2 | OTP send / verify (or known test numbers) | |
| 3 | Email OTP path (if enabled) | |
| 4 | Google Sign-In (web) | |
| 5 | Session persists across refresh (tokens) | |
| 6 | Logout clears session; cannot access main without re-auth | |
| 7 | Token refresh after expiry (or forced 401) | |

---

## Profile

| # | Check | Result |
|---|--------|--------|
| 1 | Load own profile | |
| 2 | Edit bio / about / interests | |
| 3 | Photo upload (JPEG/PNG within size limits) | |
| 4 | Reject oversized / invalid upload client-side | |

---

## Discovery / Home

| # | Check | Result |
|---|--------|--------|
| 1 | Discovery profiles load | |
| 2 | Like / unlike | |
| 3 | Match flow / Its-a-match | |
| 4 | Empty / error / retry states | |

---

## Matches

| # | Check | Result |
|---|--------|--------|
| 1 | Matches list loads | |
| 2 | Open match profile | |
| 3 | Navigate to chat from match | |

---

## Messages / Chat

| # | Check | Result |
|---|--------|--------|
| 1 | Recent chats list | |
| 2 | Open thread; history loads | |
| 3 | Send text message | |
| 4 | Socket reconnect after brief offline | |
| 5 | Media send (if enabled on web) | |

---

## Uploads

| # | Check | Result |
|---|--------|--------|
| 1 | Profile photos via signed URL | |
| 2 | Verification selfie upload | |
| 3 | Chat media (if enabled) | |
| 4 | HTTPS only to S3 / CDN | |

---

## Subscription / Payments

| # | Check | Result |
|---|--------|--------|
| 1 | Plans list loads | |
| 2 | Subscribe CTA / checkout | |
| 3 | Razorpay — **mobile preferred**; note web limitation if N/A | |
| 4 | Manage subscription screen | |

---

## Notifications

| # | Check | Result |
|---|--------|--------|
| 1 | FCM permission prompt (supported browsers) | |
| 2 | Foreground / background notification smoke | |
| 3 | `firebase-messaging-sw.js` present on host | |
| 4 | No FCM tokens in logs | |

---

## Verification

| # | Check | Result |
|---|--------|--------|
| 1 | Intro → capture → upload | |
| 2 | Result / status screen | |

---

## Clan

| # | Check | Result |
|---|--------|--------|
| 1 | Clan list / location profiles (if subscribed) | |
| 2 | Paywall / subscribe gate | |

---

## Settings

| # | Check | Result |
|---|--------|--------|
| 1 | Settings screen loads | |
| 2 | Privacy / terms WebViews | |
| 3 | Support / contact | |
| 4 | Delete account (staging preferred first) | |
| 5 | Hide contacts (web may be limited) | |

---

## Performance

| # | Check | Result |
|---|--------|--------|
| 1 | First paint / startup shell visible then Flutter frame | |
| 2 | Discovery scroll acceptable on mid-tier mobile | |
| 3 | Assets served with long-cache; `index.html` no-cache | |
| 4 | HTTP/2 enabled | |
| 5 | gzip and/or brotli on | |

---

## Security

| # | Check | Result |
|---|--------|--------|
| 1 | Site only on HTTPS | |
| 2 | API base is `https://` (no localhost / LAN in prod build) | |
| 3 | Security headers present (HSTS, nosniff, frame deny, referrer) | |
| 4 | Tokens not in `localStorage` on web (memory / secure path) | |
| 5 | No OTP / JWT in console logs | |

---

## Monitoring

| # | Check | Result |
|---|--------|--------|
| 1 | Crashlytics receives a test non-fatal (mobile) | |
| 2 | Analytics events for login / match / logout (Firebase DebugView) | |
| 3 | Known error path does not crash the tab | |

---

## Browser matrix

| Browser | Pass | Notes |
|---------|------|-------|
| Chrome (desktop) | | |
| Edge (desktop) | | |
| Firefox (desktop) | | |
| Safari (macOS) | | |
| Android Chrome | | |
| iPhone Safari | | |

---

## Navigation / SPA

| # | Check | Result |
|---|--------|--------|
| 1 | Deep link / refresh on `/` and `/splash` | |
| 2 | Refresh on `/mainScreen` | |
| 3 | Browser Back / Forward | |
| 4 | Direct URL open in new tab | |
| 5 | Argument routes after refresh (expect limited — documented) | |

---

## PWA

| # | Check | Result |
|---|--------|--------|
| 1 | Manifest valid; icons show | |
| 2 | Install / Add to Home Screen (Chromium / iOS) | |
| 3 | Offline: shell loads; API fails gracefully | |
| 4 | After redeploy, SW updates (second visit OK) | |

---

## Sign-off

| Role | Name | Date | Ready for production? |
|------|------|------|------------------------|
| Engineering | | | Yes / No |
| QA | | | Yes / No |
| Product | | | Yes / No |

**Blockers (if any):**

_________________________________________________________________

**Rollback plan acknowledged:** Yes / No  

Docs: `docs/DEPLOYMENT.md` · `deploy/nginx/everqpid-web.conf` · `docs/WEB_DEPLOYMENT.md`
