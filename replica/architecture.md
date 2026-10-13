# Daylit — architecture

## Stack

| Layer | Choice | Why |
| --- | --- | --- |
| App | Swift 5.9+, AppKit menu bar (LSApplication) | Native, tiny binary, no Electron |
| Build | SwiftPM + `scripts/package-app.sh` | No Xcode project required for CLI build |
| Brightness (licensed) | Public `CAMetalLayer` 1×1 EDR primer + `CGSetDisplayTransferByTable` | Lowest resource: one Metal present, one gamma write |
| Brightness (free half) | Half-screen click-through window, multiply + EDR, ~2 Hz keepalive | Only free mode pays a small GPU tax; licensed path stays idle |
| Persistence | UserDefaults | No server for MVP |
| Payments | Local license string MVP; Stripe / Paddle later | Match MacBrightness one-time model without blocking ship |
| Hosting | Direct .app zip | App Store later if needed |

No database. No network required for core boost.

## Risk bits

- Sleep/wake clears gamma → observe `NSWorkspace` / display reconfig and re-apply.
- Gamma without EDR clamps → always pair with primer.
- Continuous fullscreen Metal overlays burn GPU → never use that for licensed mode.
- Half-screen free mode must ignore mouse and sit above content without stealing focus.

## Build order

1. Vertical slice: primer + gamma on/off from menu (M3 Max XDR).
2. Free half overlay mode when unlicensed.
3. Slider, AC-only, unsupported screen.
4. Local license unlock.
5. Sleep/wake watchdog.
6. Landing / pricing copy (replica-launch) later.
