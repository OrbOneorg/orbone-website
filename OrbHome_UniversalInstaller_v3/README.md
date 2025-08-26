# OrbHome Universal Installer v3 (Store‑free, One‑Button, APK Fallback)

**What’s new vs v2**
- One‑button flow with visible progress.
- Automatic **PWA install** on Android/Chromium where available.
- If install prompt is unavailable, shows a safe **APK fallback button** (optional link).
- iOS gets a clean **2‑tap overlay** (Apple requirement).
- Offline-first, resilient caching, tiny payload.

## Quick Start (Local Proof on Nitro 5)
1) Unzip anywhere (Desktop is fine).
2) Double‑click `index.html` → Click **Enter My Orb**.
3) (Android/Chrome) Click **Install App** → accept OS prompt.
4) (Optional) Set `APK_FALLBACK_URL` in `app.js` to your hosted APK link.

## Put it online (for everyone)
- Drag the whole folder to Cloudflare Pages / Netlify.
- (Optional) Edit `app.js` → set `const ORB_URL` to your live Orb URL.
- Visit the public link and share it. Use `qr.html` to print QR codes.

(c) OrbOne / Universal Installer v3