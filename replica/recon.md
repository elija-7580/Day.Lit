# Daylit — recon (Vivid / MacBrightness pattern)

Stand: 2026-10-13. Target: macOS menu-bar app that unlocks Liquid Retina XDR / Pro Display XDR headroom for SDR desktop content. Method: replica-skill clean-room from public pages only. Brand: **Daylit** (not Vivid, not MacBrightness).

## Scope

| Question | Answer |
| --- | --- |
| App / platform | Desktop: macOS 13+, menu bar |
| Slice | Core loop only: unlock extra brightness, free half-screen trial, one-time full unlock |
| Who for | Elija’s Mac first; product shaped like MacBrightness pricing |

## Sources (public)

| Source | URL | Use |
| --- | --- | --- |
| Vivid marketing | https://www.getvivid.app | Feature pitch, FAQ, pricing shape |
| MacBrightness marketing / pricing | https://macbrightness.com/#pricing | Free splitscreen, $5 / team / company one-time |
| Public technique write-ups | MacBright README, XDR Light, xdr-boost READMEs | Public Metal EDR + gamma / overlay patterns (no code copied) |
| Apple WWDC21 | Explore HDR rendering with EDR | Public API surface |

No binary decompile, no private APIs, no scraping of paid builds.

## Screen inventory

| ID | Screen | How | Purpose | Key components | States |
| --- | --- | --- | --- | --- | --- |
| S01 | Menu bar popover | Status item click | Toggle boost, mode, boost amount | Toggle, slider, mode badge, Quit | unsupported display, on battery warn, free vs licensed |
| S02 | Splitscreen demo | First launch / free mode | Left half boosted, right stock | Half overlay or divider label | free only |
| S03 | Buy / unlock | Menu → Unlock | One-time license entry / buy link | License field, Open checkout | invalid key, unlocked |
| S04 | Unsupported | Auto | Explain no EDR headroom | Message | Air / non-XDR |

## Flows

```
F01 Enable boost (licensed)
    S01 toggle on -> EDR primer + gamma -> whole screen brighter
    edge: wake from sleep, lid close, no headroom

F02 Try free splitscreen
    Launch -> S02 half boost -> optional S03 unlock

F03 Adjust intensity
    S01 slider -> rewrite gamma ceiling (or overlay factor)

F04 Survive sleep/wake
    System notifications -> re-apply boost within a few seconds
```

Happy path clicks: open menu (1) → toggle (2). Beat: zero new shortcuts; system brightness keys still work.

## Components

- Status item (sun / brightness glyph)
- Enable toggle
- Boost slider (1.0–2.0×)
- Mode chip: Free half / Full / Unsupported
- AC-only checkbox (save battery)
- License / unlock row
- Quit

## Inferred data model

```
Settings  enabled, boostCeiling, acOnly, licensed, licenseKeyHash
          evidence: public menus of category apps; confidence: high

DisplayCapability  hasEDRHeadroom, maxEDRComponent
          evidence: NSScreen public API; confidence: high

License  local key or StoreKit later
          evidence: MacBrightness/Vivid one-time; confidence: medium (checkout deferred)
```

## Cannot clone

- Vivid / MacBrightness names, logos, trademarks, copy, marketing assets
- Any proprietary binary or private CoreDisplay / SkyLight presets
- Hardware Apple does not expose as EDR headroom (Air, many externals)

## Size

S–M weekend for MVP menu bar + free half + full gamma unlock. Hard parts: sleep/wake restore, half-screen free mode without high GPU cost, honest unsupported messaging.

## Core loop (summary)

Unlock XDR headroom for desktop → free half-screen forever → pay once for full screen → stay near 0% CPU while active.
